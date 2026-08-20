/// Operações de calendário que preservam o conceito de data e hora locais.
///
/// Avançar um dia recriando o calendário, em vez de somar 24 horas, evita
/// deslocamentos de meia-noite em regiões que adotam horário de verão.
abstract final class DataHoraLocal {
  static DateTime inicioDoDia(DateTime valor) {
    final local = _comoLocal(valor);
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime inicioDoProximoDia(DateTime valor) {
    final local = _comoLocal(valor);
    return DateTime(local.year, local.month, local.day + 1);
  }

  static DateTime fimDoDia(DateTime valor) =>
      inicioDoProximoDia(valor).subtract(const Duration(microseconds: 1));

  static DateTime adicionarDiasCalendario(DateTime valor, int dias) {
    final local = _comoLocal(valor);
    return DateTime(
      local.year,
      local.month,
      local.day + dias,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }

  static DateTime combinar(
    DateTime data, {
    required int hora,
    required int minuto,
  }) {
    if (hora < 0 || hora > 23) {
      throw RangeError.range(hora, 0, 23, 'hora');
    }
    if (minuto < 0 || minuto > 59) {
      throw RangeError.range(minuto, 0, 59, 'minuto');
    }

    final local = _comoLocal(data);
    return DateTime(local.year, local.month, local.day, hora, minuto);
  }

  /// Diferença em dias de calendário, ignorando hora, minuto e fuso.
  ///
  /// Subtrair `DateTime` devolveria duração absoluta, que erra em regiões com
  /// horário de verão; aqui a contagem é sempre civil.
  static int diferencaEmDias(DateTime de, DateTime ate) {
    final inicio = inicioDoDia(de);
    final fim = inicioDoDia(ate);
    return (fim.difference(inicio).inHours / 24).round();
  }

  static int ultimoDiaDoMes(int ano, int mes) => DateTime(ano, mes + 1, 0).day;

  /// Diferença em meses de calendário entre duas datas.
  static int diferencaEmMeses(DateTime de, DateTime ate) {
    final inicio = _comoLocal(de);
    final fim = _comoLocal(ate);
    return (fim.year - inicio.year) * 12 + (fim.month - inicio.month);
  }

  static bool mesmaData(DateTime primeiro, DateTime segundo) {
    final primeiroLocal = _comoLocal(primeiro);
    final segundoLocal = _comoLocal(segundo);
    return primeiroLocal.year == segundoLocal.year &&
        primeiroLocal.month == segundoLocal.month &&
        primeiroLocal.day == segundoLocal.day;
  }

  static DateTime maisRecente(DateTime primeiro, DateTime segundo) =>
      primeiro.isAfter(segundo) ? primeiro : segundo;

  static DateTime maisAntigo(DateTime primeiro, DateTime segundo) =>
      primeiro.isBefore(segundo) ? primeiro : segundo;

  static DateTime _comoLocal(DateTime valor) =>
      valor.isUtc ? valor.toLocal() : valor;
}
