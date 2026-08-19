import 'package:drift/drift.dart';

/// Persiste uma data de calendário sem associá-la a um instante ou fuso.
///
/// O inteiro usa a forma decimal `YYYYMMDD`. Ao ler, um novo [DateTime] local
/// à meia-noite é criado no fuso corrente, preservando os componentes civis
/// mesmo que o dispositivo tenha mudado de fuso desde a gravação.
final class ConversorDataCivil extends TypeConverter<DateTime, int> {
  const ConversorDataCivil();

  @override
  int toSql(DateTime value) {
    if (value.year < 1 || value.year > 9999) {
      throw ArgumentError.value(
        value,
        'value',
        'A data civil deve ter ano entre 1 e 9999.',
      );
    }
    return value.year * 10000 + value.month * 100 + value.day;
  }

  @override
  DateTime fromSql(int fromDb) {
    final ano = fromDb ~/ 10000;
    final mes = (fromDb ~/ 100) % 100;
    final dia = fromDb % 100;
    final data = DateTime(ano, mes, dia);

    if (ano < 1 ||
        ano > 9999 ||
        data.year != ano ||
        data.month != mes ||
        data.day != dia) {
      throw FormatException(
        'Data civil inválida no banco; esperado YYYYMMDD: $fromDb.',
      );
    }
    return data;
  }
}
