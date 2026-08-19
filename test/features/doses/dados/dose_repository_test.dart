import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/doses/dados/dose_repository.dart';

import '../../../core/banco/banco_teste.dart';

void main() {
  late AppDatabase db;
  late DoseRepository repository;

  setUp(() async {
    db = criarBancoEmMemoria();
    repository = DoseRepository(db);
    await inserirMedicamentoTeste(
      db,
      controleEstoque: true,
      unidadeEstoque: 'comprimido',
    );
    await inserirTratamentoTeste(db, consumoEstoquePorDose: 1.5);
  });

  tearDown(() async {
    await db.close();
  });

  group('DoseRepository', () {
    test('confirmação repetida é idempotente e gera uma única saída', () async {
      final programada = DateTime(2026, 8, 18, 8);
      final primeiraAcao = DateTime(2026, 8, 18, 8, 7);

      final primeira = await repository.confirmar(
        doseKey: 'dose-08',
        tratamentoId: 'tratamento-1',
        dataHoraProgramada: programada,
        dataHoraAcao: primeiraAcao,
      );
      final segunda = await repository.confirmar(
        doseKey: 'dose-08',
        tratamentoId: 'tratamento-1',
        dataHoraProgramada: programada,
        dataHoraAcao: DateTime(2026, 8, 18, 8, 8),
      );

      final registros = await db.select(db.registrosDose).get();
      final movimentos = await movimentacoesDoMedicamento(db, 'medicamento-1');
      expect(primeira.estado, EstadoAcaoDose.registrada);
      expect(segunda.estado, EstadoAcaoDose.jaTomada);
      expect(segunda.registro.id, primeira.registro.id);
      expect(registros, hasLength(1));
      expect(registros.single.dataHoraAcao, primeiraAcao);
      expect(movimentos, hasLength(1));
      expect(movimentos.single.tipo, 'saidaDose');
      expect(movimentos.single.quantidade, 1.5);
      expect(movimentos.single.registroDoseId, registros.single.id);
    });

    test(
      'duas confirmações concorrentes preservam as mesmas invariantes',
      () async {
        final resultados = await Future.wait([
          repository.confirmar(
            doseKey: 'dose-concorrente',
            tratamentoId: 'tratamento-1',
            dataHoraProgramada: DateTime(2026, 8, 18, 20),
          ),
          repository.confirmar(
            doseKey: 'dose-concorrente',
            tratamentoId: 'tratamento-1',
            dataHoraProgramada: DateTime(2026, 8, 18, 20),
          ),
        ]);

        expect(resultados.map((resultado) => resultado.estado).toSet(), {
          EstadoAcaoDose.registrada,
          EstadoAcaoDose.jaTomada,
        });
        expect(await db.select(db.registrosDose).get(), hasLength(1));
        expect(
          await movimentacoesDoMedicamento(db, 'medicamento-1'),
          hasLength(1),
        );
      },
    );

    test(
      'não tomada persiste sem saída e bloqueia confirmação posterior',
      () async {
        final naoTomada = await repository.registrarNaoTomada(
          doseKey: 'dose-nao-tomada',
          tratamentoId: 'tratamento-1',
          dataHoraProgramada: DateTime(2026, 8, 18, 12),
          dataHoraAcao: DateTime(2026, 8, 18, 12, 30),
        );
        final confirmacao = await repository.confirmar(
          doseKey: 'dose-nao-tomada',
          tratamentoId: 'tratamento-1',
          dataHoraProgramada: DateTime(2026, 8, 18, 12),
        );

        final registros = await db.select(db.registrosDose).get();
        expect(naoTomada.estado, EstadoAcaoDose.registrada);
        expect(confirmacao.estado, EstadoAcaoDose.jaNaoTomada);
        expect(registros, hasLength(1));
        expect(registros.single.status, 'naoTomada');
        expect(await movimentacoesDoMedicamento(db, 'medicamento-1'), isEmpty);
      },
    );

    test('correção estorna saída uma vez e mantém vínculo auditável', () async {
      await repository.confirmar(
        doseKey: 'dose-corrigida',
        tratamentoId: 'tratamento-1',
        dataHoraProgramada: DateTime(2026, 8, 18, 8),
        dataHoraAcao: DateTime(2026, 8, 18, 8, 5),
      );

      await repository.corrigirParaNaoTomada(
        'dose-corrigida',
        agora: DateTime(2026, 8, 18, 9),
      );
      await repository.corrigirParaNaoTomada(
        'dose-corrigida',
        agora: DateTime(2026, 8, 18, 9, 1),
      );

      final registro = await db.select(db.registrosDose).getSingle();
      final movimentos = await movimentacoesDoMedicamento(db, 'medicamento-1');
      final saida = movimentos.singleWhere((item) => item.tipo == 'saidaDose');
      final estorno = movimentos.singleWhere(
        (item) => item.tipo == 'ajusteEntrada',
      );
      expect(registro.status, 'naoTomada');
      expect(movimentos, hasLength(2));
      expect(estorno.quantidade, saida.quantidade);
      expect(estorno.unidade, saida.unidade);
      expect(estorno.movimentacaoOrigemId, saida.id);
      expect(estorno.registroDoseId, registro.id);
    });
  });
}
