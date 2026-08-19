import 'package:drift/drift.dart';

import '../../../core/banco/app_database.dart';

class ItemHistorico {
  const ItemHistorico({required this.registro, required this.medicamento});

  final RegistroDoseDb registro;
  final MedicamentoDb medicamento;
}

class HistoricoRepository {
  const HistoricoRepository(this._db);

  final AppDatabase _db;

  Stream<List<ItemHistorico>> observar({
    required DateTime inicio,
    required DateTime fimExclusivo,
    String? medicamentoId,
  }) {
    final query =
        _db.select(_db.registrosDose).join([
            innerJoin(
              _db.medicamentos,
              _db.medicamentos.id.equalsExp(_db.registrosDose.medicamentoId),
            ),
          ])
          ..where(
            _db.registrosDose.dataHoraProgramada.isBiggerOrEqualValue(inicio) &
                _db.registrosDose.dataHoraProgramada.isSmallerThanValue(
                  fimExclusivo,
                ),
          )
          ..orderBy([OrderingTerm.desc(_db.registrosDose.dataHoraProgramada)]);
    if (medicamentoId != null) {
      query.where(_db.registrosDose.medicamentoId.equals(medicamentoId));
    }
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => ItemHistorico(
              registro: row.readTable(_db.registrosDose),
              medicamento: row.readTable(_db.medicamentos),
            ),
          )
          .toList(growable: false),
    );
  }
}
