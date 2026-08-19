import 'payload_notificacao.dart';

/// Reserva margem abaixo do limite de 500 alarmes observado em alguns
/// fabricantes Android, deixando espaco para adiamentos pontuais.
const int limiteSeguroAgendamentosAndroid = 450;

final class AgendamentoNotificacao {
  AgendamentoNotificacao({
    required this.id,
    required this.dataHoraLocal,
    required this.payload,
    this.recorrenciaDiaria = false,
  }) {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'O ID deve ser positivo.');
    }
  }

  final int id;
  final DateTime dataHoraLocal;
  final PayloadNotificacao payload;
  final bool recorrenciaDiaria;

  String get titulo => payload.titulo;
  String get corpo => payload.corpo;
  String get payloadCodificado => payload.codificar();
}

final class NotificacaoPendente {
  const NotificacaoPendente({
    required this.id,
    required this.titulo,
    required this.corpo,
    required this.payload,
  });

  final int id;
  final String? titulo;
  final String? corpo;
  final String? payload;
}

final class ProximoLembrete {
  const ProximoLembrete({
    required this.dataHoraLocal,
    required this.titulo,
    required this.corpo,
  });

  final DateTime dataHoraLocal;
  final String titulo;
  final String corpo;
}

final class SaudeNotificacoes {
  const SaudeNotificacoes({
    required this.notificacoesHabilitadas,
    required this.alarmesExatosHabilitados,
    required this.canalHabilitado,
    this.proximoLembrete,
    this.agendaTruncada = false,
    this.coberturaPlanejadaAte,
  });

  final bool notificacoesHabilitadas;
  final bool alarmesExatosHabilitados;
  final bool canalHabilitado;
  final ProximoLembrete? proximoLembrete;

  /// Indica que ha mais ocorrencias validas do que alarmes que o Android pode
  /// manter com seguranca. A reconciliacao preserva as mais proximas e renova
  /// essa janela sempre que o aplicativo inicia ou retoma.
  final bool agendaTruncada;

  /// Ultima ocorrencia individual coberta quando [agendaTruncada] e verdadeira.
  /// Recorrencias diarias continuam sem data final e nao entram neste marco.
  final DateTime? coberturaPlanejadaAte;

  bool get totalmenteHabilitadas =>
      notificacoesHabilitadas && alarmesExatosHabilitados && canalHabilitado;
}

final class ResultadoPlanejamentoNotificacoes {
  const ResultadoPlanejamentoNotificacoes({
    required this.agendamentos,
    required this.truncado,
    this.coberturaPlanejadaAte,
  });

  final List<AgendamentoNotificacao> agendamentos;
  final bool truncado;
  final DateTime? coberturaPlanejadaAte;
}

final class ResultadoReconciliacaoNotificacoes {
  const ResultadoReconciliacaoNotificacoes({
    required this.mantidas,
    required this.agendadas,
    required this.canceladas,
  });

  final int mantidas;
  final int agendadas;
  final int canceladas;
}

final class ResultadoInicializacaoNotificacoes {
  const ResultadoInicializacaoNotificacoes({
    required this.saude,
    required this.fusoHorarioMudou,
    this.reconciliacao,
  });

  final SaudeNotificacoes saude;
  final bool fusoHorarioMudou;
  final ResultadoReconciliacaoNotificacoes? reconciliacao;
}
