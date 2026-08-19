import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
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

  tearDown(() async {
    await db.close();
  });

  group('MedicamentoRepository.cadastrar', () {
    test(
      'grava medicamento, tratamento, horários ordenados e estoque inicial',
      () async {
        final agora = DateTime(2026, 8, 18, 7, 30);

        final medicamentoId = await repository.cadastrar(
          _cadastroComEstoque(),
          agora: agora,
        );

        final medicamento = await (db.select(
          db.medicamentos,
        )..where((tabela) => tabela.id.equals(medicamentoId))).getSingle();
        final tratamento =
            await (db.select(db.tratamentos)..where(
                  (tabela) => tabela.medicamentoId.equals(medicamentoId),
                ))
                .getSingle();
        final horarios =
            await (db.select(db.horariosTratamento)
                  ..where((tabela) => tabela.tratamentoId.equals(tratamento.id))
                  ..orderBy([(tabela) => OrderingTerm.asc(tabela.ordem)]))
                .get();
        final movimentos = await movimentacoesDoMedicamento(db, medicamentoId);

        expect(medicamento.nome, 'Losartana');
        expect(medicamento.concentracao, '50 mg');
        expect(medicamento.controleEstoque, isTrue);
        expect(medicamento.unidadeEstoque, 'comprimido');
        expect(tratamento.quantidadeDose, 1);
        expect(tratamento.consumoEstoquePorDose, 1);
        expect(tratamento.usoContinuo, isTrue);
        expect(horarios.map((horario) => (horario.hora, horario.minuto)), [
          (8, 0),
          (20, 0),
        ]);
        expect(movimentos, hasLength(1));
        expect(movimentos.single.tipo, 'entradaReposicao');
        expect(movimentos.single.quantidade, 30);
        expect(movimentos.single.unidade, 'comprimido');
        expect(movimentos.single.observacao, 'Estoque inicial');
        expect(movimentos.single.dataHora, agora);
      },
    );

    test('cadastro é atômico quando uma escrita viola o schema', () async {
      final cadastro = CadastroMedicamento(
        nome: 'Nome com mais de 200 caracteres ${'x' * 220}',
        formaFarmaceutica: 'comprimido',
        unidadeDosePadrao: 'comprimido',
        quantidadeDose: 1,
        unidadeDose: 'comprimido',
        dataInicio: DateTime(2026, 8, 18),
        usoContinuo: true,
        tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
        horarios: const [HorarioCadastro(8, 0)],
      );

      await expectLater(
        repository.cadastrar(cadastro),
        throwsA(isA<Exception>()),
      );

      expect(await db.select(db.medicamentos).get(), isEmpty);
      expect(await db.select(db.tratamentos).get(), isEmpty);
      expect(await db.select(db.horariosTratamento).get(), isEmpty);
      expect(await db.select(db.movimentacoesEstoque).get(), isEmpty);
    });
  });

  group('MedicamentoRepository.criarTratamento', () {
    test('reinicia uso sem alterar o tratamento encerrado', () async {
      final medicamentoId = await repository.cadastrar(
        _cadastroComEstoque(),
        agora: DateTime(2026, 8, 18, 7),
      );
      final anterior = await db.select(db.tratamentos).getSingle();
      await repository.encerrarTratamento(
        anterior.id,
        agora: DateTime(2026, 8, 18, 12),
      );

      final novoId = await repository.criarTratamento(
        medicamentoId: medicamentoId,
        agora: DateTime(2026, 8, 19, 7),
        edicao: EdicaoTratamento(
          quantidadeDose: 0.5,
          unidadeDose: 'comprimido',
          dataInicio: DateTime(2026, 8, 19),
          usoContinuo: true,
          tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
          horarios: const [HorarioCadastro(20, 0), HorarioCadastro(9, 0)],
          consumoEstoquePorDose: 0.5,
        ),
      );

      final tratamentos = await (db.select(
        db.tratamentos,
      )..orderBy([(table) => OrderingTerm.asc(table.criadoEm)])).get();
      final horarios =
          await (db.select(db.horariosTratamento)
                ..where((table) => table.tratamentoId.equals(novoId))
                ..orderBy([(table) => OrderingTerm.asc(table.ordem)]))
              .get();

      expect(tratamentos, hasLength(2));
      expect(tratamentos.first.id, anterior.id);
      expect(tratamentos.first.ativo, isFalse);
      expect(tratamentos.last.id, novoId);
      expect(tratamentos.last.ativo, isTrue);
      expect(tratamentos.last.quantidadeDose, 0.5);
      expect(horarios.map((item) => (item.hora, item.minuto)), [
        (9, 0),
        (20, 0),
      ]);
    });
  });

  group('MedicamentoRepository.ativarControleEstoque', () {
    test(
      'ativa o controle, grava entrada inicial e consumo por dose',
      () async {
        final medicamentoId = await repository.cadastrar(
          _cadastroSemEstoque(),
          agora: DateTime(2026, 8, 18, 7),
        );

        await repository.ativarControleEstoque(
          medicamentoId: medicamentoId,
          unidadeEstoque: ' comprimido ',
          quantidadeAtual: 20,
          consumoEstoquePorDose: 1,
          agora: DateTime(2026, 8, 18, 9),
        );

        final medicamento = await (db.select(
          db.medicamentos,
        )..where((tabela) => tabela.id.equals(medicamentoId))).getSingle();
        final tratamento = await db.select(db.tratamentos).getSingle();
        final movimentos = await movimentacoesDoMedicamento(db, medicamentoId);

        expect(medicamento.controleEstoque, isTrue);
        expect(medicamento.unidadeEstoque, 'comprimido');
        expect(tratamento.consumoEstoquePorDose, 1);
        expect(movimentos, hasLength(1));
        expect(movimentos.single.tipo, 'entradaReposicao');
        expect(movimentos.single.quantidade, 20);
        expect(movimentos.single.unidade, 'comprimido');
        expect(movimentos.single.observacao, 'Estoque inicial');
        expect(movimentos.single.dataHora, DateTime(2026, 8, 18, 9));
      },
    );

    test('recusa ativação sem consumo quando há tratamento ativo', () async {
      final medicamentoId = await repository.cadastrar(
        _cadastroSemEstoque(),
        agora: DateTime(2026, 8, 18, 7),
      );

      await expectLater(
        repository.ativarControleEstoque(
          medicamentoId: medicamentoId,
          unidadeEstoque: 'comprimido',
          quantidadeAtual: 20,
        ),
        throwsA(isA<FormularioInvalido>()),
      );

      final medicamento = await (db.select(
        db.medicamentos,
      )..where((tabela) => tabela.id.equals(medicamentoId))).getSingle();

      expect(medicamento.controleEstoque, isFalse);
      expect(await db.select(db.movimentacoesEstoque).get(), isEmpty);
    });

    test('nova ativação ajusta o saldo sem apagar movimentações', () async {
      final medicamentoId = await repository.cadastrar(
        _cadastroComEstoque(),
        agora: DateTime(2026, 8, 18, 7),
      );
      await repository.desativarControleEstoque(
        medicamentoId,
        agora: DateTime(2026, 8, 18, 8),
      );

      await repository.ativarControleEstoque(
        medicamentoId: medicamentoId,
        unidadeEstoque: 'comprimido',
        quantidadeAtual: 22,
        consumoEstoquePorDose: 1,
        agora: DateTime(2026, 8, 18, 9),
      );

      final movimentos = await movimentacoesDoMedicamento(db, medicamentoId);

      expect(movimentos, hasLength(2));
      expect(movimentos.first.tipo, 'entradaReposicao');
      expect(movimentos.first.quantidade, 30);
      expect(movimentos.last.tipo, 'ajusteSaida');
      expect(movimentos.last.quantidade, 8);
      expect(
        movimentos.last.observacao,
        'Ajuste ao ativar o controle de estoque',
      );
    });
  });

  test('desativar controle preserva o ledger e limpa o consumo', () async {
    final medicamentoId = await repository.cadastrar(
      _cadastroComEstoque(),
      agora: DateTime(2026, 8, 18, 7),
    );

    await repository.desativarControleEstoque(
      medicamentoId,
      agora: DateTime(2026, 8, 18, 8),
    );

    final medicamento = await (db.select(
      db.medicamentos,
    )..where((tabela) => tabela.id.equals(medicamentoId))).getSingle();
    final tratamento = await db.select(db.tratamentos).getSingle();

    expect(medicamento.controleEstoque, isFalse);
    expect(tratamento.consumoEstoquePorDose, null);
    expect(await movimentacoesDoMedicamento(db, medicamentoId), hasLength(1));
  });

  test('reativar medicamento não reabre tratamento encerrado', () async {
    final medicamentoId = await repository.cadastrar(
      _cadastroComEstoque(),
      agora: DateTime(2026, 8, 18, 7),
    );
    await repository.inativar(medicamentoId, agora: DateTime(2026, 8, 18, 8));

    await repository.reativar(medicamentoId, agora: DateTime(2026, 8, 19, 8));

    final medicamento = await (db.select(
      db.medicamentos,
    )..where((tabela) => tabela.id.equals(medicamentoId))).getSingle();
    final tratamento = await db.select(db.tratamentos).getSingle();

    expect(medicamento.ativo, isTrue);
    expect(medicamento.atualizadoEm, DateTime(2026, 8, 19, 8));
    expect(tratamento.ativo, isFalse);
  });

  test('encerra somente tratamento cuja data civil já passou', () async {
    await repository.cadastrar(
      _cadastroTemporario('Ontem', DateTime(2026, 8, 17)),
      agora: DateTime(2026, 8, 1, 7),
    );
    await repository.cadastrar(
      _cadastroTemporario('Hoje', DateTime(2026, 8, 18)),
      agora: DateTime(2026, 8, 1, 7),
    );

    final encerrados = await repository.encerrarTratamentosVencidos(
      agora: DateTime(2026, 8, 18, 23, 59),
    );
    final tratamentos = await db.select(db.tratamentos).get();
    final porFim = {for (final item in tratamentos) item.dataFim: item};

    expect(encerrados, 1);
    expect(porFim[DateTime(2026, 8, 17)]!.ativo, isFalse);
    expect(porFim[DateTime(2026, 8, 18)]!.ativo, isTrue);
  });
}

