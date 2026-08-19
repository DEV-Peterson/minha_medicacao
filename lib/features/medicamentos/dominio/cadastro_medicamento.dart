class HorarioCadastro implements Comparable<HorarioCadastro> {
  const HorarioCadastro(this.hora, this.minuto)
    : assert(hora >= 0 && hora <= 23),
      assert(minuto >= 0 && minuto <= 59);

  final int hora;
  final int minuto;

  @override
  int compareTo(HorarioCadastro other) =>
      (hora * 60 + minuto).compareTo(other.hora * 60 + other.minuto);

  @override
  bool operator ==(Object other) =>
      other is HorarioCadastro && other.hora == hora && other.minuto == minuto;

  @override
  int get hashCode => Object.hash(hora, minuto);
}

enum TipoAgendamentoCadastro { horariosFixos, intervalo }

class CadastroMedicamento {
  CadastroMedicamento({
    required this.nome,
    required this.formaFarmaceutica,
    required this.unidadeDosePadrao,
    required this.quantidadeDose,
    required this.unidadeDose,
    required this.dataInicio,
    required this.usoContinuo,
    required this.tipoAgendamento,
    this.concentracao,
    this.observacoes,
    this.dataFim,
    this.horarios = const [],
    this.dataHoraAncora,
    this.intervaloMinutos,
    this.instrucoes,
    this.controlarEstoque = false,
    this.unidadeEstoque,
    this.estoqueInicial,
    this.consumoEstoquePorDose,
  });

  final String nome;
  final String? concentracao;
  final String formaFarmaceutica;
  final String unidadeDosePadrao;
  final String? observacoes;
  final double quantidadeDose;
  final String unidadeDose;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool usoContinuo;
  final TipoAgendamentoCadastro tipoAgendamento;
  final List<HorarioCadastro> horarios;
  final DateTime? dataHoraAncora;
  final int? intervaloMinutos;
  final String? instrucoes;
  final bool controlarEstoque;
  final String? unidadeEstoque;
  final double? estoqueInicial;
  final double? consumoEstoquePorDose;

  void validar() {
    if (nome.trim().isEmpty) {
      throw const FormularioInvalido('Informe o nome do medicamento.');
    }
    if (quantidadeDose <= 0) {
      throw const FormularioInvalido(
        'A quantidade por dose deve ser maior que zero.',
      );
    }
    if (unidadeDose.trim().isEmpty) {
      throw const FormularioInvalido('Informe a unidade da dose.');
    }
    if (!usoContinuo) {
      if (dataFim == null) {
        throw const FormularioInvalido('Informe a data final do tratamento.');
      }
      if (_somenteData(dataFim!).isBefore(_somenteData(dataInicio))) {
        throw const FormularioInvalido(
          'A data final não pode ser anterior à data inicial.',
        );
      }
    }
    if (tipoAgendamento == TipoAgendamentoCadastro.horariosFixos) {
      if (horarios.isEmpty) {
        throw const FormularioInvalido('Adicione pelo menos um horário.');
      }
      if (horarios.toSet().length != horarios.length) {
        throw const FormularioInvalido('Não é permitido repetir horários.');
      }
    } else if (dataHoraAncora == null || (intervaloMinutos ?? 0) <= 0) {
      throw const FormularioInvalido(
        'Informe a primeira dose e um intervalo maior que zero.',
      );
    }
    if (controlarEstoque) {
      if ((unidadeEstoque ?? '').trim().isEmpty) {
        throw const FormularioInvalido('Informe a unidade usada no estoque.');
      }
      if ((estoqueInicial ?? 0) < 0) {
        throw const FormularioInvalido(
          'O estoque inicial não pode ser negativo.',
        );
      }
      if ((consumoEstoquePorDose ?? 0) <= 0) {
        throw const FormularioInvalido(
          'Informe um consumo de estoque por dose maior que zero.',
        );
      }
    }
  }
}

class EdicaoTratamento {
  EdicaoTratamento({
    required this.quantidadeDose,
    required this.unidadeDose,
    required this.dataInicio,
    required this.usoContinuo,
    required this.tipoAgendamento,
    this.dataFim,
    this.horarios = const [],
    this.dataHoraAncora,
    this.intervaloMinutos,
    this.instrucoes,
    this.consumoEstoquePorDose,
  });

  final double quantidadeDose;
  final String unidadeDose;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final bool usoContinuo;
  final TipoAgendamentoCadastro tipoAgendamento;
  final List<HorarioCadastro> horarios;
  final DateTime? dataHoraAncora;
  final int? intervaloMinutos;
  final String? instrucoes;
  final double? consumoEstoquePorDose;

  void validar({required bool controlaEstoque}) {
    if (quantidadeDose <= 0) {
      throw const FormularioInvalido(
        'A quantidade por dose deve ser maior que zero.',
      );
    }
    if (unidadeDose.trim().isEmpty) {
      throw const FormularioInvalido('Informe a unidade da dose.');
    }
    if (!usoContinuo && dataFim == null) {
      throw const FormularioInvalido('Informe a data final do tratamento.');
    }
    if (dataFim != null &&
        _somenteData(dataFim!).isBefore(_somenteData(dataInicio))) {
      throw const FormularioInvalido(
        'A data final não pode ser anterior à data inicial.',
      );
    }
    if (tipoAgendamento == TipoAgendamentoCadastro.horariosFixos) {
      if (horarios.isEmpty) {
        throw const FormularioInvalido('Adicione pelo menos um horário.');
      }
      if (horarios.toSet().length != horarios.length) {
        throw const FormularioInvalido('Não é permitido repetir horários.');
      }
    } else if (dataHoraAncora == null || (intervaloMinutos ?? 0) <= 0) {
      throw const FormularioInvalido(
        'Informe a primeira dose e um intervalo maior que zero.',
      );
    }
    if (controlaEstoque && (consumoEstoquePorDose ?? 0) <= 0) {
      throw const FormularioInvalido(
        'Informe um consumo de estoque por dose maior que zero.',
      );
    }
  }
}

class FormularioInvalido implements Exception {
  const FormularioInvalido(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

DateTime _somenteData(DateTime value) =>
    DateTime(value.year, value.month, value.day);
