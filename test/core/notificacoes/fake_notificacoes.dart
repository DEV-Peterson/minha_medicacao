import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minha_medicacao/core/notificacoes/modelos_notificacao.dart';
import 'package:minha_medicacao/core/notificacoes/porta_notificacoes_locais.dart';

final class FakeNotificacoesLocais implements PortaNotificacoesLocais {
  bool notificacoesAtivas = true;
  bool alarmesExatosAtivos = true;
  bool canalAtivo = true;
  bool foiInicializada = false;
  bool canalFoiCriado = false;
  bool cancelouTodas = false;

  final Map<int, AgendamentoNotificacao> agendamentos = {};

  /// Precisão com que cada alarme foi agendado.
  final Map<int, bool> precisoes = {};
  final List<int> cancelamentos = [];
  final List<NotificacaoPendente> pendentesExternos = [];

  @override
  Future<void> inicializar({
    required DidReceiveNotificationResponseCallback aoResponder,
    required DidReceiveBackgroundNotificationResponseCallback
    aoResponderEmBackground,
  }) async {
    foiInicializada = true;
  }

  @override
  Future<void> criarCanal() async {
    canalFoiCriado = true;
  }

  @override
  Future<void> agendar(
    AgendamentoNotificacao agendamento, {
    required bool exato,
  }) async {
    agendamentos[agendamento.id] = agendamento;
    precisoes[agendamento.id] = exato;
  }

  @override
  Future<void> cancelar(int id) async {
    cancelamentos.add(id);
    agendamentos.remove(id);
    pendentesExternos.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> cancelarTodas() async {
    cancelouTodas = true;
    agendamentos.clear();
    pendentesExternos.clear();
  }

  @override
  Future<List<NotificacaoPendente>> listarPendentes() async => [
    ...pendentesExternos,
    ...agendamentos.values.map(
      (item) => NotificacaoPendente(
        id: item.id,
        titulo: item.titulo,
        corpo: item.corpo,
        payload: item.payloadCodificado,
      ),
    ),
  ];

  @override
  Future<bool> notificacoesHabilitadas() async => notificacoesAtivas;

  @override
  Future<bool> alarmesExatosHabilitados() async => alarmesExatosAtivos;

  @override
  Future<bool> canalHabilitado() async => canalAtivo;

  @override
  Future<bool> solicitarPermissaoNotificacoes() async => notificacoesAtivas;

  @override
  Future<bool> solicitarPermissaoAlarmesExatos() async => alarmesExatosAtivos;

  @override
  Future<bool> abrirConfiguracoes() async => true;
}
