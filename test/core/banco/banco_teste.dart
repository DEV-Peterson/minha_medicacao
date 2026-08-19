import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';

AppDatabase criarBancoEmMemoria() =>
    AppDatabase.forTesting(NativeDatabase.memory());

Future<MedicamentoDb> inserirMedicamentoTeste(
  AppDatabase db, {
  String id = 'medicamento-1',
  bool controleEstoque = false,
  String? unidadeEstoque,
}) async {
  final agora = DateTime(2026, 8, 18, 7);
  await db
      .into(db.medicamentos)
      .insert(
        MedicamentosCompanion.insert(
          id: id,
          nome: 'Medicamento teste',
          unidadeDosePadrao: const Value('comprimido'),
          unidadeEstoque: Value(unidadeEstoque),
          controleEstoque: Value(controleEstoque),
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );
  return (db.select(
    db.medicamentos,
  )..where((tabela) => tabela.id.equals(id))).getSingle();
}

Future<TratamentoDb> inserirTratamentoTeste(
  AppDatabase db, {
  String id = 'tratamento-1',
  String medicamentoId = 'medicamento-1',
  double consumoEstoquePorDose = 1,
}) async {
  final agora = DateTime(2026, 8, 18, 7);
  await db
      .into(db.tratamentos)
      .insert(
        TratamentosCompanion.insert(
          id: id,
          medicamentoId: medicamentoId,
          quantidadeDose: 1,
          unidadeDose: 'comprimido',
          consumoEstoquePorDose: Value(consumoEstoquePorDose),
          dataInicio: DateTime(2026, 8, 18),
          usoContinuo: true,
          tipoAgendamento: 'horariosFixos',
          criadoEm: agora,
          atualizadoEm: agora,
        ),
      );
  return (db.select(
    db.tratamentos,
  )..where((tabela) => tabela.id.equals(id))).getSingle();
}

Future<List<MovimentacaoEstoqueDb>> movimentacoesDoMedicamento(
  AppDatabase db,
  String medicamentoId,
) =>
    (db.select(db.movimentacoesEstoque)
          ..where((tabela) => tabela.medicamentoId.equals(medicamentoId))
          ..orderBy([(tabela) => OrderingTerm.asc(tabela.dataHora)]))
        .get();
