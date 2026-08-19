import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'modelos_notificacao.dart';
import 'porta_notificacoes_locais.dart';

final class FlutterNotificacoesLocais implements PortaNotificacoesLocais {
  FlutterNotificacoesLocais({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String canalId = 'lembretes_medicacao_v1';
  static const String canalNome = 'Lembretes de medicamentos';
  static const String canalDescricao =
      'Avisos nos horários dos medicamentos cadastrados';
  static const String icone = 'ic_notification';

  static const String acaoTomei = 'tomei';
  static const String acaoAdiar = 'adiar';
  static const String acaoNaoTomei = 'nao_tomei';

  static const AndroidNotificationChannel _canal = AndroidNotificationChannel(
    canalId,
    canalNome,
    description: canalDescricao,
    importance: Importance.high,
  );

  static const NotificationDetails _detalhes = NotificationDetails(
    android: AndroidNotificationDetails(
      canalId,
      canalNome,
      channelDescription: canalDescricao,
      icon: icone,
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          acaoTomei,
          'Tomei',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          acaoAdiar,
          'Adiar 10 min',
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          acaoNaoTomei,
          'Não tomei',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> inicializar({
    required DidReceiveNotificationResponseCallback aoResponder,
    required DidReceiveBackgroundNotificationResponseCallback
    aoResponderEmBackground,
  }) async {
    final inicializada = await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(icone),
      ),
      onDidReceiveNotificationResponse: aoResponder,
      onDidReceiveBackgroundNotificationResponse: aoResponderEmBackground,
    );
    if (inicializada == false) {
      throw StateError('Nao foi possivel inicializar as notificacoes locais.');
    }
  }

  @override
  Future<void> criarCanal() async {
    await _android?.createNotificationChannel(_canal);
  }

  @override
  Future<void> agendar(AgendamentoNotificacao agendamento) async {
    final local = agendamento.dataHoraLocal.isUtc
        ? agendamento.dataHoraLocal.toLocal()
        : agendamento.dataHoraLocal;
    final dataTz = tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
    await _plugin.zonedSchedule(
      id: agendamento.id,
      title: agendamento.titulo,
      body: agendamento.corpo,
      scheduledDate: dataTz,
      notificationDetails: _detalhes,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: agendamento.payloadCodificado,
      matchDateTimeComponents: agendamento.recorrenciaDiaria
          ? DateTimeComponents.time
          : null,
    );
  }

  @override
  Future<void> cancelar(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelarTodas() => _plugin.cancelAll();

  @override
  Future<List<NotificacaoPendente>> listarPendentes() async {
    final pendentes = await _plugin.pendingNotificationRequests();
    return pendentes
        .map(
          (item) => NotificacaoPendente(
            id: item.id,
            titulo: item.title,
            corpo: item.body,
            payload: item.payload,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<bool> notificacoesHabilitadas() async =>
      await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<bool> alarmesExatosHabilitados() async =>
      await _android?.canScheduleExactNotifications() ?? false;

  @override
  Future<bool> canalHabilitado() async {
    final canais = await _android?.getNotificationChannels();
    if (canais == null || canais.isEmpty) {
      // Antes do Android 8 nao existem canais.
      return true;
    }
    for (final canal in canais) {
      if (canal.id == canalId) {
        return canal.importance != Importance.none;
      }
    }
    return false;
  }

  @override
  Future<bool> solicitarPermissaoNotificacoes() async =>
      await _android?.requestNotificationsPermission() ?? false;

  @override
  Future<bool> solicitarPermissaoAlarmesExatos() async =>
      await _android?.requestExactAlarmsPermission() ?? false;

  @override
  Future<bool> abrirConfiguracoes() async =>
      await _plugin.openAppNotificationSettings() ?? false;
}
