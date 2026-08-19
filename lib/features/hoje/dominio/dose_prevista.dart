enum StatusRegistroDose { tomada, naoTomada }

enum StatusDose { tomada, pendente, emAtraso, naoTomada }

/// Ocorrência calculada pelo motor de agenda, ainda que não haja registro no
/// banco para ela.
final class DosePrevista {
  const DosePrevista({
    required this.doseKey,
    required this.tratamentoId,
    required this.medicamentoId,
    required this.regraId,
    required this.dataHoraProgramada,
    required this.quantidadeDose,
    required this.unidadeDose,
    this.consumoEstoquePorDose,
    this.instrucoes,
  });

  final String doseKey;
  final String tratamentoId;
  final String medicamentoId;
  final String regraId;
  final DateTime dataHoraProgramada;
  final double quantidadeDose;
  final String unidadeDose;
  final double? consumoEstoquePorDose;
  final String? instrucoes;

  StatusDose statusEm(DateTime agora, {StatusRegistroDose? registro}) =>
      derivarStatusDose(
        dataHoraProgramada: dataHoraProgramada,
        agora: agora,
        registro: registro,
      );
}

/// O banco persiste somente tomada/não tomada; pendência e atraso são
/// derivados em relação ao relógio atual.
StatusDose derivarStatusDose({
  required DateTime dataHoraProgramada,
  required DateTime agora,
  StatusRegistroDose? registro,
}) {
  if (registro == StatusRegistroDose.tomada) {
    return StatusDose.tomada;
  }
  if (registro == StatusRegistroDose.naoTomada) {
    return StatusDose.naoTomada;
  }
  return agora.isAfter(dataHoraProgramada)
      ? StatusDose.emAtraso
      : StatusDose.pendente;
}
