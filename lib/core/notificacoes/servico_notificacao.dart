import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../features/configuracoes/dados/configuracao_repository.dart';
import '../../features/doses/dados/dose_repository.dart';
import '../../features/hoje/dados/agenda_repository.dart';
import '../../features/hoje/dominio/dose_prevista.dart';
import '../banco/app_database.dart';
import '../data_hora/relogio.dart';
import 'callback_notificacao.dart';
import 'flutter_notificacoes_locais.dart';
import 'fuso_horario_notificacoes.dart';
import 'modelos_notificacao.dart';
import 'payload_notificacao.dart';
import 'planejador_notificacoes.dart';
import 'porta_notificacoes_locais.dart';
import 'processador_acoes_notificacao.dart';
import 'reconciliador_notificacoes.dart';

/// Fachada Android para inicializacao, diagnostico e reconciliacao dos
/// lembretes. Deve ser chamada na abertura e novamente quando o app retomar.
final class ServicoNotificacao {
  ServicoNotificacao({
    required AppDatabase banco,
    AgendaRepository? agendaRepository,
    DoseRepository? doseRepository,
    ConfiguracaoRepository? configuracaoRepository,
    PortaNotificacoesLocais? notificacoes,
    FusoHorarioNotificacoes? fusoHorario,
    DateTime Function()? agora,
    this.diasNoHorizonte = 7,
  }) : _banco = banco,
       _agendaRepository = agendaRepository ?? AgendaRepository(banco),
       _doseRepository = doseRepository ?? DoseRepository(banco),
       _configuracoes = configuracaoRepository ?? ConfiguracaoRepository(banco),
       _notificacoes = notificacoes ?? FlutterNotificacoesLocais(),
       _fusoHorario = fusoHorario ?? FusoHorarioNotificacoes(),
       _agora = agora ?? const RelogioSistema().agora;

  final AppDatabase _banco;
  final AgendaRepository _agendaRepository;
  final DoseRepository _doseRepository;
  final ConfiguracaoRepository _configuracoes;
  final PortaNotificacoesLocais _notificacoes;
  final FusoHorarioNotificacoes _fusoHorario;
  final DateTime Function() _agora;
  final int diasNoHorizonte;

  bool _pluginInicializado = false;
  bool _fusoInicializado = false;

  late final PlanejadorNotificacoes _planejador = PlanejadorNotificacoes(
    _agendaRepository,
    diasNoHorizonte: diasNoHorizonte,
  );
  late final ReconciliadorNotificacoes _reconciliador =
      ReconciliadorNotificacoes(_notificacoes);
  late final ProcessadorAcoesNotificacao _processador =
      ProcessadorAcoesNotificacao(
        _banco,
        _doseRepository,
        _notificacoes,
        agora: _agora,
      );

  Future<ResultadoInicializacaoNotificacoes> inicializar() async {
    final resultadoFuso = await _fusoHorario.inicializar(
      configuracoes: _configuracoes,
    );
    _fusoInicializado = true;

    if (!_pluginInicializado) {
      await _notificacoes.inicializar(
        aoResponder: _aoResponder,
        aoResponderEmBackground: respostaNotificacaoEmBackground,
      );
      _pluginInicializado = true;
    }
    await _notificacoes.criarCanal();

    final saude = await verificarSaude();
    ResultadoReconciliacaoNotificacoes? reconciliacao;
    if (saude.alarmesExatosHabilitados) {
      reconciliacao = await reconciliar();
    }
    return ResultadoInicializacaoNotificacoes(
      saude: saude,
      fusoHorarioMudou: resultadoFuso.mudou,
      reconciliacao: reconciliacao,
    );
  }

  /// Revalida o fuso e renova o horizonte. O payload inclui o fuso e, quando
  /// ele muda, a comparacao da reconciliacao recria todos os alarmes futuros.
  Future<ResultadoInicializacaoNotificacoes> aoRetomar() => inicializar();

