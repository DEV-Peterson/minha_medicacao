import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/estoque/dados/estoque_repository.dart';

import '../../../core/banco/banco_teste.dart';

void main() {
  late AppDatabase db;
  late EstoqueRepository repository;

  setUp(() async {
    db = criarBancoEmMemoria();
    repository = EstoqueRepository(db);
    await inserirMedicamentoTeste(
      db,
      controleEstoque: true,
      unidadeEstoque: 'comprimido',
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('EstoqueRepository', () {
    test(
      'reposição soma ao ledger sem sobrescrever movimentos anteriores',
      () async {
        await repository.adicionar(
          medicamentoId: 'medicamento-1',
          quantidade: 10,
          observacao: 'Estoque inicial de teste',
          agora: DateTime(2026, 8, 18, 7),
        );
        await repository.adicionar(
          medicamentoId: 'medicamento-1',
          quantidade: 30,
          observacao: 'Caixa nova',
          agora: DateTime(2026, 8, 19, 7),
        );

        final movimentos = await movimentacoesDoMedicamento(
          db,
          'medicamento-1',
        );
        expect(await repository.calcularSaldo('medicamento-1'), 40);
        expect(movimentos, hasLength(2));
        expect(
          movimentos.every((item) => item.tipo == 'entradaReposicao'),
          isTrue,
        );
        expect(movimentos.map((item) => item.quantidade), [10, 30]);
      },
    );

    test('ajuste para menos cria saída com apenas a diferença', () async {
      await repository.adicionar(
        medicamentoId: 'medicamento-1',
        quantidade: 12,
      );

      await repository.ajustarPara(
        medicamentoId: 'medicamento-1',
        contagemReal: 10,
        agora: DateTime(2026, 8, 18, 10),
      );

      final movimentos = await movimentacoesDoMedicamento(db, 'medicamento-1');
      final ajuste = movimentos.singleWhere(
        (item) => item.tipo == 'ajusteSaida',
      );
      expect(ajuste.quantidade, 2);
      expect(await repository.calcularSaldo('medicamento-1'), 10);
    });

    test(
      'ajuste para mais cria entrada e ajuste sem delta não grava',
      () async {
        await repository.adicionar(
          medicamentoId: 'medicamento-1',
          quantidade: 10,
        );
        await repository.ajustarPara(
          medicamentoId: 'medicamento-1',
          contagemReal: 14,
        );
        await repository.ajustarPara(
          medicamentoId: 'medicamento-1',
          contagemReal: 14,
        );

        final movimentos = await movimentacoesDoMedicamento(
          db,
          'medicamento-1',
        );
        final ajuste = movimentos.singleWhere(
          (item) => item.tipo == 'ajusteEntrada',
        );
        expect(ajuste.quantidade, 4);
        expect(movimentos, hasLength(2));
        expect(await repository.calcularSaldo('medicamento-1'), 14);
      },
    );

    test('rejeita quantidade e contagem inválidas sem alterar saldo', () async {
      await expectLater(
        repository.adicionar(medicamentoId: 'medicamento-1', quantidade: 0),
        throwsArgumentError,
      );
      await expectLater(
        repository.ajustarPara(
          medicamentoId: 'medicamento-1',
          contagemReal: -1,
        ),
        throwsArgumentError,
      );

      expect(await repository.calcularSaldo('medicamento-1'), 0);
      expect(await movimentacoesDoMedicamento(db, 'medicamento-1'), isEmpty);
    });

    test('não oferece reposição para medicamento inativado', () async {
      expect(await repository.observarSaldos().first, hasLength(1));

      await (db.update(db.medicamentos)
            ..where((table) => table.id.equals('medicamento-1')))
          .write(const MedicamentosCompanion(ativo: Value(false)));

      expect(await repository.observarSaldos().first, isEmpty);
    });
  });
}
