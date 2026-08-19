/// Fonte de tempo injetável para evitar o uso espalhado de [DateTime.now].
abstract interface class Relogio {
  DateTime agora();
}

/// Relógio utilizado em produção.
final class RelogioSistema implements Relogio {
  const RelogioSistema();

  @override
  DateTime agora() => DateTime.now();
}
