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

/// Define em quais dias uma regra de horários fixos vale.
///
/// A contagem é sempre por data civil: somar durações deslocaria o horário
/// prescrito quando o fuso muda.
sealed class RecorrenciaDias {
  const RecorrenciaDias();

  /// Rótulo persistido na coluna `recorrencia`.
  String get tipo;

  bool incluiDia(DateTime dia, DateTime dataInicio);
}

/// Todo dia dentro do período do tratamento. É o padrão.
final class RecorrenciaDiaria extends RecorrenciaDias {
  const RecorrenciaDiaria();

  @override
  String get tipo => 'diaria';

  @override
  bool incluiDia(DateTime dia, DateTime dataInicio) => true;
}

/// A cada N dias contados a partir do início do tratamento.
final class RecorrenciaCadaNDias extends RecorrenciaDias {
  RecorrenciaCadaNDias(this.dias) {
    if (dias < 1) {
      throw ArgumentError.value(dias, 'dias', 'Informe ao menos um dia.');
    }
  }

  final int dias;

  @override
  String get tipo => 'cadaNDias';

  @override
  bool incluiDia(DateTime dia, DateTime dataInicio) {
    final decorridos = DataHoraLocal.diferencaEmDias(dataInicio, dia);
    return decorridos >= 0 && decorridos % dias == 0;
  }
}

/// Dias da semana escolhidos, opcionalmente a cada N semanas.
///
/// A semana de referência é a do início do tratamento, começando na segunda.
final class RecorrenciaDiasDaSemana extends RecorrenciaDias {
  RecorrenciaDiasDaSemana(Iterable<int> diasDaSemana, {this.aCadaSemanas = 1})
    : diasDaSemana = _validar(diasDaSemana) {
    if (aCadaSemanas < 1) {
      throw ArgumentError.value(
        aCadaSemanas,
        'aCadaSemanas',
        'Informe ao menos uma semana.',
      );
    }
  }

  /// Segue `DateTime.weekday`: 1 é segunda-feira e 7 é domingo.
  final Set<int> diasDaSemana;
  final int aCadaSemanas;

  @override
  String get tipo => 'diasDaSemana';

  @override
  bool incluiDia(DateTime dia, DateTime dataInicio) {
    if (!diasDaSemana.contains(dia.weekday)) return false;
    if (aCadaSemanas == 1) return true;
    final semanas = _semanasEntre(dataInicio, dia);
    return semanas >= 0 && semanas % aCadaSemanas == 0;
  }

  static int _semanasEntre(DateTime dataInicio, DateTime dia) {
    final inicioDaSemanaInicial = DataHoraLocal.adicionarDiasCalendario(
      DataHoraLocal.inicioDoDia(dataInicio),
      -(dataInicio.weekday - 1),
    );
    final inicioDaSemanaDoDia = DataHoraLocal.adicionarDiasCalendario(
      DataHoraLocal.inicioDoDia(dia),
      -(dia.weekday - 1),
    );
    return DataHoraLocal.diferencaEmDias(
          inicioDaSemanaInicial,
          inicioDaSemanaDoDia,
        ) ~/
        7;
  }

  static Set<int> _validar(Iterable<int> valores) {
    final dias = valores.toSet();
    if (dias.isEmpty) {
      throw ArgumentError.value(
        valores,
        'diasDaSemana',
        'Escolha ao menos um dia da semana.',
      );
    }
    for (final dia in dias) {
      if (dia < DateTime.monday || dia > DateTime.sunday) {
        throw RangeError.range(dia, DateTime.monday, DateTime.sunday, 'dia');
      }
    }
    return Set.unmodifiable(dias);
  }
}

/// Um dia fixo do mês, opcionalmente a cada N meses.
///
/// Quando o mês não tem o dia escolhido, a dose cai no último dia do mês:
/// dia 31 vira 28 ou 29 em fevereiro, e 30 nos meses curtos.
final class RecorrenciaMensal extends RecorrenciaDias {
  RecorrenciaMensal(this.diaDoMes, {this.aCadaMeses = 1}) {
    if (diaDoMes < 1 || diaDoMes > 31) {
      throw RangeError.range(diaDoMes, 1, 31, 'diaDoMes');
    }
    if (aCadaMeses < 1) {
      throw ArgumentError.value(
        aCadaMeses,
        'aCadaMeses',
        'Informe ao menos um mês.',
      );
    }
  }

  final int diaDoMes;
  final int aCadaMeses;

  @override
  String get tipo => 'mensal';

  @override
  bool incluiDia(DateTime dia, DateTime dataInicio) {
    final ultimoDia = DataHoraLocal.ultimoDiaDoMes(dia.year, dia.month);
    final diaEfetivo = diaDoMes > ultimoDia ? ultimoDia : diaDoMes;
    if (dia.day != diaEfetivo) return false;
    if (aCadaMeses == 1) return true;
    final meses = DataHoraLocal.diferencaEmMeses(dataInicio, dia);
    return meses >= 0 && meses % aCadaMeses == 0;
  }
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
    this.recorrencia = const RecorrenciaDiaria(),
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
    // A recorrência escolhe dias do calendário; o intervalo em horas mantém
    // a própria sequência a partir da âncora. Combinar os dois produziria
    // agendas ambíguas.
    if (regra is RegraIntervaloAncorado && recorrencia is! RecorrenciaDiaria) {
      throw ArgumentError.value(
        recorrencia,
        'recorrencia',
        'Intervalo em horas não aceita recorrência por dias.',
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
  final RecorrenciaDias recorrencia;

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
