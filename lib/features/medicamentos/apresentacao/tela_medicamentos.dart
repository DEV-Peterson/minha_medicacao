import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/layout.dart';
import '../../../app/providers.dart';
import '../../../core/arquivos/armazenamento_anexos.dart';
import '../../../core/banco/app_database.dart';
import '../../../core/util/formatadores.dart';
import '../../tratamentos/dominio/modelos_agenda.dart';
import '../../tratamentos/dominio/recorrencia_persistida.dart';
import '../dados/medicamento_repository.dart';
import '../dominio/cadastro_medicamento.dart';
import 'formulario_medicamento.dart';
import 'formulario_tratamento.dart';

class TelaMedicamentos extends ConsumerStatefulWidget {
  const TelaMedicamentos({super.key});

  @override
  ConsumerState<TelaMedicamentos> createState() => _TelaMedicamentosState();
}

class _TelaMedicamentosState extends ConsumerState<TelaMedicamentos> {
  final _busca = TextEditingController();
  var _termo = '';
  var _mostrarInativos = false;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  bool _correspondeABusca(MedicamentoResumo item) {
    if (_termo.isEmpty) return true;
    final alvo = nomeMedicamento(
      item.medicamento.nome,
      item.medicamento.concentracao,
    ).toLowerCase();
    return alvo.contains(_termo);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(medicamentosProvider);
    return Scaffold(
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text('Não foi possível carregar os medicamentos.'),
        ),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('Nenhum medicamento cadastrado.'));
          }
          final ativos = data
              .where((item) => item.medicamento.ativo)
              .where(_correspondeABusca)
              .toList();
          final inativos = data
              .where((item) => !item.medicamento.ativo)
              .where(_correspondeABusca)
              .toList();
          // Inativados saem da lista do dia a dia, mas continuam encontráveis:
          // aparecem assim que houver busca, ou ao abrir a seção.
          final revelarInativos =
              inativos.isNotEmpty && (_termo.isNotEmpty || _mostrarInativos);

          return ConteudoCentralizado(
            larguraMaxima: 1100,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
              children: [
                if (data.length > 3 || _termo.isNotEmpty)
                  TextField(
                    key: const Key('campo_busca_medicamento'),
                    controller: _busca,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Buscar medicamento',
                      suffixIcon: _termo.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _busca.clear();
                                setState(() => _termo = '');
                              },
                            ),
                    ),
                    onChanged: (valor) =>
                        setState(() => _termo = valor.trim().toLowerCase()),
                  ),
                const SizedBox(height: 12),
                if (ativos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _termo.isEmpty
                          ? 'Nenhum medicamento ativo.'
                          : 'Nenhum medicamento ativo encontrado.',
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  GradeDeCartoes(
                    itens: [
                      for (final item in ativos) _CartaoMedicamento(item: item),
                    ],
                  ),
                if (inativos.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  if (_termo.isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(
                          () => _mostrarInativos = !_mostrarInativos,
                        ),
                        icon: Icon(
                          _mostrarInativos
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                        label: Text(
                          '${inativos.length} '
                          '${inativos.length == 1 ? 'inativado' : 'inativados'}',
                        ),
                      ),
                    ),
                  if (revelarInativos) ...[
                    if (_termo.isNotEmpty)
                      Text(
                        'Inativados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 8),
                    GradeDeCartoes(
                      itens: [
                        for (final item in inativos)
                          _CartaoMedicamento(item: item),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'adicionar_medicamento',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const FormularioMedicamento(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }
}

class _CartaoMedicamento extends ConsumerWidget {
  const _CartaoMedicamento({required this.item});

  final MedicamentoResumo item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicamento = item.medicamento;
    final tratamento = item.tratamento;
    return Card(
      child: InkWell(
        onTap: () => _abrirDetalhes(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                child: Icon(medicamento.ativo ? Icons.medication : Icons.block),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeMedicamento(
                        medicamento.nome,
                        medicamento.concentracao,
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (tratamento != null) ...[
                      Text(
                        '${formatarQuantidade(tratamento.quantidadeDose)} '
                        '${tratamento.unidadeDose}',
                      ),
                      Text(_descricaoAgenda(item)),
                      Text(
                        tratamento.usoContinuo
                            ? 'Uso contínuo'
                            : 'Até ${formatarData(tratamento.dataFim!)}',
                      ),
                    ] else
                      const Text('Sem tratamento ativo'),
                    if (!medicamento.ativo)
                      Text(
                        'Inativo',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _abrirDetalhes(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => _DetalhesMedicamento(item: item)),
    );
  }
}

class _DetalhesMedicamento extends ConsumerWidget {
  const _DetalhesMedicamento({required this.item});

  final MedicamentoResumo item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final med = item.medicamento;
    final treatment = item.tratamento;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        actions: [
          IconButton(
            tooltip: 'Editar medicamento',
            onPressed: () => _editar(context, ref),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ConteudoCentralizado(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Icon(
              Icons.medication,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              nomeMedicamento(med.nome, med.concentracao),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Forma farmacêutica'),
                    subtitle: Text(med.formaFarmaceutica ?? 'Não informada'),
                  ),
                  if (treatment != null) ...[
                    ListTile(
                      title: const Text('Dose'),
                      subtitle: Text(
                        formatarDose(
                          treatment.quantidadeDose,
                          treatment.unidadeDose,
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Agenda'),
                      subtitle: Text(_descricaoAgenda(item)),
                    ),
                    ListTile(
                      title: const Text('Período'),
                      subtitle: Text(
                        treatment.usoContinuo
                            ? 'Uso contínuo desde ${formatarData(treatment.dataInicio)}'
                            : '${formatarData(treatment.dataInicio)} a '
                                  '${formatarData(treatment.dataFim!)}',
                      ),
                    ),
                    if (treatment.instrucoes != null)
                      ListTile(
                        title: const Text('Instruções'),
                        subtitle: Text(treatment.instrucoes!),
                      ),
                  ],
                  if (med.observacoes != null)
                    ListTile(
                      title: const Text('Observações'),
                      subtitle: Text(med.observacoes!),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SecaoAnexos(medicamentoId: med.id),
            const SizedBox(height: 16),
            if (med.ativo && treatment == null)
              FilledButton.tonalIcon(
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => FormularioTratamento(item: item),
                    ),
                  );
                  if (changed == true && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.add_alarm_outlined),
                label: const Text('Iniciar novo tratamento'),
              ),
            if (treatment != null && treatment.ativo)
              FilledButton.tonalIcon(
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (_) => FormularioTratamento(item: item),
                    ),
                  );
                  if (changed == true && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.edit_calendar_outlined),
                label: const Text('Alterar tratamento'),
              ),
            if (treatment != null && treatment.ativo)
              OutlinedButton.icon(
                onPressed: () => _encerrar(context, ref, treatment.id),
                icon: const Icon(Icons.event_busy),
                label: const Text('Encerrar tratamento'),
              ),
            if (med.ativo)
              TextButton.icon(
                onPressed: () => _inativar(context, ref),
                icon: const Icon(Icons.block),
                label: const Text('Inativar medicamento'),
              )
            else
              FilledButton.tonalIcon(
                onPressed: () => _reativar(context, ref),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reativar medicamento'),
              ),
            TextButton.icon(
              onPressed: () => _excluir(context, ref),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Excluir medicamento'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editar(BuildContext context, WidgetRef ref) async {
    final edicao = await showDialog<_EdicaoMedicamento>(
      context: context,
      builder: (_) => _DialogoEdicaoMedicamento(
        nome: item.medicamento.nome,
        concentracao: item.medicamento.concentracao,
        formaFarmaceutica: item.medicamento.formaFarmaceutica,
        unidadeDosePadrao: item.medicamento.unidadeDosePadrao,
        observacoes: item.medicamento.observacoes,
      ),
    );
    if (edicao != null && context.mounted) {
      await ref
          .read(medicamentoRepositoryProvider)
          .atualizarDados(
            id: item.medicamento.id,
            nome: edicao.nome,
            concentracao: edicao.concentracao,
            formaFarmaceutica: edicao.formaFarmaceutica,
            unidadeDosePadrao: edicao.unidadeDosePadrao,
            observacoes: edicao.observacoes,
          );
      await _reconciliarSilenciosamente(ref);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _encerrar(
    BuildContext context,
    WidgetRef ref,
    String treatmentId,
  ) async {
    final accepted = await _confirmar(
      context,
      title: 'Encerrar tratamento?',
      text:
          'Novas doses e lembretes deixarão de ser gerados. O histórico será preservado.',
    );
    if (accepted != true || !context.mounted) return;
    await ref
        .read(medicamentoRepositoryProvider)
        .encerrarTratamento(treatmentId);
    await _reconciliarSilenciosamente(ref);
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _reativar(BuildContext context, WidgetRef ref) async {
    final accepted = await _confirmar(
      context,
      title: 'Reativar medicamento?',
      text:
          'O medicamento volta às listas. Os tratamentos encerrados continuam '
          'encerrados: inicie um novo tratamento para voltar a gerar doses.',
    );
    if (accepted != true || !context.mounted) return;
    await ref.read(medicamentoRepositoryProvider).reativar(item.medicamento.id);
    await _reconciliarSilenciosamente(ref);
    if (context.mounted) Navigator.pop(context);
  }

  /// Exclusão real só existe enquanto não há histórico: serve para corrigir
  /// um cadastro errado. Com doses registradas, o caminho oferecido é inativar,
  /// que tira o medicamento da lista sem reescrever o passado.
  Future<void> _excluir(BuildContext context, WidgetRef ref) async {
    final repositorio = ref.read(medicamentoRepositoryProvider);
    final registros = await repositorio.contarRegistrosDose(
      item.medicamento.id,
    );
    if (!context.mounted) return;

    if (registros > 0) {
      final inativar = await _confirmar(
        context,
        title: 'Não é possível excluir',
        text:
            'Este medicamento tem $registros '
            '${registros == 1 ? 'dose registrada' : 'doses registradas'} no '
            'histórico. Você pode inativá-lo: ele sai da lista e continua '
            'aparecendo na busca e no histórico.',
        confirmar: 'Inativar',
      );
      if (inativar == true && context.mounted) {
        await _inativar(context, ref, confirmado: true);
      }
      return;
    }

    final confirmado = await _confirmar(
      context,
      title: 'Excluir medicamento?',
      text:
          'O cadastro, o tratamento, as fotos e as movimentações de estoque '
          'serão apagados definitivamente. Não há histórico de doses a '
          'preservar.',
      confirmar: 'Excluir',
    );
    if (confirmado != true || !context.mounted) return;

    try {
      final anexos = await repositorio.excluir(item.medicamento.id);
      await ref.read(anexoRepositoryProvider).removerArquivos(anexos);
      await _reconciliarSilenciosamente(ref);
      ref.invalidate(estoquesComPrevisaoProvider);
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Medicamento excluído.')));
    } on ExclusaoBloqueadaPorHistorico catch (erro) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(erro.mensagem)));
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir.')),
      );
    }
  }

  Future<void> _inativar(
    BuildContext context,
    WidgetRef ref, {
    bool confirmado = false,
  }) async {
    final accepted =
        confirmado ||
        await _confirmar(
              context,
              title: 'Inativar medicamento?',
              text:
                  'O medicamento sai da lista e continua no histórico. Para '
                  'encontrá-lo depois, use a busca.',
            ) ==
            true;
    if (!accepted || !context.mounted) return;
    await ref.read(medicamentoRepositoryProvider).inativar(item.medicamento.id);
    await _reconciliarSilenciosamente(ref);
    if (context.mounted) Navigator.pop(context);
  }
}

class _EdicaoMedicamento {
  const _EdicaoMedicamento({
    required this.nome,
    required this.concentracao,
    required this.formaFarmaceutica,
    required this.unidadeDosePadrao,
    required this.observacoes,
  });

  final String nome;
  final String concentracao;
  final String formaFarmaceutica;
  final String unidadeDosePadrao;
  final String observacoes;
}

class _DialogoEdicaoMedicamento extends StatefulWidget {
  const _DialogoEdicaoMedicamento({
    required this.nome,
    required this.concentracao,
    required this.formaFarmaceutica,
    required this.unidadeDosePadrao,
    required this.observacoes,
  });

  final String nome;
  final String? concentracao;
  final String? formaFarmaceutica;
  final String? unidadeDosePadrao;
  final String? observacoes;

  @override
  State<_DialogoEdicaoMedicamento> createState() =>
      _DialogoEdicaoMedicamentoState();
}

class _DialogoEdicaoMedicamentoState extends State<_DialogoEdicaoMedicamento> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome = TextEditingController(
    text: widget.nome,
  );
  late final TextEditingController _concentracao = TextEditingController(
    text: widget.concentracao,
  );
  late final TextEditingController _formaFarmaceutica = TextEditingController(
    text: widget.formaFarmaceutica,
  );
  late final TextEditingController _unidadeDosePadrao = TextEditingController(
    text: widget.unidadeDosePadrao,
  );
  late final TextEditingController _observacoes = TextEditingController(
    text: widget.observacoes,
  );

  @override
  void dispose() {
    _nome.dispose();
    _concentracao.dispose();
    _formaFarmaceutica.dispose();
    _unidadeDosePadrao.dispose();
    _observacoes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar medicamento'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nome,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o nome do medicamento.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _concentracao,
                decoration: const InputDecoration(labelText: 'Concentração'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _formaFarmaceutica,
                decoration: const InputDecoration(
                  labelText: 'Forma farmacêutica',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unidadeDosePadrao,
                decoration: const InputDecoration(
                  labelText: 'Unidade padrão da dose',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe a unidade padrão.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _observacoes,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _EdicaoMedicamento(
                nome: _nome.text,
                concentracao: _concentracao.text,
                formaFarmaceutica: _formaFarmaceutica.text,
                unidadeDosePadrao: _unidadeDosePadrao.text,
                observacoes: _observacoes.text,
              ),
            );
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}

class _SecaoAnexos extends ConsumerWidget {
  const _SecaoAnexos({required this.medicamentoId});

  final String medicamentoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(anexoRepositoryProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fotos e receita',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                PopupMenuButton<TipoArquivoAnexo>(
                  tooltip: 'Adicionar anexo',
                  onSelected: (type) => _adicionar(context, ref, type),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: TipoArquivoAnexo.fotoMedicamento,
                      child: Text('Foto do medicamento'),
                    ),
                    PopupMenuItem(
                      value: TipoArquivoAnexo.receita,
                      child: Text('Foto da receita'),
                    ),
                  ],
                  icon: const Icon(Icons.add_a_photo_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StreamBuilder<List<AnexoDb>>(
              stream: repository.observarDoMedicamento(medicamentoId),
              builder: (context, snapshot) {
                final attachments = snapshot.data ?? const [];
                if (attachments.isEmpty) {
                  return const Text('Nenhuma foto adicionada.');
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final attachment in attachments)
                      _MiniaturaAnexo(anexo: attachment),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionar(
    BuildContext context,
    WidgetRef ref,
    TipoArquivoAnexo type,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Câmera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !context.mounted) return;
    final image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 92,
    );
    if (image == null || !context.mounted) return;
    try {
      await ref
          .read(anexoRepositoryProvider)
          .adicionar(medicamentoId: medicamentoId, tipo: type, imagem: image);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Foto adicionada.')));
      }
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível salvar a foto.')),
        );
      }
    }
  }
}

class _MiniaturaAnexo extends ConsumerWidget {
  const _MiniaturaAnexo({required this.anexo});

  final AnexoDb anexo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final descricao = anexo.tipo == 'receita'
        ? 'Foto da receita'
        : 'Foto do medicamento';
    return FutureBuilder(
      future: ref.watch(anexoRepositoryProvider).arquivoDe(anexo),
      builder: (context, snapshot) => SizedBox(
        width: 112,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: snapshot.hasData
                    ? InkWell(
                        onTap: () => _abrir(context, snapshot.data!, descricao),
                        child: Hero(
                          tag: 'anexo-${anexo.id}',
                          child: Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            semanticLabel: descricao,
                          ),
                        ),
                      )
                    : ColoredBox(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: const Icon(Icons.image_outlined),
                      ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    anexo.tipo == 'receita' ? 'Receita' : 'Medicamento',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Remover foto',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _remover(context, ref),
                  icon: const Icon(Icons.delete_outline, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrir(BuildContext context, File arquivo, String descricao) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _VisualizadorAnexo(
          arquivo: arquivo,
          titulo: descricao,
          heroTag: 'anexo-${anexo.id}',
        ),
      ),
    );
  }

  Future<void> _remover(BuildContext context, WidgetRef ref) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto?'),
        content: const Text('O arquivo será removido do aplicativo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (accepted == true) {
      await ref.read(anexoRepositoryProvider).remover(anexo.id);
    }
  }
}

/// Exibe o anexo em tela cheia, com zoom por gesto e arrasto.
class _VisualizadorAnexo extends StatelessWidget {
  const _VisualizadorAnexo({
    required this.arquivo,
    required this.titulo,
    required this.heroTag,
  });

  final File arquivo;
  final String titulo;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Hero(
            tag: heroTag,
            child: Image.file(
              arquivo,
              fit: BoxFit.contain,
              semanticLabel: titulo,
              errorBuilder: (context, _, _) => const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível abrir esta imagem.',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _descricaoAgenda(MedicamentoResumo item) {
  final treatment = item.tratamento;
  if (treatment == null) return 'Sem agenda';
  if (treatment.tipoAgendamento == 'intervalo') {
    final hours = (treatment.intervaloMinutos ?? 0) / 60;
    return 'A cada ${formatarQuantidade(hours)} horas';
  }
  final horarios = item.horarios
      .map(
        (time) =>
            '${time.hora.toString().padLeft(2, '0')}:'
            '${time.minuto.toString().padLeft(2, '0')}',
      )
      .join(' / ');
  final recorrencia = RecorrenciaPersistida.doTratamento(treatment);
  // "Todos os dias" é o caso comum e não precisa aparecer no cartão.
  return recorrencia is RecorrenciaDiaria
      ? horarios
      : '$horarios · ${descreverRecorrencia(recorrencia)}';
}

Future<bool?> _confirmar(
  BuildContext context, {
  required String title,
  required String text,
  String confirmar = 'Confirmar',
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: Text(text),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: Text(confirmar),
      ),
    ],
  ),
);

Future<void> _reconciliarSilenciosamente(WidgetRef ref) async {
  try {
    await ref.read(servicoNotificacaoProvider).reconciliar();
    ref.invalidate(saudeNotificacoesProvider);
  } on Object {
    // O banco é a fonte de verdade; a abertura seguinte reconcilia.
  }
}
