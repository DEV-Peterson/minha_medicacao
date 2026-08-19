import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout.dart';
import '../../../app/providers.dart';
import '../../../core/util/formatadores.dart';

class TelaEstoque extends ConsumerWidget {
  const TelaEstoque({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(estoquesComPrevisaoProvider);
    final settings = ref.watch(configuracoesProvider).valueOrNull ?? const {};
    final alertDays = int.tryParse(settings['diasAlertaEstoque'] ?? '7') ?? 7;
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) =>
          const Center(child: Text('Não foi possível calcular o estoque.')),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('Nenhum medicamento cadastrado.'));
        }
        final withoutControl = items
            .where((item) => !item.saldo.medicamento.controleEstoque)
            .toList();
        final controlled = items
            .where((item) => item.saldo.medicamento.controleEstoque)
            .toList();
        final low = controlled.where((item) {
          final date = item.previsao?.dataInsuficiente;
          return date != null &&
              date.difference(ref.read(relogioProvider).agora()).inDays <=
                  alertDays;
        }).toList();
        final enough = controlled.where((item) => !low.contains(item)).toList();
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(estoquesComPrevisaoProvider),
          child: ConteudoCentralizado(
            larguraMaxima: 1100,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (low.isNotEmpty)
                  _GrupoEstoque(
                    title: 'Precisa repor em breve',
                    items: low,
                    warning: true,
                  ),
                if (enough.isNotEmpty) ...[
                  if (low.isNotEmpty) const SizedBox(height: 24),
                  _GrupoEstoque(title: 'Estoque suficiente', items: enough),
                ],
                if (withoutControl.isNotEmpty) ...[
                  if (low.isNotEmpty || enough.isNotEmpty)
                    const SizedBox(height: 24),
                  _GrupoEstoque(
                    title: 'Sem controle de estoque',
                    items: withoutControl,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GrupoEstoque extends StatelessWidget {
  const _GrupoEstoque({
    required this.title,
    required this.items,
    this.warning = false,
  });

  final String title;
  final List<EstoqueComPrevisao> items;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (warning) ...[
              Icon(
                Icons.warning_amber,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GradeDeCartoes(
          itens: [for (final item in items) _CartaoEstoque(item: item)],
        ),
      ],
    );
  }
}

class _CartaoEstoque extends ConsumerWidget {
  const _CartaoEstoque({required this.item});

  final EstoqueComPrevisao item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicine = item.saldo.medicamento;
    final unit = medicine.unidadeEstoque ?? 'unidades';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nomeMedicamento(medicine.nome, medicine.concentracao),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            if (medicine.controleEstoque) ...[
              Text(
                'Restam: ${formatarQuantidade(item.saldo.quantidade)} $unit',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              if (item.previsao?.dataInsuficiente case final date?)
                Text(
                  'Estoque suficiente até aproximadamente ${formatarData(date)}',
                )
              else
                const Text('Sem término previsto no horizonte calculado'),
              if ((item.previsao?.consumoProximosSeteDias ?? 0) > 0)
                Text(
                  'Consumo previsto em 7 dias: '
                  '${formatarQuantidade(item.previsao!.consumoProximosSeteDias)} $unit',
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(
                    onPressed: () => _adicionar(context, ref),
                    child: const Text('Adicionar estoque'),
                  ),
                  TextButton(
                    onPressed: () => _ajustar(context, ref),
                    child: const Text('Ajustar'),
                  ),
                  TextButton(
                    onPressed: () => _desativarControle(context, ref),
                    child: const Text('Desativar controle'),
                  ),
                ],
              ),
            ] else ...[
              const Text('Controle não ativado para este medicamento.'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => _ativarControle(context, ref),
                child: const Text('Ativar controle de estoque'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _adicionar(BuildContext context, WidgetRef ref) async {
    final value = await _pedirQuantidade(
      context,
      title: 'Adicionar estoque',
      label: 'Quantidade adquirida',
    );
    if (value == null || !context.mounted) return;
    try {
      await ref
          .read(estoqueRepositoryProvider)
          .adicionar(
            medicamentoId: item.saldo.medicamento.id,
            quantidade: value,
            observacao: 'Caixa nova',
          );
      ref.invalidate(estoquesComPrevisaoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Estoque adicionado.')));
      }
    } on Object {
      if (context.mounted) _erro(context);
    }
  }

  Future<void> _ativarControle(BuildContext context, WidgetRef ref) async {
    final medicine = item.saldo.medicamento;
    final resumo = ref
        .read(medicamentosProvider)
        .valueOrNull
        ?.where((resumo) => resumo.medicamento.id == medicine.id)
        .firstOrNull;
    final tratamento = resumo?.tratamento;
    final resultado = await showDialog<_AtivacaoControleEstoque>(
      context: context,
      builder: (_) => _DialogoAtivarControle(
        unidadeInicial:
            medicine.unidadeEstoque ?? medicine.unidadeDosePadrao ?? '',
        exigeConsumo: tratamento != null,
        consumoInicial: tratamento == null
            ? ''
            : formatarQuantidade(tratamento.quantidadeDose),
      ),
    );
    if (resultado == null || !context.mounted) return;
    try {
      await ref
          .read(medicamentoRepositoryProvider)
          .ativarControleEstoque(
            medicamentoId: medicine.id,
            unidadeEstoque: resultado.unidade,
            quantidadeAtual: resultado.quantidade,
            consumoEstoquePorDose: resultado.consumoPorDose,
          );
      ref.invalidate(estoquesComPrevisaoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Controle de estoque ativado.')),
        );
      }
    } on Object {
      if (context.mounted) _erro(context);
    }
  }

  Future<void> _desativarControle(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar o controle de estoque?'),
        content: const Text(
          'As doses confirmadas deixarão de dar baixa. As movimentações já '
          'registradas continuam preservadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;
    try {
      await ref
          .read(medicamentoRepositoryProvider)
          .desativarControleEstoque(item.saldo.medicamento.id);
      ref.invalidate(estoquesComPrevisaoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Controle de estoque desativado.')),
        );
      }
    } on Object {
      if (context.mounted) _erro(context);
    }
  }

  Future<void> _ajustar(BuildContext context, WidgetRef ref) async {
    final value = await _pedirQuantidade(
      context,
      title: 'Ajustar estoque',
      label: 'Contagem real',
      initial: formatarQuantidade(item.saldo.quantidade),
      allowZero: true,
    );
    if (value == null || !context.mounted) return;
    try {
      await ref
          .read(estoqueRepositoryProvider)
          .ajustarPara(
            medicamentoId: item.saldo.medicamento.id,
            contagemReal: value,
          );
      ref.invalidate(estoquesComPrevisaoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Estoque ajustado.')));
      }
    } on Object {
      if (context.mounted) _erro(context);
    }
  }
}

Future<double?> _pedirQuantidade(
  BuildContext context, {
  required String title,
  required String label,
  String? initial,
  bool allowZero = false,
}) {
  return showDialog<double>(
    context: context,
    builder: (context) => _DialogoQuantidade(
      title: title,
      label: label,
      initial: initial,
      allowZero: allowZero,
    ),
  );
}

class _DialogoQuantidade extends StatefulWidget {
  const _DialogoQuantidade({
    required this.title,
    required this.label,
    required this.allowZero,
    this.initial,
  });

  final String title;
  final String label;
  final String? initial;
  final bool allowZero;

  @override
  State<_DialogoQuantidade> createState() => _DialogoQuantidadeState();
}

class _DialogoQuantidadeState extends State<_DialogoQuantidade> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('campo_quantidade_estoque'),
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: widget.label, errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }

  void _salvar() {
    final value = lerDecimal(_controller.text);
    if (value == null || (widget.allowZero ? value < 0 : value <= 0)) {
      setState(() {
        _error = widget.allowZero
            ? 'Informe zero ou um valor positivo.'
            : 'Informe um valor maior que zero.';
      });
      return;
    }
    Navigator.pop(context, value);
  }
}

void _erro(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Não foi possível atualizar o estoque.')),
  );
}

class _AtivacaoControleEstoque {
  const _AtivacaoControleEstoque({
    required this.unidade,
    required this.quantidade,
    this.consumoPorDose,
  });

  final String unidade;
  final double quantidade;
  final double? consumoPorDose;
}

class _DialogoAtivarControle extends StatefulWidget {
  const _DialogoAtivarControle({
    required this.unidadeInicial,
    required this.exigeConsumo,
    required this.consumoInicial,
  });

  final String unidadeInicial;
  final bool exigeConsumo;
  final String consumoInicial;

  @override
  State<_DialogoAtivarControle> createState() => _DialogoAtivarControleState();
}

class _DialogoAtivarControleState extends State<_DialogoAtivarControle> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _unidade = TextEditingController(
    text: widget.unidadeInicial,
  );
  final _quantidade = TextEditingController();
  late final TextEditingController _consumo = TextEditingController(
    text: widget.consumoInicial,
  );

  @override
  void dispose() {
    _unidade.dispose();
    _quantidade.dispose();
    _consumo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ativar controle de estoque'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const Key('campo_unidade_estoque'),
                controller: _unidade,
                decoration: const InputDecoration(
                  labelText: 'Unidade do estoque *',
                ),
                validator: (value) => (value ?? '').trim().isEmpty
                    ? 'Informe a unidade usada no estoque.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('campo_quantidade_disponivel'),
                controller: _quantidade,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantidade disponível *',
                ),
                validator: (value) => (lerDecimal(value ?? '') ?? -1) < 0
                    ? 'Informe zero ou um valor positivo.'
                    : null,
              ),
              if (widget.exigeConsumo) ...[
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('campo_consumo_por_dose'),
                  controller: _consumo,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Consumo de estoque por dose *',
                  ),
                  validator: (value) => (lerDecimal(value ?? '') ?? 0) <= 0
                      ? 'Informe um consumo maior que zero.'
                      : null,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Quando a unidade da dose e a do estoque são diferentes, '
                  'informe quanto cada dose consome. O aplicativo não converte '
                  'unidades sozinho.',
                ),
              ],
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
            if (!_form.currentState!.validate()) return;
            Navigator.pop(
              context,
              _AtivacaoControleEstoque(
                unidade: _unidade.text,
                quantidade: lerDecimal(_quantidade.text)!,
                consumoPorDose: widget.exigeConsumo
                    ? lerDecimal(_consumo.text)
                    : null,
              ),
            );
          },
          child: const Text('Ativar'),
        ),
      ],
    );
  }
}
