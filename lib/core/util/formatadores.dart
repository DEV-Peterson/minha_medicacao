import 'package:intl/intl.dart';

import '../../features/tratamentos/dominio/modelos_agenda.dart';

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

const _nomesDosDias = {
  DateTime.monday: 'segunda-feira',
  DateTime.tuesday: 'terça-feira',
  DateTime.wednesday: 'quarta-feira',
  DateTime.thursday: 'quinta-feira',
  DateTime.friday: 'sexta-feira',
  DateTime.saturday: 'sábado',
  DateTime.sunday: 'domingo',
};

const _nomesCurtosDosDias = {
  DateTime.monday: 'seg',
  DateTime.tuesday: 'ter',
  DateTime.wednesday: 'qua',
  DateTime.thursday: 'qui',
  DateTime.friday: 'sex',
  DateTime.saturday: 'sáb',
  DateTime.sunday: 'dom',
};

String nomeDoDiaDaSemana(int dia) => _nomesDosDias[dia] ?? '';

/// Texto curto que descreve em quais dias a agenda se repete.
String descreverRecorrencia(RecorrenciaDias recorrencia) {
  switch (recorrencia) {
    case RecorrenciaDiaria():
      return 'todos os dias';
    case RecorrenciaCadaNDias(:final dias):
      return dias == 1
          ? 'todos os dias'
          : dias == 2
          ? 'dia sim, dia não'
          : 'a cada $dias dias';
    case RecorrenciaDiasDaSemana(:final diasDaSemana, :final aCadaSemanas):
      final ordenados = diasDaSemana.toList()..sort();
      final nomes = ordenados
          .map((dia) => _nomesCurtosDosDias[dia] ?? '')
          .join(', ');
      return aCadaSemanas == 1 ? nomes : '$nomes, a cada $aCadaSemanas semanas';
    case RecorrenciaMensal(:final diaDoMes, :final aCadaMeses):
      return aCadaMeses == 1
          ? 'todo dia $diaDoMes'
          : 'dia $diaDoMes, a cada $aCadaMeses meses';
  }
}
