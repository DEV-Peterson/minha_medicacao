import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/doses/dados/dose_repository.dart';
import '../../features/hoje/dados/agenda_repository.dart';
import '../banco/app_database.dart';
import '../data_hora/data_hora_local.dart';
import '../data_hora/relogio.dart';
import 'flutter_notificacoes_locais.dart';
import 'identificador_notificacao.dart';
import 'modelos_notificacao.dart';
import 'payload_notificacao.dart';
import 'planejador_notificacoes.dart';
import 'porta_notificacoes_locais.dart';

enum ResultadoProcessamentoAcaoNotificacao {
  ignorada,
  payloadInvalido,
  respostaInconsistente,
  doseJaRegistrada,
  tomadaRegistrada,
  adiamentoRegistrado,
  naoTomadaRegistrada,
}

final class ProcessadorAcoesNotificacao {
  ProcessadorAcoesNotificacao(
    this._banco,
    this._doseRepository,
    this._notificacoes, {
    AgendaRepository? agendaRepository,
    this.duracaoAdiamento = const Duration(minutes: 10),
    DateTime Function()? agora,
  }) : _agora = agora ?? const RelogioSistema().agora {
    _agendaRepository = agendaRepository ?? AgendaRepository(_banco);
    if (duracaoAdiamento <= Duration.zero) {
      throw ArgumentError.value(
        duracaoAdiamento,
        'duracaoAdiamento',
        'A duracao deve ser positiva.',
      );
    }
  }

  final AppDatabase _banco;
  final DoseRepository _doseRepository;
  final PortaNotificacoesLocais _notificacoes;
  late final AgendaRepository _agendaRepository;
  final Duration duracaoAdiamento;
  final DateTime Function() _agora;

  Future<ResultadoProcessamentoAcaoNotificacao> processar(
    NotificationResponse resposta,
  ) async {
    final acao = resposta.actionId;
    if (resposta.notificationResponseType !=
            NotificationResponseType.selectedNotificationAction ||
        acao == null ||
        acao.isEmpty) {
      return ResultadoProcessamentoAcaoNotificacao.ignorada;
    }

    final payload = PayloadNotificacao.tentarDecodificar(resposta.payload);
    if (payload == null) {
      return ResultadoProcessamentoAcaoNotificacao.payloadInvalido;
    }

    final idEsperado = switch (payload.tipo) {
      TipoPayloadNotificacao.dose => _idDaDose(payload.doseKey),
      TipoPayloadNotificacao.adiamento => _idDoAdiamento(payload.doseKey),
      TipoPayloadNotificacao.recorrenciaDiaria => _idDaRecorrencia(
        payload.tratamentoId,
        payload.regraId,
        hora: payload.horaRecorrencia!,
        minuto: payload.minutoRecorrencia!,
        segundo: payload.segundoRecorrencia!,
      ),
    };
    if (resposta.id != null && resposta.id != idEsperado) {
      return ResultadoProcessamentoAcaoNotificacao.respostaInconsistente;
    }

    final agora = _agora();
    final payloadConcreto =
        payload.tipo == TipoPayloadNotificacao.recorrenciaDiaria
        ? await _resolverRecorrenciaDiaria(payload, agora)
        : payload;
    if (payloadConcreto == null) {
      return ResultadoProcessamentoAcaoNotificacao.respostaInconsistente;
    }
    return switch (acao) {
      FlutterNotificacoesLocais.acaoTomei => _confirmar(
        payload: payloadConcreto,
        agora: agora,
      ),
      FlutterNotificacoesLocais.acaoAdiar => _adiar(
        payload: payloadConcreto,
        agora: agora,
      ),
      FlutterNotificacoesLocais.acaoNaoTomei => _registrarNaoTomada(
        payload: payloadConcreto,
        agora: agora,
      ),
      _ => Future.value(ResultadoProcessamentoAcaoNotificacao.ignorada),
    };
  }

  Future<ResultadoProcessamentoAcaoNotificacao> _confirmar({
    required PayloadNotificacao payload,
    required DateTime agora,
  }) async {
    await _doseRepository.confirmar(
      doseKey: payload.doseKey,
      tratamentoId: payload.tratamentoId,
      dataHoraProgramada: payload.dataHoraProgramadaUtc,
      dataHoraAcao: agora,
    );
    await _notificacoes.cancelar(_idDoAdiamento(payload.doseKey));
    return ResultadoProcessamentoAcaoNotificacao.tomadaRegistrada;
  }

  Future<ResultadoProcessamentoAcaoNotificacao> _registrarNaoTomada({
    required PayloadNotificacao payload,
    required DateTime agora,
  }) async {
    await _doseRepository.registrarNaoTomada(
      doseKey: payload.doseKey,
      tratamentoId: payload.tratamentoId,
      dataHoraProgramada: payload.dataHoraProgramadaUtc,
      dataHoraAcao: agora,
    );
    await _notificacoes.cancelar(_idDoAdiamento(payload.doseKey));
    return ResultadoProcessamentoAcaoNotificacao.naoTomadaRegistrada;
  }

