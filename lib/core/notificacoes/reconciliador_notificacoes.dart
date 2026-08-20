import 'modelos_notificacao.dart';
import 'payload_notificacao.dart';
import 'porta_notificacoes_locais.dart';

final class ReconciliadorNotificacoes {
  const ReconciliadorNotificacoes(this._notificacoes);

  final PortaNotificacoesLocais _notificacoes;

  Future<ResultadoReconciliacaoNotificacoes> reconciliar(
    List<AgendamentoNotificacao> esperados, {
    bool exato = true,
  }) async {
    if (esperados.length > limiteSeguroAgendamentosAndroid) {
      throw StateError(
        'A reconciliacao recebeu ${esperados.length} alarmes; o limite '
        'seguro e $limiteSeguroAgendamentosAndroid.',
      );
    }
    final esperadosPorId = <int, AgendamentoNotificacao>{};
    for (final esperado in esperados) {
      final anterior = esperadosPorId[esperado.id];
      if (anterior != null &&
          anterior.payloadCodificado != esperado.payloadCodificado) {
        throw StateError(
          'Dois agendamentos distintos receberam o ID ${esperado.id}: '
          '${anterior.payload.doseKey} e ${esperado.payload.doseKey}.',
        );
      }
      esperadosPorId[esperado.id] = esperado;
    }

    final pendentes = await _notificacoes.listarPendentes();

    // Uma notificacao de outra origem com o mesmo ID seria sobrescrita pelo
    // Android. Detectamos o conflito antes de modificar qualquer agendamento.
    for (final pendente in pendentes) {
      if (esperadosPorId.containsKey(pendente.id) &&
          !PayloadNotificacao.pertenceAoAplicativo(pendente.payload)) {
        throw StateError(
          'O ID ${pendente.id} ja esta em uso por outra notificacao.',
        );
      }
    }

    final mantidos = <int>{};
    final cancelar = <int>{};
    for (final pendente in pendentes) {
      final esperado = esperadosPorId[pendente.id];
      final nosso = PayloadNotificacao.pertenceAoAplicativo(pendente.payload);
      if (!nosso) continue;

      if (esperado != null &&
          pendente.titulo == esperado.titulo &&
          pendente.corpo == esperado.corpo &&
          pendente.payload == esperado.payloadCodificado &&
          mantidos.add(pendente.id)) {
        continue;
      }
      cancelar.add(pendente.id);
      mantidos.remove(pendente.id);
    }

    for (final id in cancelar) {
      await _notificacoes.cancelar(id);
    }

    var agendadas = 0;
    for (final esperado in esperados) {
      if (mantidos.contains(esperado.id)) continue;
      await _notificacoes.agendar(esperado, exato: exato);
      agendadas++;
    }

    return ResultadoReconciliacaoNotificacoes(
      mantidas: mantidos.length,
      agendadas: agendadas,
      canceladas: cancelar.length,
    );
  }
}
