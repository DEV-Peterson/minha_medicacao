import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/notificacoes/flutter_notificacoes_locais.dart';
import 'package:minha_medicacao/core/notificacoes/identificador_notificacao.dart';
import 'package:minha_medicacao/core/notificacoes/planejador_notificacoes.dart';
import 'package:minha_medicacao/core/notificacoes/processador_acoes_notificacao.dart';
import 'package:minha_medicacao/features/doses/dados/dose_repository.dart';
import 'package:minha_medicacao/features/hoje/dados/agenda_repository.dart';
import 'package:timezone/data/latest_all.dart' as dados_tz;
import 'package:timezone/timezone.dart' as tz;

import '../banco/banco_teste.dart';
import 'fake_notificacoes.dart';

void main() {
  late AppDatabase db;
  late AgendaRepository agendaRepository;
  late FakeNotificacoesLocais notificacoes;
  late DateTime agora;

  setUpAll(() {
    dados_tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  });

  setUp(() async {
    db = criarBancoEmMemoria();
    agendaRepository = AgendaRepository(db);
    notificacoes = FakeNotificacoesLocais();
    agora = DateTime(2026, 8, 18, 8, 5);
    await inserirMedicamentoTeste(
      db,
      controleEstoque: true,
      unidadeEstoque: 'comprimido',
    );
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
  });

  tearDown(() => db.close());

  Future<
    ({
      ProcessadorAcoesNotificacao processador,
      NotificationResponse resposta,
      int idRecorrencia,
    })
  >
  preparar(String acao) async {
    final recorrencia = (await PlanejadorNotificacoes(
      agendaRepository,
    ).planejar(agora: agora)).single;
    final processador = ProcessadorAcoesNotificacao(
      db,
      DoseRepository(db),
      notificacoes,
      agendaRepository: agendaRepository,
      agora: () => agora,
    );
    return (
      processador: processador,
      resposta: NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        id: recorrencia.id,
        actionId: acao,
        payload: recorrencia.payloadCodificado,
      ),
      idRecorrencia: recorrencia.id,
    );
  }

  test('Tomei repetido confirma uma vez e nao cancela a recorrencia', () async {
    final cenario = await preparar(FlutterNotificacoesLocais.acaoTomei);

    await cenario.processador.processar(cenario.resposta);
    await cenario.processador.processar(cenario.resposta);

    final registros = await db.select(db.registrosDose).get();
    final movimentacoes = await db.select(db.movimentacoesEstoque).get();
    expect(registros, hasLength(1));
    expect(registros.single.status, 'tomada');
    expect(movimentacoes, hasLength(1));
    expect(notificacoes.cancelamentos, isNot(contains(cenario.idRecorrencia)));
  });

  test('Nao tomei repetido persiste um unico registro sem estoque', () async {
    final cenario = await preparar(FlutterNotificacoesLocais.acaoNaoTomei);

    await cenario.processador.processar(cenario.resposta);
    await cenario.processador.processar(cenario.resposta);

    final registros = await db.select(db.registrosDose).get();
    final movimentacoes = await db.select(db.movimentacoesEstoque).get();
    expect(registros, hasLength(1));
    expect(registros.single.status, 'naoTomada');
    expect(movimentacoes, isEmpty);
    expect(notificacoes.cancelamentos, isNot(contains(cenario.idRecorrencia)));
  });

  test(
    'Adiar repetido reutiliza registro e ID e confirmacao o remove',
    () async {
      final cenario = await preparar(FlutterNotificacoesLocais.acaoAdiar);

      await cenario.processador.processar(cenario.resposta);
      await cenario.processador.processar(cenario.resposta);

      final adiamentos = await db.select(db.adiamentosDose).get();
      final idAdiamento = IdentificadorNotificacao.paraChave(
        PlanejadorNotificacoes.chaveDoAdiamento(adiamentos.single.doseKey),
      );
      expect(adiamentos, hasLength(1));
      expect(
        adiamentos.single.lembrarEm,
        agora.add(const Duration(minutes: 10)),
      );
      expect(adiamentos.single.notificacaoId, idAdiamento);
      expect(notificacoes.agendamentos.keys, [idAdiamento]);
      expect(
        notificacoes.cancelamentos,
        isNot(contains(cenario.idRecorrencia)),
      );

      final confirmar = await preparar(FlutterNotificacoesLocais.acaoTomei);
      await confirmar.processador.processar(confirmar.resposta);

      expect(await db.select(db.adiamentosDose).get(), isEmpty);
      expect(notificacoes.cancelamentos, contains(idAdiamento));
    },
  );

  test(
    'acao de intervalo recorrente resolve somente o slot que tocou',
    () async {
      agora = DateTime(2026, 8, 18, 15);
      await (db.update(
        db.tratamentos,
      )..where((tabela) => tabela.id.equals('tratamento-1'))).write(
        TratamentosCompanion(
          tipoAgendamento: const Value('intervalo'),
          dataHoraAncora: Value(DateTime(2026, 8, 18, 6)),
          intervaloMinutos: const Value(8 * 60),
        ),
      );
      final recorrencias = await PlanejadorNotificacoes(
        agendaRepository,
      ).planejar(agora: agora);
      final slotDasSeis = recorrencias.singleWhere(
        (item) => item.payload.horaRecorrencia == 6,
      );
      final processador = ProcessadorAcoesNotificacao(
        db,
        DoseRepository(db),
        notificacoes,
        agendaRepository: agendaRepository,
        agora: () => agora,
      );

      await processador.processar(
        NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          id: slotDasSeis.id,
          actionId: FlutterNotificacoesLocais.acaoTomei,
          payload: slotDasSeis.payloadCodificado,
        ),
      );

      final registro = await db.select(db.registrosDose).getSingle();
      expect(registro.dataHoraProgramada, DateTime(2026, 8, 18, 6));
    },
  );
}
