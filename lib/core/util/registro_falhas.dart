import 'dart:developer' as developer;

/// Registra uma falha sem expor dados de saúde.
///
/// Mensagens de exceção podem carregar trechos de consulta com nome de
/// medicamento, e o log do Android sobrevive ao aplicativo. Por isso o
/// registro guarda apenas a etapa e o tipo do erro; a mensagem completa fica
/// disponível somente em depuração.
void registrarFalha(String etapa, Object erro, [StackTrace? pilha]) {
  developer.log(
    'Falha em $etapa (${erro.runtimeType})',
    name: 'minha_medicacao',
    stackTrace: pilha,
  );
  assert(() {
    // ignore: avoid_print
    print('[minha_medicacao] $etapa: $erro');
    return true;
  }());
}
