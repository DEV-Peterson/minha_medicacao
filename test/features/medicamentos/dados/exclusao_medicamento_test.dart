import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/doses/dados/dose_repository.dart';
import 'package:minha_medicacao/features/medicamentos/dados/medicamento_repository.dart';
import 'package:minha_medicacao/features/medicamentos/dominio/cadastro_medicamento.dart';

import '../../../core/banco/banco_teste.dart';

void main() {
  late AppDatabase db;
  late MedicamentoRepository repository;

  setUp(() {
    db = criarBancoEmMemoria();
    repository = MedicamentoRepository(db);
  });

  tearDown(() => db.close());

  Future<String> cadastrarComEstoque() => repository.cadastrar(
    CadastroMedicamento(
      nome: 'Losartana',
      formaFarmaceutica: 'comprimido',
      unidadeDosePadrao: 'comprimido',
      quantidadeDose: 1,
      unidadeDose: 'comprimido',
      dataInicio: DateTime(2026, 8, 18),
      usoContinuo: true,
      tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
      horarios: const [HorarioCadastro(8, 0)],
      controlarEstoque: true,
      unidadeEstoque: 'comprimido',
      estoqueInicial: 30,
      consumoEstoquePorDose: 1,
    ),
    agora: DateTime(2026, 8, 18, 7),
  );

  test(
    'exclui cadastro sem histórico junto com tudo que depende dele',
    () async {
      final medicamentoId = await cadastrarComEstoque();
      final tratamento = await db.select(db.tratamentos).getSingle();
      await db
          .into(db.anexos)
          .insert(
            AnexosCompanion.insert(
              id: 'anexo-1',
              medicamentoId: medicamentoId,
              tipo: 'fotoMedicamento',
              caminhoRelativo: 'anexos/medicamentos/foto.jpg',
              criadoEm: DateTime(2026, 8, 18, 9),
            ),
          );
      await db
          .into(db.adiamentosDose)
          .insert(
            AdiamentosDoseCompanion.insert(
              id: 'adiamento-1',
              doseKey: 'dose-1',
              tratamentoId: tratamento.id,
              medicamentoId: medicamentoId,
              dataHoraProgramada: DateTime(2026, 8, 18, 8),
              lembrarEm: DateTime(2026, 8, 18, 8, 10),
              notificacaoId: 42,
              criadoEm: DateTime(2026, 8, 18, 8),
            ),
          );

      final anexos = await repository.excluir(medicamentoId);

      expect(anexos, ['anexos/medicamentos/foto.jpg']);
      expect(await db.select(db.medicamentos).get(), isEmpty);
      expect(await db.select(db.tratamentos).get(), isEmpty);
      expect(await db.select(db.horariosTratamento).get(), isEmpty);
      expect(await db.select(db.movimentacoesEstoque).get(), isEmpty);
      expect(await db.select(db.anexos).get(), isEmpty);
      expect(await db.select(db.adiamentosDose).get(), isEmpty);
    },
  );

  test('recusa exclusão quando existe dose registrada', () async {
    final medicamentoId = await cadastrarComEstoque();
    final tratamento = await db.select(db.tratamentos).getSingle();
    await DoseRepository(db).confirmar(
      doseKey: 'dose:v1|tratamento|regra|1',
      tratamentoId: tratamento.id,
      dataHoraProgramada: DateTime(2026, 8, 18, 8),
      dataHoraAcao: DateTime(2026, 8, 18, 8, 5),
    );

    await expectLater(
      repository.excluir(medicamentoId),
      throwsA(isA<ExclusaoBloqueadaPorHistorico>()),
    );

    // Nada pode ter sido apagado pela tentativa.
    expect(await db.select(db.medicamentos).get(), hasLength(1));
    expect(await db.select(db.tratamentos).get(), hasLength(1));
    expect(await db.select(db.registrosDose).get(), hasLength(1));
    expect(await db.select(db.movimentacoesEstoque).get(), hasLength(2));
  });

  test('conta doses registradas do medicamento', () async {
    final medicamentoId = await cadastrarComEstoque();
    final tratamento = await db.select(db.tratamentos).getSingle();

    expect(await repository.contarRegistrosDose(medicamentoId), 0);

    await DoseRepository(db).registrarNaoTomada(
      doseKey: 'dose:v1|tratamento|regra|2',
      tratamentoId: tratamento.id,
      dataHoraProgramada: DateTime(2026, 8, 18, 8),
      dataHoraAcao: DateTime(2026, 8, 18, 9),
    );

    expect(await repository.contarRegistrosDose(medicamentoId), 1);
  });

  test('medicamento inexistente falha sem apagar nada', () async {
    await cadastrarComEstoque();

    await expectLater(
      repository.excluir('nao-existe'),
      throwsA(isA<StateError>()),
    );
    expect(await db.select(db.medicamentos).get(), hasLength(1));
  });

  test('exclusão não afeta outro medicamento', () async {
    final primeiro = await cadastrarComEstoque();
    await repository.cadastrar(
      CadastroMedicamento(
        nome: 'Metformina',
        formaFarmaceutica: 'comprimido',
        unidadeDosePadrao: 'comprimido',
        quantidadeDose: 1,
        unidadeDose: 'comprimido',
        dataInicio: DateTime(2026, 8, 18),
        usoContinuo: true,
        tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
        horarios: const [HorarioCadastro(12, 0)],
      ),
      agora: DateTime(2026, 8, 18, 7),
    );

    await repository.excluir(primeiro);

    final restantes = await db.select(db.medicamentos).get();
    expect(restantes.single.nome, 'Metformina');
    expect(await db.select(db.tratamentos).get(), hasLength(1));
    expect(await db.select(db.horariosTratamento).get(), hasLength(1));
  });
}
