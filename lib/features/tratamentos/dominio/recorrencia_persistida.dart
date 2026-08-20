import '../../../core/banco/app_database.dart';
import 'modelos_agenda.dart';

/// Traduz a recorrência entre as colunas do banco e o domínio.
///
/// O banco guarda o tipo e os parâmetros em colunas separadas para permitir
/// checagens de integridade; o domínio usa uma hierarquia selada.
abstract final class RecorrenciaPersistida {
  static RecorrenciaDias doTratamento(TratamentoDb tratamento) => decodificar(
    tipo: tratamento.recorrencia,
    intervalo: tratamento.recorrenciaIntervalo,
    diasSemana: tratamento.recorrenciaDiasSemana,
    diaDoMes: tratamento.recorrenciaDiaDoMes,
  );

  static RecorrenciaDias decodificar({
    required String tipo,
    int? intervalo,
    String? diasSemana,
    int? diaDoMes,
  }) {
    switch (tipo) {
      case 'cadaNDias':
        return RecorrenciaCadaNDias(intervalo ?? 1);
      case 'diasDaSemana':
        return RecorrenciaDiasDaSemana(
          decodificarDiasDaSemana(diasSemana),
          aCadaSemanas: intervalo ?? 1,
        );
      case 'mensal':
        return RecorrenciaMensal(diaDoMes ?? 1, aCadaMeses: intervalo ?? 1);
      default:
        return const RecorrenciaDiaria();
    }
  }

  static Set<int> decodificarDiasDaSemana(String? valor) {
    final partes = (valor ?? '')
        .split(',')
        .map((parte) => int.tryParse(parte.trim()))
        .whereType<int>()
        .toSet();
    return partes.isEmpty ? {DateTime.monday} : partes;
  }

  static String codificarDiasDaSemana(Iterable<int> dias) =>
      (dias.toList()..sort()).join(',');

  /// Valores prontos para as colunas de `tratamentos`.
  static ({String tipo, int? intervalo, String? diasSemana, int? diaDoMes})
  colunas(RecorrenciaDias recorrencia) => switch (recorrencia) {
    RecorrenciaDiaria() => (
      tipo: 'diaria',
      intervalo: null,
      diasSemana: null,
      diaDoMes: null,
    ),
    RecorrenciaCadaNDias(:final dias) => (
      tipo: 'cadaNDias',
      intervalo: dias,
      diasSemana: null,
      diaDoMes: null,
    ),
    RecorrenciaDiasDaSemana(:final diasDaSemana, :final aCadaSemanas) => (
      tipo: 'diasDaSemana',
      intervalo: aCadaSemanas,
      diasSemana: codificarDiasDaSemana(diasDaSemana),
      diaDoMes: null,
    ),
    RecorrenciaMensal(:final diaDoMes, :final aCadaMeses) => (
      tipo: 'mensal',
      intervalo: aCadaMeses,
      diasSemana: null,
      diaDoMes: diaDoMes,
    ),
  };
}
