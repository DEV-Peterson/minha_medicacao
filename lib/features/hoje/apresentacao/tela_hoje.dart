import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/notificacoes/identificador_notificacao.dart';
import '../../../core/notificacoes/planejador_notificacoes.dart';
import '../../../core/util/formatadores.dart';
import '../../doses/dados/dose_repository.dart';
import '../../medicamentos/apresentacao/formulario_medicamento.dart';
import '../dados/agenda_repository.dart';
import '../dominio/dose_prevista.dart';

class TelaHoje extends ConsumerWidget {
  const TelaHoje({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agenda = ref.watch(agendaHojeProvider);
    final possuiMedicamentos =
        ref.watch(medicamentosProvider).valueOrNull?.isNotEmpty ?? false;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(agendaHojeProvider),
      child: agenda.when(
        loading: () => const _ListaRolavel(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => _ListaRolavel(
          child: _ErroCarregamento(
            onRetry: () => ref.invalidate(agendaHojeProvider),
          ),
        ),
        data: (value) => _ConteudoHoje(
          agenda: value,
          possuiMedicamentos: possuiMedicamentos,
        ),
      ),
    );
  }
}

class _ConteudoHoje extends ConsumerWidget {
  const _ConteudoHoje({required this.agenda, required this.possuiMedicamentos});

  final AgendaDoDia agenda;
  final bool possuiMedicamentos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (agenda.doses.isEmpty) {
      return _ListaRolavel(
        child: possuiMedicamentos
            ? const _SemDosesHoje()
            : _EstadoVazio(
                onCadastrar: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FormularioMedicamento(),
                  ),
                ),
              ),
      );
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          formatarDataExtensa(agenda.data),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _ResumoDia(agenda: agenda),
        if (agenda.proxima case final next?) ...[
          const SizedBox(height: 20),
          Text('Próxima dose', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _CartaoProximaDose(item: next),
        ],
        const SizedBox(height: 24),
        Text('Doses de hoje', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (var index = 0; index < agenda.doses.length; index++) ...[
          _ItemDose(item: agenda.doses[index]),
          if (index != agenda.doses.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SemDosesHoje extends StatelessWidget {
  const _SemDosesHoje();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma dose programada para hoje',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Seus medicamentos continuam disponíveis na aba Medicamentos.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumoDia extends StatelessWidget {
  const _ResumoDia({required this.agenda});

  final AgendaDoDia agenda;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              agenda.restantes == 0
                  ? Icons.check_circle_outline
                  : Icons.schedule_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${agenda.tomadas} de ${agenda.total} doses tomadas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    agenda.restantes == 0
                        ? 'Nenhuma dose pendente hoje'
                        : '${agenda.restantes} ${agenda.restantes == 1 ? 'dose restante' : 'doses restantes'} hoje',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartaoProximaDose extends StatelessWidget {
  const _CartaoProximaDose({required this.item});

  final DoseComEstado item;

  @override
  Widget build(BuildContext context) {
    final dose = item.dose;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatarHora(dose.dataHoraProgramada),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              nomeMedicamento(
                item.medicamento.nome,
                item.medicamento.concentracao,
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              '${formatarQuantidade(dose.quantidadeDose)} ${dose.unidadeDose}',
            ),
            if (dose.instrucoes case final instructions?) ...[
              const SizedBox(height: 4),
              Text(instructions),
            ],
            const SizedBox(height: 12),
            _AcoesDose(item: item),
          ],
        ),
      ),
    );
  }
}

class _ItemDose extends StatelessWidget {
  const _ItemDose({required this.item});

  final DoseComEstado item;

  @override
  Widget build(BuildContext context) {
    final visual = _visualStatus(context, item.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    formatarHora(item.dose.dataHoraProgramada),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(visual.icon, color: visual.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nomeMedicamento(
                          item.medicamento.nome,
                          item.medicamento.concentracao,
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${formatarQuantidade(item.dose.quantidadeDose)} ${item.dose.unidadeDose}',
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _descricaoStatus(item),
                        style: TextStyle(color: visual.color),
                      ),
                      if (item.status == StatusDose.emAtraso)
                        const Text(
                          'Consulte a orientação prescrita caso tenha dúvida '
                          'sobre como proceder.',
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.status == StatusDose.pendente ||
                item.status == StatusDose.emAtraso) ...[
              const SizedBox(height: 8),
              _AcoesDose(item: item, compact: true),
            ],
          ],
        ),
      ),
    );
  }
}

class _AcoesDose extends ConsumerWidget {
  const _AcoesDose({required this.item, this.compact = false});

