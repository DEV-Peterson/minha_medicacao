import 'dart:async';

/// Serializa operações que alteram ou fotografam o conjunto banco + anexos.
///
/// O bloqueio é reentrante dentro da mesma [Zone], o que permite que uma
/// restauração crie seu backup de segurança sem provocar deadlock.
class ExclusaoMutuaArquivos {
  ExclusaoMutuaArquivos();

  static final compartilhada = ExclusaoMutuaArquivos();

  final Object _chaveZona = Object();
  Future<void> _fimDaFila = Future<void>.value();

  Future<T> executar<T>(Future<T> Function() operacao) async {
    if (identical(Zone.current[_chaveZona], this)) {
      return operacao();
    }

    final vez = Completer<void>();
    final anterior = _fimDaFila;
    _fimDaFila = vez.future;

    await anterior.catchError((Object _) {});
    try {
      return await runZoned(
        operacao,
        zoneValues: <Object, Object>{_chaveZona: this},
      );
    } finally {
      vez.complete();
    }
  }
}
