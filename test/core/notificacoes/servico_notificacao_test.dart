import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/notificacoes/fuso_horario_notificacoes.dart';
import 'package:minha_medicacao/core/notificacoes/modelos_notificacao.dart';
import 'package:minha_medicacao/core/notificacoes/payload_notificacao.dart';
import 'package:minha_medicacao/core/notificacoes/servico_notificacao.dart';
import 'package:minha_medicacao/features/doses/dados/dose_repository.dart';
import 'package:minha_medicacao/features/hoje/dados/agenda_repository.dart';
import 'package:timezone/data/latest_all.dart' as dados_tz;
import 'package:timezone/timezone.dart' as tz;

import '../banco/banco_teste.dart';
import 'fake_notificacoes.dart';

void main() {
  late AppDatabase db;
  late FakeNotificacoesLocais notificacoes;

  setUpAll(() {
    dados_tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
  });

  setUp(() {
    db = criarBancoEmMemoria();
    notificacoes = FakeNotificacoesLocais();
  });

  tearDown(() => db.close());

  Future<void> inserirDoseDasOito() async {
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
  }

  test('cancelarTodosAgendamentos limpa pendentes e exibidas', () async {
    notificacoes.pendentesExternos.addAll(const [
      NotificacaoPendente(id: 10, titulo: null, corpo: null, payload: null),
      NotificacaoPendente(id: 10, titulo: null, corpo: null, payload: null),
      NotificacaoPendente(id: 20, titulo: null, corpo: null, payload: null),
    ]);
    final servico = ServicoNotificacao(
      banco: db,
      notificacoes: notificacoes,
      fusoHorario: FusoHorarioNotificacoes(
        obterIdentificador: () async => 'America/Sao_Paulo',
      ),
    );

    await servico.cancelarTodosAgendamentos();

    expect(notificacoes.cancelouTodas, isTrue);
    expect(notificacoes.pendentesExternos, isEmpty);
  });

  group('sem permissao de alarme exato', () {
    test('agenda mesmo assim, em modo inexato', () async {
      await inserirDoseDasOito();
      notificacoes.alarmesExatosAtivos = false;
      final servico = ServicoNotificacao(
        banco: db,
        notificacoes: notificacoes,
        fusoHorario: FusoHorarioNotificacoes(
          obterIdentificador: () async => 'America/Sao_Paulo',
        ),
        agora: () => DateTime(2026, 8, 18, 7),
      );

      final resultado = await servico.inicializar();

      // O app de lembrete nunca pode ficar mudo: sem alarme exato o aviso
      // ainda e agendado, apenas com precisao menor.
      expect(resultado.saude.alarmesExatosHabilitados, isFalse);
      expect(resultado.reconciliacao?.agendadas, 1);
      expect(notificacoes.agendamentos, hasLength(1));
      expect(notificacoes.precisoes.values.single, isFalse);
    });

    test('conceder a permissao recria os alarmes em modo exato', () async {
      await inserirDoseDasOito();
      notificacoes.alarmesExatosAtivos = false;
      final servico = ServicoNotificacao(
        banco: db,
        notificacoes: notificacoes,
        fusoHorario: FusoHorarioNotificacoes(
          obterIdentificador: () async => 'America/Sao_Paulo',
        ),
        agora: () => DateTime(2026, 8, 18, 7),
      );
      await servico.inicializar();
      expect(notificacoes.precisoes.values.single, isFalse);

      notificacoes.alarmesExatosAtivos = true;
      notificacoes.cancelouTodas = false;
      await servico.reconciliar(agora: DateTime(2026, 8, 18, 7));

      // Um alarme pendente guarda a precisao com que nasceu, entao a troca
      // exige descartar os antigos.
      expect(notificacoes.cancelouTodas, isTrue);
      expect(notificacoes.precisoes.values.single, isTrue);
    });

    test('precisao estavel nao descarta os alarmes pendentes', () async {
      await inserirDoseDasOito();
      final servico = ServicoNotificacao(
        banco: db,
        notificacoes: notificacoes,
        fusoHorario: FusoHorarioNotificacoes(
          obterIdentificador: () async => 'America/Sao_Paulo',
        ),
        agora: () => DateTime(2026, 8, 18, 7),
      );
      await servico.inicializar();
      notificacoes.cancelouTodas = false;

      await servico.reconciliar(agora: DateTime(2026, 8, 18, 7));

      expect(notificacoes.cancelouTodas, isFalse);
      expect(notificacoes.precisoes.values.single, isTrue);
    });
  });

  test('inicializa fuso, canal, diagnostico e reconciliacao', () async {
    await inserirDoseDasOito();
    final servico = ServicoNotificacao(
      banco: db,
      notificacoes: notificacoes,
      fusoHorario: FusoHorarioNotificacoes(
        obterIdentificador: () async => 'America/Sao_Paulo',
      ),
      agora: () => DateTime(2026, 8, 18, 7),
    );

    final resultado = await servico.inicializar();

    expect(notificacoes.foiInicializada, isTrue);
    expect(notificacoes.canalFoiCriado, isTrue);
    expect(resultado.saude.totalmenteHabilitadas, isTrue);
    expect(
      resultado.saude.proximoLembrete?.dataHoraLocal,
      DateTime(2026, 8, 18, 8),
    );
    expect(resultado.reconciliacao?.agendadas, 1);
    expect(notificacoes.agendamentos.values.single.recorrenciaDiaria, isTrue);
  });

  test('adiamento antes do horario suprime apenas a ocorrencia base', () async {
    await inserirDoseDasOito();
    var instante = DateTime(2026, 8, 18, 7);
    final agendaRepository = AgendaRepository(db);
    final dose = (await agendaRepository.obterDia(
      instante,
      agora: instante,
    )).doses.single.dose;
    await DoseRepository(db).adiar(
      doseKey: dose.doseKey,
      tratamentoId: dose.tratamentoId,
      medicamentoId: dose.medicamentoId,
      dataHoraProgramada: dose.dataHoraProgramada,
      lembrarEm: DateTime(2026, 8, 18, 7, 10),
      notificacaoId: 123,
      agora: instante,
    );
    final servico = ServicoNotificacao(
      banco: db,
      agendaRepository: agendaRepository,
      notificacoes: notificacoes,
      fusoHorario: FusoHorarioNotificacoes(
        obterIdentificador: () async => 'America/Sao_Paulo',
      ),
      agora: () => instante,
    );

    await servico.reconciliar(agora: instante);

    final agendados = notificacoes.agendamentos.values.toList();
    final adiamento = agendados.singleWhere(
      (item) => item.payload.tipo == TipoPayloadNotificacao.adiamento,
    );
    final recorrencia = agendados.singleWhere(
      (item) => item.payload.tipo == TipoPayloadNotificacao.recorrenciaDiaria,
    );
    expect(adiamento.dataHoraLocal, DateTime(2026, 8, 18, 7, 10));
    expect(recorrencia.dataHoraLocal, DateTime(2026, 8, 19, 8));

    // Mesmo depois de o snooze tocar, a dose-base segue suprimida ate seu
    // horario original passar.
    instante = DateTime(2026, 8, 18, 7, 20);
    await servico.reconciliar(agora: instante);
    expect(
      notificacoes.agendamentos.values.where(
        (item) => item.payload.tipo == TipoPayloadNotificacao.adiamento,
      ),
      isEmpty,
    );
    expect(
      notificacoes.agendamentos.values
          .singleWhere(
            (item) =>
                item.payload.tipo == TipoPayloadNotificacao.recorrenciaDiaria,
          )
          .dataHoraLocal,
      DateTime(2026, 8, 19, 8),
    );
    expect(await db.select(db.adiamentosDose).get(), hasLength(1));
  });

  test('trocar 10 por 30 minutos recria o alarme de adiamento', () async {
    await inserirDoseDasOito();
    final instante = DateTime(2026, 8, 18, 7);
    final agendaRepository = AgendaRepository(db);
    final dose = (await agendaRepository.obterDia(
      instante,
      agora: instante,
    )).doses.single.dose;
    final repositorio = DoseRepository(db);
    final servico = ServicoNotificacao(
      banco: db,
      agendaRepository: agendaRepository,
      notificacoes: notificacoes,
      fusoHorario: FusoHorarioNotificacoes(
        obterIdentificador: () async => 'America/Sao_Paulo',
      ),
      agora: () => instante,
    );

    Future<void> adiarAte(DateTime lembrarEm) => repositorio.adiar(
      doseKey: dose.doseKey,
      tratamentoId: dose.tratamentoId,
      medicamentoId: dose.medicamentoId,
      dataHoraProgramada: dose.dataHoraProgramada,
      lembrarEm: lembrarEm,
      notificacaoId: lembrarEm.minute,
      agora: instante,
    );

    await adiarAte(DateTime(2026, 8, 18, 7, 10));
    await servico.reconciliar(agora: instante);
    final primeiro = notificacoes.agendamentos.values.singleWhere(
      (item) => item.payload.tipo == TipoPayloadNotificacao.adiamento,
    );

    await adiarAte(DateTime(2026, 8, 18, 7, 30));
    await servico.reconciliar(agora: instante);
    final atualizado = notificacoes.agendamentos.values.singleWhere(
      (item) => item.payload.tipo == TipoPayloadNotificacao.adiamento,
    );

    expect(atualizado.id, primeiro.id);
    expect(notificacoes.cancelamentos, contains(primeiro.id));
    expect(atualizado.dataHoraLocal, DateTime(2026, 8, 18, 7, 30));
    expect(
      atualizado.payload.lembrarEmUtc,
      DateTime(2026, 8, 18, 7, 30).toUtc(),
    );
  });
}
