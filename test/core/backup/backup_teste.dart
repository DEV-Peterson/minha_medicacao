import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';

Future<AppDatabase> abrirBancoArquivo(File arquivo) async {
  await arquivo.parent.create(recursive: true);
  return AppDatabase.forTesting(NativeDatabase(arquivo));
}

Future<void> inserirMedicamentoNome(
  AppDatabase db,
  String nome, {
  String id = 'medicamento-1',
}) async {
  final agora = DateTime.utc(2026, 8, 18);
  await db
      .into(db.medicamentos)
      .insert(
        MedicamentosCompanion.insert(
          id: id,
          nome: nome,
          unidadeDosePadrao: const Value('comprimido'),
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );
}
