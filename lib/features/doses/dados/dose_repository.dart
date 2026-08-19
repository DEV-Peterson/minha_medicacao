import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/banco/app_database.dart';
import '../../../core/data_hora/relogio.dart';

enum EstadoAcaoDose { registrada, jaTomada, jaNaoTomada }

class ResultadoAcaoDose {
  const ResultadoAcaoDose(this.estado, this.registro);

  final EstadoAcaoDose estado;
  final RegistroDoseDb registro;
}

class DoseRepository {
  DoseRepository(this._db, {Uuid? uuid, this.relogio = const RelogioSistema()})
    : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;
  final Relogio relogio;

  Future<ResultadoAcaoDose> confirmar({
    required String doseKey,
    required String tratamentoId,
    required DateTime dataHoraProgramada,
    DateTime? dataHoraAcao,
  }) async {
    final now = dataHoraAcao ?? relogio.agora();
    return _db.transaction(() async {
      final tratamento = await (_db.select(
        _db.tratamentos,
      )..where((table) => table.id.equals(tratamentoId))).getSingle();
      final medicamento =
          await (_db.select(_db.medicamentos)
                ..where((table) => table.id.equals(tratamento.medicamentoId)))
              .getSingle();
      final registroId = _uuid.v4();
      final created = await _db
          .into(_db.registrosDose)
          .insertReturningOrNull(
            RegistrosDoseCompanion.insert(
              id: registroId,
              doseKey: doseKey,
              tratamentoId: tratamento.id,
              medicamentoId: medicamento.id,
              dataHoraProgramada: dataHoraProgramada,
              dataHoraAcao: now,
              quantidadeDose: tratamento.quantidadeDose,
              unidadeDose: tratamento.unidadeDose,
              status: 'tomada',
              criadoEm: now,
              atualizadoEm: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      if (created == null) {
        final existing = await (_db.select(
          _db.registrosDose,
        )..where((table) => table.doseKey.equals(doseKey))).getSingle();
        return ResultadoAcaoDose(
          existing.status == 'tomada'
              ? EstadoAcaoDose.jaTomada
              : EstadoAcaoDose.jaNaoTomada,
          existing,
        );
      }
      final consumo = tratamento.consumoEstoquePorDose;
      final unidadeEstoque = medicamento.unidadeEstoque;
      if (medicamento.controleEstoque &&
          consumo != null &&
          unidadeEstoque != null) {
        await _db
            .into(_db.movimentacoesEstoque)
            .insert(
              MovimentacoesEstoqueCompanion.insert(
                id: _uuid.v4(),
                medicamentoId: medicamento.id,
                registroDoseId: Value(registroId),
                tipo: 'saidaDose',
                quantidade: consumo,
                unidade: unidadeEstoque,
                dataHora: now,
                observacao: const Value('Dose confirmada'),
              ),
            );
      }
      await (_db.delete(
        _db.adiamentosDose,
      )..where((table) => table.doseKey.equals(doseKey))).go();
      return ResultadoAcaoDose(EstadoAcaoDose.registrada, created);
    });
  }

  Future<ResultadoAcaoDose> registrarNaoTomada({
    required String doseKey,
    required String tratamentoId,
    required DateTime dataHoraProgramada,
    DateTime? dataHoraAcao,
  }) async {
    final now = dataHoraAcao ?? relogio.agora();
    return _db.transaction(() async {
      final tratamento = await (_db.select(
        _db.tratamentos,
      )..where((table) => table.id.equals(tratamentoId))).getSingle();
      final created = await _db
          .into(_db.registrosDose)
          .insertReturningOrNull(
            RegistrosDoseCompanion.insert(
              id: _uuid.v4(),
              doseKey: doseKey,
              tratamentoId: tratamento.id,
              medicamentoId: tratamento.medicamentoId,
              dataHoraProgramada: dataHoraProgramada,
              dataHoraAcao: now,
              quantidadeDose: tratamento.quantidadeDose,
              unidadeDose: tratamento.unidadeDose,
              status: 'naoTomada',
              criadoEm: now,
              atualizadoEm: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final registro =
          created ??
          await (_db.select(
            _db.registrosDose,
          )..where((table) => table.doseKey.equals(doseKey))).getSingle();
      await (_db.delete(
        _db.adiamentosDose,
      )..where((table) => table.doseKey.equals(doseKey))).go();
      return ResultadoAcaoDose(
        created != null
            ? EstadoAcaoDose.registrada
            : registro.status == 'tomada'
            ? EstadoAcaoDose.jaTomada
            : EstadoAcaoDose.jaNaoTomada,
        registro,
      );
    });
  }

  Future<AdiamentoDoseDb> adiar({
    required String doseKey,
    required String tratamentoId,
    required String medicamentoId,
    required DateTime dataHoraProgramada,
    required DateTime lembrarEm,
    required int notificacaoId,
    DateTime? agora,
  }) async {
    return _db.transaction(() async {
      final existing = await (_db.select(
        _db.registrosDose,
      )..where((table) => table.doseKey.equals(doseKey))).getSingleOrNull();
      if (existing != null) {
        throw StateError('Esta dose já possui um registro.');
      }
      return _db
          .into(_db.adiamentosDose)
          .insertReturning(
            AdiamentosDoseCompanion.insert(
              id: _uuid.v4(),
              doseKey: doseKey,
              tratamentoId: tratamentoId,
              medicamentoId: medicamentoId,
              dataHoraProgramada: dataHoraProgramada,
              lembrarEm: lembrarEm,
              notificacaoId: notificacaoId,
              criadoEm: agora ?? relogio.agora(),
            ),
            mode: InsertMode.insertOrReplace,
          );
    });
  }

  Stream<List<RegistroDoseDb>> observarRegistrosNoPeriodo(
    DateTime inicio,
    DateTime fim,
  ) {
    final query = _db.select(_db.registrosDose)
      ..where(
        (table) =>
            table.dataHoraProgramada.isBiggerOrEqualValue(inicio) &
            table.dataHoraProgramada.isSmallerThanValue(fim),
      )
      ..orderBy([(table) => OrderingTerm.asc(table.dataHoraProgramada)]);
    return query.watch();
  }

  Future<void> corrigirParaNaoTomada(String doseKey, {DateTime? agora}) async {
    final now = agora ?? relogio.agora();
    await _db.transaction(() async {
      final registro = await (_db.select(
        _db.registrosDose,
      )..where((table) => table.doseKey.equals(doseKey))).getSingle();
      if (registro.status == 'naoTomada') return;
      final saidas =
          await (_db.select(_db.movimentacoesEstoque)..where(
                (table) =>
                    table.registroDoseId.equals(registro.id) &
                    table.tipo.equals('saidaDose'),
              ))
              .get();
      for (final saida in saidas) {
        final jaEstornada =
            await (_db.select(_db.movimentacoesEstoque)..where(
                  (table) => table.movimentacaoOrigemId.equals(saida.id),
                ))
                .getSingleOrNull();
        if (jaEstornada == null) {
          await _db
              .into(_db.movimentacoesEstoque)
              .insert(
                MovimentacoesEstoqueCompanion.insert(
                  id: _uuid.v4(),
                  medicamentoId: saida.medicamentoId,
                  registroDoseId: Value(registro.id),
                  movimentacaoOrigemId: Value(saida.id),
                  tipo: 'ajusteEntrada',
                  quantidade: saida.quantidade,
                  unidade: saida.unidade,
                  dataHora: now,
                  observacao: const Value('Estorno de confirmação corrigida'),
                ),
              );
        }
      }
      await (_db.update(
        _db.registrosDose,
      )..where((table) => table.id.equals(registro.id))).write(
        RegistrosDoseCompanion(
          status: const Value('naoTomada'),
          dataHoraAcao: Value(now),
          atualizadoEm: Value(now),
          observacao: const Value('Registro corrigido pela usuária'),
        ),
      );
    });
  }
}
