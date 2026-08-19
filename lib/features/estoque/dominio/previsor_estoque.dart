import '../../hoje/dominio/gerador_agenda.dart';
import '../../tratamentos/dominio/modelos_agenda.dart';

class PrevisaoEstoque {
  const PrevisaoEstoque({
    required this.saldoAtual,
    required this.consumoProximosSeteDias,
    this.dataInsuficiente,
  });

  final double saldoAtual;
  final double consumoProximosSeteDias;
  final DateTime? dataInsuficiente;

  int? diasAproximadosEm(DateTime agora) {
    final data = dataInsuficiente;
    if (data == null) return null;
    return DateTime(
      data.year,
      data.month,
      data.day,
    ).difference(DateTime(agora.year, agora.month, agora.day)).inDays;
  }
}

class PrevisorEstoque {
  const PrevisorEstoque([this._gerador = const GeradorAgenda()]);

  final GeradorAgenda _gerador;

  PrevisaoEstoque calcular({
    required double saldoAtual,
    required List<TratamentoAgenda> tratamentos,
    required DateTime agora,
    Duration horizonte = const Duration(days: 3660),
  }) {
    final fim = agora.add(horizonte);
    final ocorrencias = [
      for (final tratamento in tratamentos)
        ..._gerador.gerar(
          tratamento: tratamento,
          periodo: PeriodoAgenda(inicio: agora, fimExclusivo: fim),
        ),
    ]..sort((a, b) => a.dataHoraProgramada.compareTo(b.dataHoraProgramada));

    var saldo = saldoAtual;
    var consumoSeteDias = 0.0;
    DateTime? insuficiente;
    final seteDias = agora.add(const Duration(days: 7));
    for (final dose in ocorrencias) {
      final consumo = dose.consumoEstoquePorDose;
      if (consumo == null) continue;
      if (dose.dataHoraProgramada.isBefore(seteDias)) {
        consumoSeteDias += consumo;
      }
      if (insuficiente == null && saldo + 0.000001 < consumo) {
        insuficiente = dose.dataHoraProgramada;
      }
      saldo -= consumo;
    }
    return PrevisaoEstoque(
      saldoAtual: saldoAtual,
      consumoProximosSeteDias: consumoSeteDias,
      dataInsuficiente: insuficiente,
    );
  }
}