  Future<ResultadoReconciliacaoNotificacoes> reconciliar({
    DateTime? agora,
  }) async {
    await _garantirFusoInicializado();
    final planejamento = await _planejarTodos(agora ?? _agora());
    return _reconciliador.reconciliar(planejamento.agendamentos);
  }

  Future<SaudeNotificacoes> verificarSaude({DateTime? agora}) async {
    await _garantirFusoInicializado();
    final instante = agora ?? _agora();
    final estados = await Future.wait<bool>([
      _notificacoes.notificacoesHabilitadas(),
      _notificacoes.alarmesExatosHabilitados(),
      _notificacoes.canalHabilitado(),
    ]);
    final planejamento = await _planejarTodos(instante);
    final proximo = planejamento.agendamentos.isEmpty
        ? null
        : ProximoLembrete(
            dataHoraLocal: planejamento.agendamentos.first.dataHoraLocal,
            titulo: planejamento.agendamentos.first.titulo,
            corpo: planejamento.agendamentos.first.corpo,
          );
    return SaudeNotificacoes(
      notificacoesHabilitadas: estados[0],
      alarmesExatosHabilitados: estados[1],
      canalHabilitado: estados[2],
      proximoLembrete: proximo,
      agendaTruncada: planejamento.truncado,
      coberturaPlanejadaAte: planejamento.coberturaPlanejadaAte,
    );
  }

  Future<bool> solicitarPermissaoNotificacoes() async {
    await _notificacoes.solicitarPermissaoNotificacoes();
    return _notificacoes.notificacoesHabilitadas();
  }

  Future<bool> solicitarPermissaoAlarmesExatos() async {
    await _notificacoes.solicitarPermissaoAlarmesExatos();
    final habilitados = await _notificacoes.alarmesExatosHabilitados();
    if (habilitados) {
      await reconciliar();
    }
    return habilitados;
  }

  Future<bool> abrirConfiguracoes() => _notificacoes.abrirConfiguracoes();

  /// Remove alarmes pendentes e notificacoes exibidas antes de uma restauracao.
  /// Uma chamada posterior a [reconciliar] recria apenas o estado restaurado.
  Future<void> cancelarTodosAgendamentos() async {
    await _notificacoes.cancelarTodas();
  }

  void _aoResponder(NotificationResponse resposta) {
    unawaited(_processarRespostaSegura(resposta));
  }

