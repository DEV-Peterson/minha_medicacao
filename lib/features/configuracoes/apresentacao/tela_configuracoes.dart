import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout.dart';
import '../../../app/providers.dart';
import '../../../core/arquivos/arquivo_seguro.dart';
import '../../../core/backup/backup_excecao.dart';
import '../../../core/util/formatadores.dart';

class TelaConfiguracoes extends ConsumerStatefulWidget {
  const TelaConfiguracoes({super.key});

  @override
  ConsumerState<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends ConsumerState<TelaConfiguracoes> {
  var _ocupado = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(configuracoesProvider);
    final notificationHealth = ref.watch(saudeNotificacoesProvider);
    final days =
        int.tryParse(settings.valueOrNull?['diasAlertaEstoque'] ?? '7') ?? 7;
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ConteudoCentralizado(
        child: ListView(
          children: [
            if (_ocupado) const LinearProgressIndicator(),
            const _SectionTitle('Lembretes'),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notificações'),
              subtitle: Text(
                notificationHealth.when(
                  data: (health) =>
                      health.notificacoesHabilitadas && health.canalHabilitado
                      ? 'Habilitadas'
                      : 'Não habilitadas',
                  loading: () => 'Verificando...',
                  error: (_, _) => 'Não foi possível verificar',
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.alarm_outlined),
              title: const Text('Alarmes exatos'),
              subtitle: Text(
                notificationHealth.when(
                  data: (health) => health.alarmesExatosHabilitados
                      ? 'Habilitados'
                      : 'Não habilitados — os lembretes continuam chegando, '
                            'mas podem atrasar alguns minutos',
                  loading: () => 'Verificando...',
                  error: (_, _) => 'Não foi possível verificar',
                ),
              ),
            ),
            if (notificationHealth.valueOrNull?.proximoLembrete
                case final next?)
              ListTile(
                leading: const Icon(Icons.upcoming_outlined),
                title: const Text('Próximo lembrete'),
                subtitle: Text(
                  '${formatarData(next.dataHoraLocal)} às '
                  '${formatarHora(next.dataHoraLocal)} - ${next.corpo.split('\n').first}',
                ),
              ),
            if (notificationHealth.valueOrNull case final health?)
              if (!health.totalmenteHabilitadas)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.tonalIcon(
                    onPressed: _ocupado ? null : _configurarLembretes,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Configurar lembretes'),
                  ),
                ),
            const Divider(),
            const _SectionTitle('Estoque'),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Avisar antes de acabar'),
              subtitle: Text('Aproximadamente $days dias'),
              onTap: () => _alterarDias(context, ref, days),
            ),
            const Divider(),
            const _SectionTitle('Backup'),
            ListTile(
              enabled: !_ocupado,
              leading: const Icon(Icons.backup_outlined),
              title: const Text('Criar e compartilhar backup'),
              subtitle: const Text('Banco e anexos em um único arquivo ZIP'),
              onTap: _criarBackup,
            ),
            ListTile(
              enabled: !_ocupado,
              leading: const Icon(Icons.restore_outlined),
              title: const Text('Restaurar backup'),
              subtitle: const Text(
                'Selecione um backup local ou no Google Drive',
              ),
              onTap: _restaurarBackup,
            ),
            const Divider(),
            const _SectionTitle('Sobre'),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Minha Medicação'),
              subtitle: Text(
                'Versão '
                '${ref.watch(versaoAplicativoProvider).valueOrNull ?? '—'}\n'
                'Aplicativo local de organização. Não fornece orientação '
                'médica.',
              ),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _alterarDias(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final value = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Alerta de estoque baixo'),
        children: [
          for (final value in [3, 5, 7, 10, 14])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, value),
              child: Row(
                children: [
                  Icon(
                    value == current
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  const SizedBox(width: 12),
                  Text('$value dias'),
                ],
              ),
            ),
        ],
      ),
    );
    if (value == null) return;
    await ref
        .read(configuracaoRepositoryProvider)
        .definir('diasAlertaEstoque', '$value');
    ref.invalidate(estoquesComPrevisaoProvider);
  }

  Future<void> _criarBackup() async {
    setState(() => _ocupado = true);
    try {
      final result = await ref.read(servicoBackupProvider).criar();
      await ref
          .read(servicoCompartilhamentoBackupProvider)
          .compartilhar(result.arquivo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backup criado. O compartilhamento foi aberto.'),
        ),
      );
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível criar o backup.')),
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _configurarLembretes() async {
    setState(() => _ocupado = true);
    try {
      final service = ref.read(servicoNotificacaoProvider);
      final health = await service.verificarSaude();
      if (!health.notificacoesHabilitadas) {
        await service.solicitarPermissaoNotificacoes();
      }
      if (!health.alarmesExatosHabilitados) {
        await service.solicitarPermissaoAlarmesExatos();
      }
      final updated = await service.verificarSaude();
      if (!updated.totalmenteHabilitadas) {
        await service.abrirConfiguracoes();
      }
      ref.invalidate(saudeNotificacoesProvider);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir as configurações de lembretes.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _restaurarBackup() async {
    setState(() => _ocupado = true);
    var iniciouRestauracao = false;
    File? arquivoSelecionado;
    try {
      final arquivo = await ref
          .read(servicoSelecaoBackupProvider)
          .selecionarParaRestauracao();
      if (arquivo == null) return;
      arquivoSelecionado = arquivo;
      if (!mounted) return;

      final confirmado = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Substituir os dados atuais?'),
          content: const Text(
            'A restauração substitui medicamentos, histórico, estoque e anexos. '
            'Antes da troca, o aplicativo criará automaticamente um backup de '
            'segurança dos dados atuais.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restaurar'),
            ),
          ],
        ),
      );
      if (confirmado != true) return;

      iniciouRestauracao = true;
      final resultado = await ref
          .read(servicoRestauracaoBackupProvider)
          .restaurar(arquivo);
      if (!mounted) return;
      final texto = resultado.avisos.isEmpty
          ? 'Backup restaurado. Um backup de segurança dos dados anteriores foi preservado.'
          : 'Dados restaurados, mas ${resultado.avisos.first.mensagem.toLowerCase()}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(texto)));
    } on BackupInvalido catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensagem)));
    } on FalhaNaRestauracao catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensagem)));
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            iniciouRestauracao
                ? 'Não foi possível concluir a restauração. Os dados anteriores foram mantidos.'
                : 'Não foi possível abrir o backup selecionado.',
          ),
        ),
      );
    } finally {
      if (arquivoSelecionado != null) {
        await excluirSemPropagar(arquivoSelecionado);
      }
      if (mounted) setState(() => _ocupado = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
