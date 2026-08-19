import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'modelos_notificacao.dart';

abstract interface class PortaNotificacoesLocais {
  Future<void> inicializar({
    required DidReceiveNotificationResponseCallback aoResponder,
    required DidReceiveBackgroundNotificationResponseCallback
    aoResponderEmBackground,
  });

  Future<void> criarCanal();

  Future<void> agendar(AgendamentoNotificacao agendamento);

  Future<void> cancelar(int id);

  /// Remove alarmes pendentes e notificacoes atualmente exibidas pelo app.
  Future<void> cancelarTodas();

  Future<List<NotificacaoPendente>> listarPendentes();

  Future<bool> notificacoesHabilitadas();

  Future<bool> alarmesExatosHabilitados();

  Future<bool> canalHabilitado();

  Future<bool> solicitarPermissaoNotificacoes();

  Future<bool> solicitarPermissaoAlarmesExatos();

  Future<bool> abrirConfiguracoes();
}
