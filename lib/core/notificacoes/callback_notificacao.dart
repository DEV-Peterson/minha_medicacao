import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/doses/dados/dose_repository.dart';
import '../banco/app_database.dart';
import '../util/registro_falhas.dart';
import 'flutter_notificacoes_locais.dart';
import 'fuso_horario_notificacoes.dart';
import 'processador_acoes_notificacao.dart';

/// Ponto de entrada mantido pelo compilador para a FlutterEngine criada pelo
/// receiver de acoes do flutter_local_notifications.
@pragma('vm:entry-point')
void respostaNotificacaoEmBackground(NotificationResponse resposta) {
  unawaited(_processarRespostaEmBackground(resposta));
}

Future<void> _processarRespostaEmBackground(
  NotificationResponse resposta,
) async {
  final banco = AppDatabase();
  try {
    await FusoHorarioNotificacoes().inicializar();
    final notificacoes = FlutterNotificacoesLocais();
    await ProcessadorAcoesNotificacao(
      banco,
      DoseRepository(banco),
      notificacoes,
    ).processar(resposta);
  } on Object catch (erro, stackTrace) {
    registrarFalha('ação de notificação em background', erro, stackTrace);
  } finally {
    await banco.close();
  }
}
