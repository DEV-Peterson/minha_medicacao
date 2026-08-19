import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/banco/app_database.dart';
import '../../../core/data_hora/relogio.dart';

class SaldoEstoque {
  const SaldoEstoque({required this.medicamento, required this.quantidade});

  final MedicamentoDb medicamento;
  final double quantidade;
}

class EstoqueRepository {
  EstoqueRepository(
    this._db, {
    Uuid? uuid,
    this.relogio = const RelogioSistema(),
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;
  final Relogio relogio;

  Future<double> calcularSaldo(String medicamentoId) async {
    final result = await _db
        .customSelect(
          '''
      SELECT COALESCE(SUM(
        CASE WHEN tipo IN ('entradaReposicao', 'ajusteEntrada')
             THEN quantidade ELSE -quantidade END
      ), 0.0) AS saldo
      FROM movimentacoes_estoque
      WHERE medicamento_id = ?
      ''',
          variables: [Variable.withString(medicamentoId)],
          readsFrom: {_db.movimentacoesEstoque},
        )
        .getSingle();
    return result.read<double>('saldo');
  }

  Stream<List<SaldoEstoque>> observarSaldos() {
    return _db
        .customSelect(
          '''
      SELECT m.*,
             COALESCE(SUM(
               CASE WHEN mov.tipo IN ('entradaReposicao', 'ajusteEntrada')
                    THEN mov.quantidade ELSE -mov.quantidade END
             ), 0.0) AS saldo
      FROM medicamentos AS m
      LEFT JOIN movimentacoes_estoque AS mov ON mov.medicamento_id = m.id
      WHERE m.ativo = 1
      GROUP BY m.id
      ORDER BY m.nome COLLATE NOCASE
      ''',
          readsFrom: {_db.medicamentos, _db.movimentacoesEstoque},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => SaldoEstoque(
                  medicamento: _db.medicamentos.map(row.data),
                  quantidade: row.read<double>('saldo'),
                ),
              )
              .toList(growable: false),
        );
  }

  Future<void> adicionar({
    required String medicamentoId,
    required double quantidade,
    String? observacao,
    DateTime? agora,
  }) async {
    if (quantidade <= 0) {
      throw ArgumentError.value(
        quantidade,
        'quantidade',
        'Deve ser maior que zero.',
      );
    }
    final medicamento = await (_db.select(
      _db.medicamentos,
    )..where((table) => table.id.equals(medicamentoId))).getSingle();
    if (!medicamento.controleEstoque || medicamento.unidadeEstoque == null) {
      throw StateError(
        'O controle de estoque não está ativo para este medicamento.',
      );
    }
    await _db
        .into(_db.movimentacoesEstoque)
        .insert(
          MovimentacoesEstoqueCompanion.insert(
            id: _uuid.v4(),
            medicamentoId: medicamentoId,
            tipo: 'entradaReposicao',
            quantidade: quantidade,
            unidade: medicamento.unidadeEstoque!,
            dataHora: agora ?? relogio.agora(),
            observacao: Value(_vazioParaNulo(observacao) ?? 'Reposição'),
          ),
        );
  }

  Future<void> ajustarPara({
    required String medicamentoId,
    required double contagemReal,
    String? observacao,
    DateTime? agora,
  }) async {
    if (contagemReal < 0) {
      throw ArgumentError.value(
        contagemReal,
        'contagemReal',
        'Não pode ser negativa.',
      );
    }
    await _db.transaction(() async {
      final medicamento = await (_db.select(
        _db.medicamentos,
      )..where((table) => table.id.equals(medicamentoId))).getSingle();
      if (!medicamento.controleEstoque || medicamento.unidadeEstoque == null) {
        throw StateError(
          'O controle de estoque não está ativo para este medicamento.',
        );
      }
      final atual = await calcularSaldo(medicamentoId);
      final delta = contagemReal - atual;
      if (delta.abs() < 0.000001) return;
      await _db
          .into(_db.movimentacoesEstoque)
          .insert(
            MovimentacoesEstoqueCompanion.insert(
              id: _uuid.v4(),
              medicamentoId: medicamentoId,
              tipo: delta > 0 ? 'ajusteEntrada' : 'ajusteSaida',
              quantidade: delta.abs(),
              unidade: medicamento.unidadeEstoque!,
              dataHora: agora ?? relogio.agora(),
              observacao: Value(
                _vazioParaNulo(observacao) ?? 'Ajuste para contagem real',
              ),
            ),
          );
    });
  }

  Stream<List<MovimentacaoEstoqueDb>> observarMovimentacoes(
    String medicamentoId,
  ) {
    final query = _db.select(_db.movimentacoesEstoque)
      ..where((table) => table.medicamentoId.equals(medicamentoId))
      ..orderBy([(table) => OrderingTerm.desc(table.dataHora)]);
    return query.watch();
  }
}

String? _vazioParaNulo(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
