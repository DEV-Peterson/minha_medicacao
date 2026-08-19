import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/layout.dart';
import '../../../app/providers.dart';
import '../../../core/data_hora/data_hora_local.dart';
import '../../../core/util/formatadores.dart';
import '../dados/historico_repository.dart';

class TelaHistorico extends ConsumerStatefulWidget {
  const TelaHistorico({super.key});

  @override
  ConsumerState<TelaHistorico> createState() => _TelaHistoricoState();
}

class _TelaHistoricoState extends ConsumerState<TelaHistorico> {
  late DateTimeRange _periodo;
  String? _medicamentoId;

  @override
  void initState() {
    super.initState();
    final now = ref.read(relogioProvider).agora();
    final hoje = DataHoraLocal.inicioDoDia(now);
    _periodo = DateTimeRange(
      start: DataHoraLocal.adicionarDiasCalendario(hoje, -29),
      end: hoje,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(historicoRepositoryProvider);
    final medications = ref.watch(medicamentosProvider).valueOrNull ?? const [];
    final endExclusive = DataHoraLocal.inicioDoProximoDia(_periodo.end);
    final filtroPeriodo = OutlinedButton.icon(
      onPressed: _selecionarPeriodo,
      icon: const Icon(Icons.date_range),
      label: Text(
        '${formatarData(_periodo.start)} a ${formatarData(_periodo.end)}',
        overflow: TextOverflow.ellipsis,
      ),
    );
    final filtroMedicamento = DropdownButtonFormField<String?>(
      initialValue: _medicamentoId,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Medicamento'),
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
        for (final item in medications)
          DropdownMenuItem<String?>(
            value: item.medicamento.id,
            child: Text(
              nomeMedicamento(
                item.medicamento.nome,
                item.medicamento.concentracao,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (value) => setState(() => _medicamentoId = value),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ConteudoCentralizado(
            child: LayoutBuilder(
              builder: (context, constraints) => constraints.maxWidth < 520
                  ? Column(
                      children: [
                        SizedBox(width: double.infinity, child: filtroPeriodo),
                        const SizedBox(height: 8),
                        filtroMedicamento,
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: filtroPeriodo),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: filtroMedicamento),
                      ],
                    ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<List<ItemHistorico>>(
            stream: repository.observar(
              inicio: _periodo.start,
              fimExclusivo: endExclusive,
              medicamentoId: _medicamentoId,
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Não foi possível carregar o histórico.'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data!;
              if (items.isEmpty) {
                return const Center(
                  child: Text('Nenhuma dose registrada neste período.'),
                );
              }
              return ConteudoCentralizado(child: _ListaHistorico(items: items));
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarPeriodo() async {
    final result = await showDateRangePicker(
      context: context,
      initialDateRange: _periodo,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Filtrar histórico',
    );
    if (result != null) setState(() => _periodo = result);
  }
}

class _ListaHistorico extends StatelessWidget {
  const _ListaHistorico({required this.items});

  final List<ItemHistorico> items;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<ItemHistorico>>{};
    for (final item in items) {
      final scheduled = item.registro.dataHoraProgramada;
      final date = DateTime(scheduled.year, scheduled.month, scheduled.day);
      groups.putIfAbsent(date, () => []).add(item);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        for (final entry in groups.entries) ...[
          Text(
            formatarData(entry.key),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var index = 0; index < entry.value.length; index++) ...[
                  _ItemHistorico(item: entry.value[index]),
                  if (index != entry.value.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _ItemHistorico extends ConsumerWidget {
  const _ItemHistorico({required this.item});

  final ItemHistorico item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = item.registro;
    final taken = record.status == 'tomada';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: taken
            ? Colors.green.withValues(alpha: 0.14)
            : Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          taken ? Icons.check : Icons.close,
          color: taken
              ? Colors.green.shade700
              : Theme.of(context).colorScheme.error,
        ),
      ),
      title: Text(
        '${formatarHora(record.dataHoraProgramada)}  '
        '${nomeMedicamento(item.medicamento.nome, item.medicamento.concentracao)}',
      ),
      subtitle: Text(
        taken ? 'Tomada às ${formatarHora(record.dataHoraAcao)}' : 'Não tomada',
      ),
      trailing: taken
          ? PopupMenuButton<String>(
              tooltip: 'Opções do registro',
              onSelected: (_) => _corrigir(context, ref),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'naoTomada',
                  child: Text('Corrigir para não tomada'),
                ),
              ],
            )
          : null,
    );
  }

  Future<void> _corrigir(BuildContext context, WidgetRef ref) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Corrigir este registro?'),
        content: const Text(
          'O status mudará para “Não tomada”. Se houve baixa de estoque, '
          'será criado um estorno vinculado, sem apagar o histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Corrigir'),
          ),
        ],
      ),
    );
    if (confirmado != true || !context.mounted) return;
    try {
      await ref
          .read(doseRepositoryProvider)
          .corrigirParaNaoTomada(item.registro.doseKey);
      ref.invalidate(estoquesComPrevisaoProvider);
      try {
        await ref.read(servicoNotificacaoProvider).reconciliar();
      } on Object {
        // O SQLite permanece válido e a próxima abertura reconcilia.
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro corrigido com sucesso.')),
      );
    } on Object {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível corrigir o registro.')),
      );
    }
  }
}