  final DoseComEstado item;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilledButton.icon(
          onPressed: () => _confirmar(context, ref),
          icon: const Icon(Icons.check),
          label: const Text('Tomei'),
        ),
        OutlinedButton(
          onPressed: () => _adiar(context, ref),
          child: const Text('Adiar'),
        ),
        TextButton(
          onPressed: () => _naoTomada(context, ref),
          child: Text(compact ? 'Não tomei' : 'Não tomei'),
        ),
      ],
    );
  }

  Future<void> _confirmar(BuildContext context, WidgetRef ref) async {
    final now = ref.read(relogioProvider).agora();
    if (now.isBefore(item.dose.dataHoraProgramada)) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar dose antecipada?'),
          content: Text(
            'Esta dose está programada para '
            '${formatarHora(item.dose.dataHoraProgramada)}. '
            'Deseja registrar que foi tomada agora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Registrar'),
            ),
          ],
        ),
      );
      if (accepted != true || !context.mounted) return;
    }
    try {
      final result = await ref
          .read(doseRepositoryProvider)
          .confirmar(
            doseKey: item.dose.doseKey,
            tratamentoId: item.dose.tratamentoId,
            dataHoraProgramada: item.dose.dataHoraProgramada,
            dataHoraAcao: now,
          );
      await _reconciliarSilenciosamente(ref);
      if (!context.mounted) return;
      final message = switch (result.estado) {
        EstadoAcaoDose.registrada => 'Dose registrada como tomada.',
        EstadoAcaoDose.jaTomada =>
          'Esta dose já foi registrada como tomada às ${formatarHora(result.registro.dataHoraAcao)}.',
        EstadoAcaoDose.jaNaoTomada =>
          'Esta dose já foi registrada como não tomada.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!context.mounted) return;
      _mostrarErro(context, error);
    }
  }

  Future<void> _naoTomada(BuildContext context, WidgetRef ref) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar dose não tomada?'),
        content: const Text(
          'A dose será mantida no histórico e não haverá baixa no estoque.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Não tomei'),
          ),
        ],
      ),
    );
    if (accepted != true || !context.mounted) return;
    try {
      final result = await ref
          .read(doseRepositoryProvider)
          .registrarNaoTomada(
            doseKey: item.dose.doseKey,
            tratamentoId: item.dose.tratamentoId,
            dataHoraProgramada: item.dose.dataHoraProgramada,
          );
      await _reconciliarSilenciosamente(ref);
      if (!context.mounted) return;
      final message = result.estado == EstadoAcaoDose.registrada
          ? 'Dose registrada como não tomada.'
          : 'Esta dose já possui um registro.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on Object catch (error) {
      if (!context.mounted) return;
      _mostrarErro(context, error);
    }
  }

  Future<void> _adiar(BuildContext context, WidgetRef ref) async {
    final minutes = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('Adiar lembrete')),
            ListTile(
              leading: const Icon(Icons.snooze),
              title: const Text('10 minutos'),
              onTap: () => Navigator.pop(context, 10),
            ),
            ListTile(
              leading: const Icon(Icons.snooze),
              title: const Text('30 minutos'),
              onTap: () => Navigator.pop(context, 30),
            ),
          ],
        ),
      ),
    );
    if (minutes == null || !context.mounted) return;
    final now = ref.read(relogioProvider).agora();
    final notificacaoId = IdentificadorNotificacao.paraChave(
      PlanejadorNotificacoes.chaveDoAdiamento(item.dose.doseKey),
    );
    try {
      await ref
          .read(doseRepositoryProvider)
          .adiar(
            doseKey: item.dose.doseKey,
            tratamentoId: item.dose.tratamentoId,
            medicamentoId: item.dose.medicamentoId,
            dataHoraProgramada: item.dose.dataHoraProgramada,
            lembrarEm: now.add(Duration(minutes: minutes)),
            notificacaoId: notificacaoId,
          );
      await _reconciliarSilenciosamente(ref);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lembrete adiado por $minutes minutos.')),
      );
    } on Object catch (error) {
      if (!context.mounted) return;
      _mostrarErro(context, error);
    }
  }
}

class _StatusVisual {
  const _StatusVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}

_StatusVisual _visualStatus(BuildContext context, StatusDose status) {
  return switch (status) {
    StatusDose.tomada => const _StatusVisual(Icons.check_circle, Colors.green),
    StatusDose.naoTomada => _StatusVisual(
      Icons.cancel,
      Theme.of(context).colorScheme.error,
    ),
    StatusDose.emAtraso => _StatusVisual(
      Icons.warning_amber,
      Theme.of(context).colorScheme.error,
    ),
    StatusDose.pendente => _StatusVisual(
      Icons.radio_button_unchecked,
      Theme.of(context).colorScheme.primary,
    ),
  };
}

String _descricaoStatus(DoseComEstado item) {
  return switch (item.status) {
    StatusDose.tomada =>
      'Tomada às ${formatarHora(item.registro!.dataHoraAcao)}',
    StatusDose.naoTomada => 'Não tomada',
    StatusDose.emAtraso =>
      'Dose não confirmada. Horário previsto: ${formatarHora(item.dose.dataHoraProgramada)}',
    StatusDose.pendente => 'Pendente',
  };
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.onCadastrar});

  final VoidCallback onCadastrar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum medicamento cadastrado',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre o primeiro medicamento para montar sua agenda.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCadastrar,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar medicamento'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErroCarregamento extends StatelessWidget {
  const _ErroCarregamento({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Não foi possível carregar a agenda.'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }
}

class _ListaRolavel extends StatelessWidget {
  const _ListaRolavel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ListView(
    physics: const AlwaysScrollableScrollPhysics(),
    children: [
      SizedBox(height: MediaQuery.sizeOf(context).height * 0.62, child: child),
    ],
  );
}

void _mostrarErro(BuildContext context, Object error) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Não foi possível concluir a operação.')),
  );
}

Future<void> _reconciliarSilenciosamente(WidgetRef ref) async {
  try {
    await ref.read(servicoNotificacaoProvider).reconciliar();
    ref.invalidate(saudeNotificacoesProvider);
  } on Object {
    // O registro no SQLite continua válido; a próxima abertura reconcilia.
  }
}
