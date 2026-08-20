import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/notificacoes/modelos_notificacao.dart';
import 'package:minha_medicacao/core/notificacoes/planejador_notificacoes.dart';
import 'package:minha_medicacao/core/notificacoes/reconciliador_notificacoes.dart';
import 'package:minha_medicacao/features/doses/dados/dose_repository.dart';
import 'package:minha_medicacao/features/hoje/dados/agenda_repository.dart';
import 'package:timezone/data/latest_all.dart' as dados_tz;
import 'package:timezone/timezone.dart' as tz;

import '../banco/banco_teste.dart';
import 'fake_notificacoes.dart';

void main() {
  late AppDatabase db;
  late AgendaRepository agendaRepository;

  setUpAll(() {
    dados_tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  });

  setUp(() async {
    db = criarBancoEmMemoria();
    agendaRepository = AgendaRepository(db);
    await inserirMedicamentoTeste(db);
    await inserirTratamentoTeste(db);
    await db
        .into(db.horariosTratamento)
        .insert(
          HorariosTratamentoCompanion.insert(
            id: 'horario-8',
            tratamentoId: 'tratamento-1',
            hora: 8,
            minuto: 0,
            ordem: 0,
          ),
        );
    await db
        .into(db.horariosTratamento)
        .insert(
          HorariosTratamentoCompanion.insert(
            id: 'horario-20',
            tratamentoId: 'tratamento-1',
            hora: 20,
            minuto: 0,
            ordem: 1,
          ),
        );
  });

  tearDown(() => db.close());

  group('recorrencia por dias do calendario', () {
    Future<void> definirRecorrencia({
      required String tipo,
      int? intervalo,
      String? diasSemana,
      int? diaDoMes,
    }) async {
      await (db.update(
        db.tratamentos,
      )..where((tabela) => tabela.id.equals('tratamento-1'))).write(
        TratamentosCompanion(
          recorrencia: Value(tipo),
          recorrenciaIntervalo: Value(intervalo),
          recorrenciaDiasSemana: Value(diasSemana),
          recorrenciaDiaDoMes: Value(diaDoMes),
        ),
      );
    }

    test('a cada dois dias nao usa notificacao diaria repetida', () async {
      await definirRecorrencia(tipo: 'cadaNDias', intervalo: 2);
      final planejador = PlanejadorNotificacoes(agendaRepository);

      final resultado = await planejador.planejar(
        agora: DateTime(2026, 8, 18, 7),
      );

      expect(resultado.any((item) => item.recorrenciaDiaria), isFalse);
      // O tratamento comeca em 18/08, entao valem 18, 20, 22 e nunca 19.
      // O tratamento tem dois horarios por dia valido: 08:00 e 20:00.
      expect(resultado.take(4).map((item) => item.dataHoraLocal), [
        DateTime(2026, 8, 18, 8),
        DateTime(2026, 8, 18, 20),
        DateTime(2026, 8, 20, 8),
        DateTime(2026, 8, 20, 20),
      ]);
      final agosto = resultado
          .map((item) => item.dataHoraLocal)
          .where((data) => data.year == 2026 && data.month == DateTime.august)
          .map((data) => data.day)
          .toSet();
      expect(agosto, {18, 20, 22, 24, 26, 28, 30});
    });

    test('dose mensal agenda o proximo mes sem varrer dia a dia', () async {
      await definirRecorrencia(tipo: 'mensal', intervalo: 1, diaDoMes: 20);
      final planejador = PlanejadorNotificacoes(agendaRepository);

      final resultado = await planejador.planejar(
        agora: DateTime(2026, 8, 18, 7),
      );

      expect(resultado, isNotEmpty);
      expect(resultado.any((item) => item.recorrenciaDiaria), isFalse);
      expect(resultado.first.dataHoraLocal, DateTime(2026, 8, 20, 8));
      expect(resultado.map((item) => item.dataHoraLocal.day).toSet(), {20});
    });

    test('dias da semana agenda apenas os dias escolhidos', () async {
      // 1 e segunda-feira, 4 e quinta-feira.
      await definirRecorrencia(
        tipo: 'diasDaSemana',
        intervalo: 1,
        diasSemana: '1,4',
      );
      final planejador = PlanejadorNotificacoes(agendaRepository);

      final resultado = await planejador.planejar(
        agora: DateTime(2026, 8, 18, 7),
      );

      expect(resultado, isNotEmpty);
      expect(resultado.map((item) => item.dataHoraLocal.weekday).toSet(), {
        DateTime.monday,
        DateTime.thursday,
      });
    });
  });

  test('uso continuo com horarios fixos vira recorrencia diaria', () async {
    await (db.update(db.medicamentos)
          ..where((tabela) => tabela.id.equals('medicamento-1')))
        .write(const MedicamentosCompanion(concentracao: Value('50 mg')));
    final planejador = PlanejadorNotificacoes(agendaRepository);

    final resultado = await planejador.planejar(
      agora: DateTime(2026, 8, 18, 7),
    );

    expect(resultado, hasLength(2));
    expect(resultado, everyElement(isA<AgendamentoNotificacao>()));
    expect(resultado.every((item) => item.recorrenciaDiaria), isTrue);
    expect(resultado[0].dataHoraLocal, DateTime(2026, 8, 18, 8));
    expect(resultado[1].dataHoraLocal, DateTime(2026, 8, 18, 20));
    expect(resultado.first.corpo, contains('Medicamento teste 50 mg'));
    expect(resultado.map((item) => item.payload.regraId), [
      'horario-8',
      'horario-20',
    ]);
  });

  for (final status in ['tomada', 'naoTomada']) {
    test(
      'recorrencia pula somente a dose de hoje pre-registrada como $status',
      () async {
        final agora = DateTime(2026, 8, 18, 7);
        final agenda = await agendaRepository.obterDia(agora, agora: agora);
        final doseDasOito = agenda.doses
            .singleWhere((item) => item.dose.regraId == 'horario-8')
            .dose;
        final repositorio = DoseRepository(db);
        if (status == 'tomada') {
          await repositorio.confirmar(
            doseKey: doseDasOito.doseKey,
            tratamentoId: doseDasOito.tratamentoId,
            dataHoraProgramada: doseDasOito.dataHoraProgramada,
            dataHoraAcao: agora,
          );
        } else {
          await repositorio.registrarNaoTomada(
            doseKey: doseDasOito.doseKey,
            tratamentoId: doseDasOito.tratamentoId,
            dataHoraProgramada: doseDasOito.dataHoraProgramada,
            dataHoraAcao: agora,
          );
        }

        final resultado = await PlanejadorNotificacoes(
          agendaRepository,
        ).planejar(agora: agora);
        final oito = resultado.singleWhere(
          (item) => item.payload.regraId == 'horario-8',
        );
        final vinte = resultado.singleWhere(
          (item) => item.payload.regraId == 'horario-20',
        );

        expect(oito.recorrenciaDiaria, isTrue);
        expect(oito.dataHoraLocal, DateTime(2026, 8, 19, 8));
        expect(vinte.dataHoraLocal, DateTime(2026, 8, 18, 20));
      },
    );
  }

  test('tratamento temporario usa ocorrencias one-shot', () async {
    await inserirMedicamentoTeste(db, id: 'medicamento-2');
    final agora = DateTime(2026, 8, 18, 7);
    await db
        .into(db.tratamentos)
        .insert(
          TratamentosCompanion.insert(
            id: 'tratamento-2',
            medicamentoId: 'medicamento-2',
            quantidadeDose: 1,
            unidadeDose: 'comprimido',
            dataInicio: DateTime(2026, 8, 18),
            dataFim: Value(DateTime(2026, 8, 28)),
            usoContinuo: false,
            tipoAgendamento: 'horariosFixos',
            criadoEm: agora,
            atualizadoEm: agora,
          ),
        );
    await db
        .into(db.horariosTratamento)
        .insert(
          HorariosTratamentoCompanion.insert(
            id: 'temporario-9',
            tratamentoId: 'tratamento-2',
            hora: 9,
            minuto: 0,
            ordem: 0,
          ),
        );

    final resultado = await PlanejadorNotificacoes(
      agendaRepository,
    ).planejar(agora: agora);
    final temporarias = resultado
        .where((item) => item.payload.tratamentoId == 'tratamento-2')
        .toList();

    expect(temporarias, hasLength(11));
    expect(temporarias.every((item) => !item.recorrenciaDiaria), isTrue);
    expect(temporarias.first.dataHoraLocal, DateTime(2026, 8, 18, 9));
    expect(temporarias.last.dataHoraLocal, DateTime(2026, 8, 28, 9));
  });

  test(
    'intervalo continuo que divide 24h vira recorrencias por slot ancorado',
    () async {
      await (db.update(
        db.tratamentos,
      )..where((tabela) => tabela.id.equals('tratamento-1'))).write(
        TratamentosCompanion(
          tipoAgendamento: const Value('intervalo'),
          dataHoraAncora: Value(DateTime(2026, 8, 18, 6)),
          intervaloMinutos: const Value(8 * 60),
        ),
      );

      final resultado = await PlanejadorNotificacoes(
        agendaRepository,
      ).planejarComDiagnostico(agora: DateTime(2026, 8, 18, 7));

      expect(resultado.truncado, isFalse);
      expect(resultado.agendamentos, hasLength(3));
      expect(
        resultado.agendamentos.map((item) => item.payload.horaRecorrencia),
        containsAll(<int>[6, 14, 22]),
      );
      expect(
        resultado.agendamentos.map((item) => item.id).toSet(),
        hasLength(3),
      );
      expect(
        resultado.agendamentos.every((item) => item.recorrenciaDiaria),
        isTrue,
      );
      final slotDasSeis = resultado.agendamentos.singleWhere(
        (item) => item.payload.horaRecorrencia == 6,
      );
      expect(slotDasSeis.dataHoraLocal, DateTime(2026, 8, 19, 6));
    },
  );

  test(
    'intervalo continuo nao divisor preserva ancora em janela rolante',
    () async {
      await (db.update(
        db.tratamentos,
      )..where((tabela) => tabela.id.equals('tratamento-1'))).write(
        TratamentosCompanion(
          tipoAgendamento: const Value('intervalo'),
          dataHoraAncora: Value(DateTime(2026, 8, 18, 6)),
          intervaloMinutos: const Value(7 * 60),
        ),
      );
      final planejador = PlanejadorNotificacoes(
        agendaRepository,
        maximoAgendamentos: 4,
      );

      final resultado = await planejador.planejarComDiagnostico(
        agora: DateTime(2026, 8, 18, 7),
      );

      expect(resultado.truncado, isTrue);
      expect(resultado.agendamentos, hasLength(4));
      expect(
        resultado.agendamentos.every((item) => !item.recorrenciaDiaria),
        isTrue,
      );
      expect(resultado.agendamentos.map((item) => item.dataHoraLocal), [
        DateTime(2026, 8, 18, 13),
        DateTime(2026, 8, 18, 20),
        DateTime(2026, 8, 19, 3),
        DateTime(2026, 8, 19, 10),
      ]);
      expect(resultado.coberturaPlanejadaAte, DateTime(2026, 8, 19, 10));
    },
  );

  test(
    'temporario muito longo degrada para as ocorrencias mais proximas',
    () async {
      await (db.update(db.tratamentos)
            ..where((tabela) => tabela.id.equals('tratamento-1')))
          .write(const TratamentosCompanion(ativo: Value(false)));
      await inserirMedicamentoTeste(db, id: 'medicamento-longo');
      final agora = DateTime(2026, 8, 18, 7);
      await db
          .into(db.tratamentos)
          .insert(
            TratamentosCompanion.insert(
              id: 'tratamento-longo',
              medicamentoId: 'medicamento-longo',
              quantidadeDose: 1,
              unidadeDose: 'comprimido',
              dataInicio: DateTime(2026, 8, 18),
              dataFim: Value(DateTime(2030, 8, 18)),
              usoContinuo: false,
              tipoAgendamento: 'horariosFixos',
              criadoEm: agora,
              atualizadoEm: agora,
            ),
          );
      await db
          .into(db.horariosTratamento)
          .insert(
            HorariosTratamentoCompanion.insert(
              id: 'longo-9',
              tratamentoId: 'tratamento-longo',
              hora: 9,
              minuto: 0,
              ordem: 0,
            ),
          );

      final resultado = await PlanejadorNotificacoes(
        agendaRepository,
        maximoAgendamentos: 3,
      ).planejarComDiagnostico(agora: agora);

      expect(resultado.truncado, isTrue);
      expect(resultado.agendamentos, hasLength(3));
      expect(resultado.agendamentos.map((item) => item.dataHoraLocal), [
        DateTime(2026, 8, 18, 9),
        DateTime(2026, 8, 19, 9),
        DateTime(2026, 8, 20, 9),
      ]);
    },
  );

  test('detecta colisao antes de produzir o mapa de agendamentos', () async {
    final planejador = PlanejadorNotificacoes(
      agendaRepository,
      gerarIdentificador: (_) => 42,
    );

    expect(
      () => planejador.planejar(agora: DateTime(2026, 8, 18, 7)),
      throwsA(isA<ColisaoIdentificadorNotificacao>()),
    );
  });

  test('limite seguro trunca sem derrubar todo o planejamento', () async {
    final planejador = PlanejadorNotificacoes(
      agendaRepository,
      maximoAgendamentos: 1,
    );

    final resultado = await planejador.planejarComDiagnostico(
      agora: DateTime(2026, 8, 18, 7),
    );

    expect(resultado.agendamentos, hasLength(1));
    expect(resultado.truncado, isTrue);
  });

  test('reconciliacao e idempotente e recria conteudo divergente', () async {
    final fake = FakeNotificacoesLocais();
    final reconciliador = ReconciliadorNotificacoes(fake);
    final esperados = await PlanejadorNotificacoes(
      agendaRepository,
    ).planejar(agora: DateTime(2026, 8, 18, 7));

    final primeira = await reconciliador.reconciliar(esperados);
    final segunda = await reconciliador.reconciliar(esperados);

    expect(primeira.agendadas, 2);
    expect(segunda.mantidas, 2);
    expect(segunda.agendadas, 0);

    final divergente = esperados.first;
    fake.agendamentos.remove(divergente.id);
    fake.pendentesExternos.add(
      NotificacaoPendente(
        id: divergente.id,
        titulo: divergente.titulo,
        corpo: 'conteudo antigo',
        payload: divergente.payloadCodificado,
      ),
    );

    final reparo = await reconciliador.reconciliar(esperados);

    expect(reparo.canceladas, 1);
    expect(reparo.agendadas, 1);
    expect(fake.agendamentos[divergente.id]?.corpo, divergente.corpo);
  });
}
