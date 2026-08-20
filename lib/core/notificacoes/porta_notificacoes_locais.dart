import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'modelos_notificacao.dart';

abstract interface class PortaNotificacoesLocais {
  Future<void> inicializar({
    required DidReceiveNotificationResponseCallback aoResponder,
    required DidReceiveBackgroundNotificationResponseCallback
    aoResponderEmBackground,
  });

  Future<void> criarCanal();

  /// Agenda um lembrete.
  ///
  /// Com [exato] falso o Android pode atrasar a entrega em alguns
  /// minutos, mas o lembrete continua chegando — o que é preferível a
  /// não avisar quando a permissão de alarme exato não está concedida.
  Future<void> agendar(
    AgendamentoNotificacao agendamento, {
    required bool exato,
  });

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
