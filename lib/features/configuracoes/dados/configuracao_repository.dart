import 'package:drift/drift.dart';

import '../../../core/banco/app_database.dart';
import '../../../core/data_hora/relogio.dart';

class ConfiguracaoRepository {
  const ConfiguracaoRepository(
    this._db, {
    this.relogio = const RelogioSistema(),
  });

  final AppDatabase _db;
  final Relogio relogio;

  Stream<Map<String, String>> observarTodas() => _db
      .select(_db.configuracoes)
      .watch()
      .map((rows) => {for (final row in rows) row.chave: row.valor});

  Future<String?> obter(String chave) async =>
      (_db.select(_db.configuracoes)
            ..where((table) => table.chave.equals(chave)))
          .getSingleOrNull()
          .then((row) => row?.valor);

  Future<void> definir(String chave, String valor, {DateTime? agora}) async {
    await _db
        .into(_db.configuracoes)
        .insert(
          ConfiguracoesCompanion.insert(
            chave: chave,
            valor: valor,
            atualizadoEm: agora ?? relogio.agora(),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }
}
