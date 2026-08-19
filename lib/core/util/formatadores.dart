import 'package:intl/intl.dart';

final _hora = DateFormat('HH:mm', 'pt_BR');
final _data = DateFormat('dd/MM/yyyy', 'pt_BR');
final _dataCurta = DateFormat('dd/MM', 'pt_BR');
final _dataExtensa = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');

String formatarHora(DateTime value) => _hora.format(value);
String formatarData(DateTime value) => _data.format(value);
String formatarDataCurta(DateTime value) => _dataCurta.format(value);

String formatarDataExtensa(DateTime value) {
  final text = _dataExtensa.format(value);
  return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}

String formatarQuantidade(num value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return NumberFormat('0.##', 'pt_BR').format(value);
}

double? lerDecimal(String value) {
  final trimmed = value.trim();
  final normalized = trimmed.contains(',')
      ? trimmed.replaceAll('.', '').replaceAll(',', '.')
      : trimmed;
  return double.tryParse(normalized);
}

String nomeMedicamento(String nome, String? concentracao) {
  final detail = concentracao?.trim();
  return detail == null || detail.isEmpty ? nome : '$nome $detail';
}
