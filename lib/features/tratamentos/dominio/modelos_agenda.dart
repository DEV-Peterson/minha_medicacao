import 'package:minha_medicacao/core/data_hora/data_hora_local.dart';

/// Horário prescrito dentro de um dia, associado a uma regra estável.
final class HorarioTratamento implements Comparable<HorarioTratamento> {
  HorarioTratamento({
    required this.id,
    required this.hora,
    required this.minuto,
  }) {
    _exigirTexto(id, 'id');
    if (hora < 0 || hora > 23) {
      throw RangeError.range(hora, 0, 23, 'hora');
    }
    if (minuto < 0 || minuto > 59) {
      throw RangeError.range(minuto, 0, 59, 'minuto');
    }
  }

  final String id;
  final int hora;
  final int minuto;

  @override
  int compareTo(HorarioTratamento outro) {
    final porHora = hora.compareTo(outro.hora);
    return porHora != 0 ? porHora : minuto.compareTo(outro.minuto);
  }

  @override
  String toString() =>
      '${hora.toString().padLeft(2, '0')}:'
      '${minuto.toString().padLeft(2, '0')}';
}

sealed class RegraAgendamento {
  const RegraAgendamento();
}

/// Regra com uma ou mais horas locais prescritas para cada dia válido.
final class RegraHorariosFixos extends RegraAgendamento {
  RegraHorariosFixos(Iterable<HorarioTratamento> horarios)
    : horarios = _validarEOrdenar(horarios);

  final List<HorarioTratamento> horarios;

  static List<HorarioTratamento> _validarEOrdenar(
    Iterable<HorarioTratamento> valores,
  ) {
    final ordenados = valores.toList()..sort();
    if (ordenados.isEmpty) {
      throw ArgumentError.value(valores, 'horarios', 'Informe um horário.');
    }

    final ids = <String>{};
    final minutosDoDia = <int>{};
    for (final horario in ordenados) {
      if (!ids.add(horario.id)) {
        throw ArgumentError.value(
          horario.id,
          'horarios',
          'IDs de regra não podem se repetir.',
        );
      }
      if (!minutosDoDia.add(horario.hora * 60 + horario.minuto)) {
        throw ArgumentError.value(
          horario,
          'horarios',
          'Horários duplicados não são permitidos.',
        );
      }
    }

    return List.unmodifiable(ordenados);
  }
}

/// Regra cuja sequência parte sempre da mesma primeira dose.
final class RegraIntervaloAncorado extends RegraAgendamento {
  RegraIntervaloAncorado({
    required this.id,
    required this.dataHoraAncora,
    required this.intervalo,
  }) {
    _exigirTexto(id, 'id');
    if (intervalo <= Duration.zero) {
      throw ArgumentError.value(
        intervalo,
        'intervalo',
        'O intervalo deve ser maior que zero.',
      );
    }
  }

  final String id;
  final DateTime dataHoraAncora;
  final Duration intervalo;
}

/// Recorte do tratamento necessário para calcular a agenda.
final class TratamentoAgenda {
  TratamentoAgenda({
    required this.id,
    required this.medicamentoId,
    required this.quantidadeDose,
    required this.unidadeDose,
    required DateTime dataInicio,
    required this.usoContinuo,
    required this.regra,
    DateTime? dataFim,
    this.consumoEstoquePorDose,
    this.instrucoes,
    this.ativo = true,
  }) : dataInicio = DataHoraLocal.inicioDoDia(dataInicio),
       dataFim = dataFim == null ? null : DataHoraLocal.inicioDoDia(dataFim) {
    _exigirTexto(id, 'id');
    _exigirTexto(medicamentoId, 'medicamentoId');
    _exigirTexto(unidadeDose, 'unidadeDose');
    _exigirNumeroPositivo(quantidadeDose, 'quantidadeDose');

    final consumo = consumoEstoquePorDose;
    if (consumo != null) {
      _exigirNumeroPositivo(consumo, 'consumoEstoquePorDose');
    }

    if (usoContinuo && this.dataFim != null) {
      throw ArgumentError.value(
        dataFim,
        'dataFim',
        'Tratamento contínuo não deve possuir data final.',
      );
    }
    if (!usoContinuo && this.dataFim == null) {
      throw ArgumentError.notNull('dataFim');
    }
    if (this.dataFim?.isBefore(this.dataInicio) ?? false) {
      throw ArgumentError.value(
        dataFim,
        'dataFim',
        'A data final não pode anteceder a data inicial.',
      );
    }
  }

  final String id;
  final String medicamentoId;
  final double quantidadeDose;
  final String unidadeDose;
  final double? consumoEstoquePorDose;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool usoContinuo;
  final String? instrucoes;
  final bool ativo;
  final RegraAgendamento regra;

  /// Primeiro instante que já não pertence ao tratamento.
  DateTime? get fimExclusivo =>
      dataFim == null ? null : DataHoraLocal.inicioDoProximoDia(dataFim!);
}

/// Período semiaberto: inclui [inicio] e exclui [fimExclusivo].
final class PeriodoAgenda {
  PeriodoAgenda({required this.inicio, required this.fimExclusivo}) {
    if (!fimExclusivo.isAfter(inicio)) {
      throw ArgumentError.value(
        fimExclusivo,
        'fimExclusivo',
        'O fim deve ser posterior ao início.',
      );
    }
  }

  factory PeriodoAgenda.dia(DateTime data) => PeriodoAgenda(
    inicio: DataHoraLocal.inicioDoDia(data),
    fimExclusivo: DataHoraLocal.inicioDoProximoDia(data),
  );

  final DateTime inicio;
  final DateTime fimExclusivo;
}

void _exigirTexto(String valor, String nome) {
  if (valor.trim().isEmpty) {
    throw ArgumentError.value(valor, nome, 'O valor não pode ser vazio.');
  }
}

void _exigirNumeroPositivo(double valor, String nome) {
  if (!valor.isFinite || valor <= 0) {
    throw ArgumentError.value(valor, nome, 'O valor deve ser maior que zero.');
  }
}