CadastroMedicamento _cadastroComEstoque() => CadastroMedicamento(
  nome: '  Losartana  ',
  concentracao: ' 50 mg ',
  formaFarmaceutica: 'comprimido',
  unidadeDosePadrao: 'comprimido',
  quantidadeDose: 1,
  unidadeDose: ' comprimido ',
  dataInicio: DateTime(2026, 8, 18),
  usoContinuo: true,
  tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
  horarios: const [HorarioCadastro(20, 0), HorarioCadastro(8, 0)],
  instrucoes: 'Após alimentação',
  controlarEstoque: true,
  unidadeEstoque: ' comprimido ',
  estoqueInicial: 30,
  consumoEstoquePorDose: 1,
);

CadastroMedicamento _cadastroTemporario(String nome, DateTime fim) =>
    CadastroMedicamento(
      nome: nome,
      formaFarmaceutica: 'comprimido',
      unidadeDosePadrao: 'comprimido',
      quantidadeDose: 1,
      unidadeDose: 'comprimido',
      dataInicio: DateTime(2026, 8, 1),
      dataFim: fim,
      usoContinuo: false,
      tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
      horarios: const [HorarioCadastro(8, 0)],
    );

CadastroMedicamento _cadastroSemEstoque() => CadastroMedicamento(
  nome: 'Metformina',
  concentracao: '850 mg',
  formaFarmaceutica: 'comprimido',
  unidadeDosePadrao: 'comprimido',
  quantidadeDose: 1,
  unidadeDose: 'comprimido',
  dataInicio: DateTime(2026, 8, 18),
  usoContinuo: true,
  tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
  horarios: const [HorarioCadastro(12, 0)],
);