  Future<ResultadoProcessamentoAcaoNotificacao> _adiar({
    required PayloadNotificacao payload,
    required DateTime agora,
  }) async {
    final decisao = await _banco.transaction(() async {
      final registro =
          await (_banco.select(_banco.registrosDose)
                ..where((tabela) => tabela.doseKey.equals(payload.doseKey)))
              .getSingleOrNull();
      if (registro != null) {
        return const _DecisaoAdiamento.doseRegistrada();
      }

      final existente =
          await (_banco.select(_banco.adiamentosDose)
                ..where((tabela) => tabela.doseKey.equals(payload.doseKey)))
              .getSingleOrNull();
      if (existente != null && existente.lembrarEm.isAfter(agora)) {
        return _DecisaoAdiamento.agendar(existente);
      }

      final id = _idDoAdiamento(payload.doseKey);
      final adiamento = await _doseRepository.adiar(
        doseKey: payload.doseKey,
        tratamentoId: payload.tratamentoId,
        medicamentoId: payload.medicamentoId,
        dataHoraProgramada: payload.dataHoraProgramadaUtc,
        lembrarEm: agora.add(duracaoAdiamento),
        notificacaoId: id,
        agora: agora,
      );
      return _DecisaoAdiamento.agendar(adiamento);
    });

    final adiamento = decisao.adiamento;
    if (adiamento == null) {
      await _notificacoes.cancelar(_idDoAdiamento(payload.doseKey));
      return ResultadoProcessamentoAcaoNotificacao.doseJaRegistrada;
    }

    final idAdiamento = _idDoAdiamento(payload.doseKey);
    final novoAgendamento = AgendamentoNotificacao(
      id: idAdiamento,
      dataHoraLocal: adiamento.lembrarEm,
      payload: payload.comoAdiamento(lembrarEm: adiamento.lembrarEm),
    );

    // A action nativa remove somente a notificacao visivel. Nao chamamos
    // cancel(id) no ID de origem, pois ele pode pertencer a uma recorrencia.
    final exato = await _notificacoes.alarmesExatosHabilitados();
    await _notificacoes.agendar(novoAgendamento, exato: exato);
    return ResultadoProcessamentoAcaoNotificacao.adiamentoRegistrado;
  }

  Future<PayloadNotificacao?> _resolverRecorrenciaDiaria(
    PayloadNotificacao recorrencia,
    DateTime agora,
  ) async {
    final hoje = DataHoraLocal.inicioDoDia(agora);
    final dias = <DateTime>[
      hoje,
      DataHoraLocal.adicionarDiasCalendario(hoje, -1),
    ];
    PayloadNotificacao? melhor;

    for (final dia in dias) {
      final agenda = await _agendaRepository.obterDia(dia, agora: agora);
      for (final item in agenda.doses) {
        final dose = item.dose;
        if (dose.tratamentoId != recorrencia.tratamentoId ||
            dose.regraId != recorrencia.regraId ||
            dose.dataHoraProgramada.hour != recorrencia.horaRecorrencia ||
            dose.dataHoraProgramada.minute != recorrencia.minutoRecorrencia ||
            dose.dataHoraProgramada.second != recorrencia.segundoRecorrencia ||
            dose.dataHoraProgramada.isAfter(agora)) {
          continue;
        }
        final candidato = PayloadNotificacao(
          tipo: TipoPayloadNotificacao.dose,
          doseKey: dose.doseKey,
          tratamentoId: dose.tratamentoId,
          medicamentoId: dose.medicamentoId,
          regraId: dose.regraId,
          dataHoraProgramadaUtc: dose.dataHoraProgramada.toUtc(),
          fusoHorario: recorrencia.fusoHorario,
          titulo: recorrencia.titulo,
          corpo: recorrencia.corpo,
        );
        if (melhor == null ||
            candidato.dataHoraProgramadaUtc.isAfter(
              melhor.dataHoraProgramadaUtc,
            )) {
          melhor = candidato;
        }
      }
    }
    return melhor;
  }

  static int _idDaDose(String doseKey) => IdentificadorNotificacao.paraChave(
    PlanejadorNotificacoes.chaveDaDose(doseKey),
  );

  static int _idDoAdiamento(String doseKey) =>
      IdentificadorNotificacao.paraChave(
        PlanejadorNotificacoes.chaveDoAdiamento(doseKey),
      );

  static int _idDaRecorrencia(
    String tratamentoId,
    String regraId, {
    required int hora,
    required int minuto,
    required int segundo,
  }) => IdentificadorNotificacao.paraChave(
    PlanejadorNotificacoes.chaveDaRecorrencia(
      tratamentoId,
      regraId,
      hora: hora,
      minuto: minuto,
      segundo: segundo,
    ),
  );
}

final class _DecisaoAdiamento {
  const _DecisaoAdiamento.agendar(this.adiamento);

  const _DecisaoAdiamento.doseRegistrada() : adiamento = null;

  final AdiamentoDoseDb? adiamento;
}
