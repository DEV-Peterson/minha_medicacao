import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';

import 'banco_teste.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = criarBancoEmMemoria();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase', () {
    test('cria schema, configurações iniciais e ativa foreign keys', () async {
      final configuracoes = await db.select(db.configuracoes).get();
      final foreignKeys = await db
          .customSelect('PRAGMA foreign_keys')
          .getSingle();

      expect({
        for (final item in configuracoes) item.chave: item.valor,
      }, containsPair('diasAlertaEstoque', '7'));
      expect({
        for (final item in configuracoes) item.chave: item.valor,
      }, containsPair('versaoFormatoBackup', '1'));
      expect({
        for (final item in configuracoes) item.chave: item.valor,
      }, containsPair('configuracaoInicialConcluida', 'false'));
      expect(foreignKeys.read<int>('foreign_keys'), 1);
      await db.verificarIntegridade();
    });

    test('FK impede tratamento para medicamento inexistente', () async {
      final agora = DateTime(2026, 8, 18);

      await expectLater(
        db
            .into(db.tratamentos)
            .insert(
              TratamentosCompanion.insert(
                id: 'tratamento-sem-medicamento',
                medicamentoId: 'inexistente',
                quantidadeDose: 1,
                unidadeDose: 'comprimido',
                dataInicio: agora,
                usoContinuo: true,
                tipoAgendamento: 'horariosFixos',
                criadoEm: agora,
                atualizadoEm: agora,
              ),
            ),
        throwsA(isA<Exception>()),
      );
      expect(await db.select(db.tratamentos).get(), isEmpty);
    });

    test('FK restringe exclusão do medicamento com tratamento', () async {
      await inserirMedicamentoTeste(db);
      await inserirTratamentoTeste(db);

      await expectLater(
        (db.delete(
          db.medicamentos,
        )..where((tabela) => tabela.id.equals('medicamento-1'))).go(),
        throwsA(isA<Exception>()),
      );
      expect(await db.select(db.medicamentos).get(), hasLength(1));
    });

    test(
      'FK remove horários em cascata ao remover tratamento sem histórico',
      () async {
        await inserirMedicamentoTeste(db);
        await inserirTratamentoTeste(db);
        await db
            .into(db.horariosTratamento)
            .insert(
              HorariosTratamentoCompanion.insert(
                id: 'horario-1',
                tratamentoId: 'tratamento-1',
                hora: 8,
                minuto: 0,
                ordem: 0,
              ),
            );

        await (db.delete(
          db.tratamentos,
        )..where((tabela) => tabela.id.equals('tratamento-1'))).go();

        expect(await db.select(db.horariosTratamento).get(), isEmpty);
        expect(await db.select(db.medicamentos).get(), hasLength(1));
      },
    );

    test('constraints rejeitam dose, intervalo e status inválidos', () async {
      await inserirMedicamentoTeste(db);
      final agora = DateTime(2026, 8, 18);

      await expectLater(
        db
            .into(db.tratamentos)
            .insert(
              TratamentosCompanion.insert(
                id: 'quantidade-invalida',
                medicamentoId: 'medicamento-1',
                quantidadeDose: 0,
                unidadeDose: 'comprimido',
                dataInicio: agora,
                usoContinuo: true,
                tipoAgendamento: 'horariosFixos',
                criadoEm: agora,
                atualizadoEm: agora,
              ),
            ),
        throwsA(isA<Exception>()),
      );
      await expectLater(
        db
            .into(db.tratamentos)
            .insert(
              TratamentosCompanion.insert(
                id: 'intervalo-invalido',
                medicamentoId: 'medicamento-1',
                quantidadeDose: 1,
                unidadeDose: 'comprimido',
                dataInicio: agora,
                usoContinuo: true,
                tipoAgendamento: 'intervalo',
                dataHoraAncora: Value(agora),
                intervaloMinutos: const Value(0),
                criadoEm: agora,
                atualizadoEm: agora,
              ),
            ),
        throwsA(isA<Exception>()),
      );

      await inserirTratamentoTeste(db);
      await expectLater(
        db
            .into(db.registrosDose)
            .insert(
              RegistrosDoseCompanion.insert(
                id: 'registro-invalido',
                doseKey: 'dose-invalida',
                tratamentoId: 'tratamento-1',
                medicamentoId: 'medicamento-1',
                dataHoraProgramada: agora,
                dataHoraAcao: agora,
                quantidadeDose: 1,
                unidadeDose: 'comprimido',
                status: 'pendente',
                criadoEm: agora,
                atualizadoEm: agora,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('unicidade protege horário e doseKey', () async {
      await inserirMedicamentoTeste(db);
      await inserirTratamentoTeste(db);
      final agora = DateTime(2026, 8, 18, 8);

      Future<void> inserirHorario(String id) async {
        await db
            .into(db.horariosTratamento)
            .insert(
              HorariosTratamentoCompanion.insert(
                id: id,
                tratamentoId: 'tratamento-1',
                hora: 8,
                minuto: 0,
                ordem: 0,
              ),
            );
      }

      Future<void> inserirRegistro(String id) async {
        await db
            .into(db.registrosDose)
            .insert(
              RegistrosDoseCompanion.insert(
                id: id,
                doseKey: 'tratamento-1|08:00|2026-08-18',
                tratamentoId: 'tratamento-1',
                medicamentoId: 'medicamento-1',
                dataHoraProgramada: agora,
                dataHoraAcao: agora,
                quantidadeDose: 1,
                unidadeDose: 'comprimido',
                status: 'tomada',
                criadoEm: agora,
                atualizadoEm: agora,
              ),
            );
      }

      await inserirHorario('horario-1');
      await expectLater(inserirHorario('horario-2'), throwsA(isA<Exception>()));
      await inserirRegistro('registro-1');
      await expectLater(
        inserirRegistro('registro-2'),
        throwsA(isA<Exception>()),
      );

      expect(await db.select(db.horariosTratamento).get(), hasLength(1));
      expect(await db.select(db.registrosDose).get(), hasLength(1));
    });
  });
}