  Future<void> _processarRespostaSegura(NotificationResponse resposta) async {
    try {
      await _processador.processar(resposta);
    } on Object catch (erro, stackTrace) {
      developer.log(
        'Falha ao processar uma resposta de notificacao.',
        name: 'minha_medicacao.notificacoes',
        error: erro,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _garantirFusoInicializado() async {
    if (_fusoInicializado) return;
    await _fusoHorario.inicializar(configuracoes: _configuracoes);
    _fusoInicializado = true;
  }

  Future<_ResultadoPlanejamentoCompleto> _planejarTodos(DateTime agora) async {
    final adiamentos = await _planejarAdiamentos(agora);
    final adiamentosOrdenados = adiamentos.agendamentos.toList()
      ..sort((a, b) => a.dataHoraLocal.compareTo(b.dataHoraLocal));
    final adiamentosMantidos = adiamentosOrdenados
        .take(limiteSeguroAgendamentosAndroid)
        .toList(growable: false);
    final adiamentosTruncados =
        adiamentosOrdenados.length > adiamentosMantidos.length;
    final planejamento = await _planejador.planejarComDiagnostico(
      agora: agora,
      dosesSuprimidas: adiamentos.dosesSuprimidas,
      limiteAgendamentos:
          limiteSeguroAgendamentosAndroid - adiamentosMantidos.length,
    );
    final esperados = <AgendamentoNotificacao>[
      ...planejamento.agendamentos,
      ...adiamentosMantidos,
    ];
    esperados.sort((a, b) => a.dataHoraLocal.compareTo(b.dataHoraLocal));
    final coberturaAdiamentos =
        adiamentosTruncados && adiamentosMantidos.isNotEmpty
        ? adiamentosMantidos.last.dataHoraLocal
        : null;
    return _ResultadoPlanejamentoCompleto(
      agendamentos: List.unmodifiable(esperados),
      truncado: planejamento.truncado || adiamentosTruncados,
      coberturaPlanejadaAte:
          planejamento.coberturaPlanejadaAte ?? coberturaAdiamentos,
    );
  }

  Future<_ResultadoPlanejamentoAdiamentos> _planejarAdiamentos(
    DateTime agora,
  ) async {
    final registros = await _banco.select(_banco.adiamentosDose).get();
    final esperados = <AgendamentoNotificacao>[];
    final dosesSuprimidas = <String>{};
    final remover = <String>[];

    for (final adiamento in registros) {
      final agenda = await _agendaRepository.obterDia(
        adiamento.dataHoraProgramada.toLocal(),
        agora: agora,
      );
      DoseComEstado? item;
      for (final candidato in agenda.doses) {
        if (candidato.dose.doseKey == adiamento.doseKey) {
          item = candidato;
          break;
        }
      }
      if (item == null ||
          item.status == StatusDose.tomada ||
          item.status == StatusDose.naoTomada) {
        remover.add(adiamento.doseKey);
        continue;
      }
      if (!adiamento.lembrarEm.isAfter(agora)) {
        // Se o adiamento tocou antes do horario original, a supressao precisa
        // sobreviver ate essa ocorrencia passar; do contrario a reconciliacao
        // recriaria o alarme base da mesma dose.
        if (adiamento.dataHoraProgramada.isAfter(agora)) {
          dosesSuprimidas.add(adiamento.doseKey);
        } else {
          remover.add(adiamento.doseKey);
        }
        continue;
      }

      dosesSuprimidas.add(adiamento.doseKey);

      final id = _planejador.idDoAdiamento(adiamento.doseKey);
      if (adiamento.notificacaoId != id) {
        await (_banco.update(_banco.adiamentosDose)
              ..where((tabela) => tabela.doseKey.equals(adiamento.doseKey)))
            .write(AdiamentosDoseCompanion(notificacaoId: Value(id)));
      }
      final conteudo = PlanejadorNotificacoes.conteudoDeDose(item);
      esperados.add(
        AgendamentoNotificacao(
          id: id,
          dataHoraLocal: adiamento.lembrarEm,
          payload: PayloadNotificacao(
            tipo: TipoPayloadNotificacao.adiamento,
            doseKey: item.dose.doseKey,
            tratamentoId: item.dose.tratamentoId,
            medicamentoId: item.dose.medicamentoId,
            regraId: item.dose.regraId,
            dataHoraProgramadaUtc: item.dose.dataHoraProgramada.toUtc(),
            fusoHorario: tz.local.name,
            titulo: conteudo.$1,
            corpo: conteudo.$2,
            lembrarEmUtc: adiamento.lembrarEm.toUtc(),
          ),
        ),
      );
    }

    for (final doseKey in remover) {
      await (_banco.delete(
        _banco.adiamentosDose,
      )..where((tabela) => tabela.doseKey.equals(doseKey))).go();
    }
    return _ResultadoPlanejamentoAdiamentos(
      agendamentos: List.unmodifiable(esperados),
      dosesSuprimidas: Set.unmodifiable(dosesSuprimidas),
    );
  }
}

final class _ResultadoPlanejamentoAdiamentos {
  const _ResultadoPlanejamentoAdiamentos({
    required this.agendamentos,
    required this.dosesSuprimidas,
  });

  final List<AgendamentoNotificacao> agendamentos;
  final Set<String> dosesSuprimidas;
}

final class _ResultadoPlanejamentoCompleto {
  const _ResultadoPlanejamentoCompleto({
    required this.agendamentos,
    required this.truncado,
    this.coberturaPlanejadaAte,
  });

  final List<AgendamentoNotificacao> agendamentos;
  final bool truncado;
  final DateTime? coberturaPlanejadaAte;
}
