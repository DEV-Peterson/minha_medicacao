/// Cria uma identidade estável para uma ocorrência calculada.
///
/// O instante é normalizado para UTC, então representações diferentes do
/// mesmo instante produzem a mesma chave.
String criarDoseKey({
  required String tratamentoId,
  required String regraId,
  required DateTime dataHoraProgramada,
}) {
  if (tratamentoId.trim().isEmpty) {
    throw ArgumentError.value(
      tratamentoId,
      'tratamentoId',
      'O valor não pode ser vazio.',
    );
  }
  if (regraId.trim().isEmpty) {
    throw ArgumentError.value(
      regraId,
      'regraId',
      'O valor não pode ser vazio.',
    );
  }

  final instante = dataHoraProgramada.toUtc().microsecondsSinceEpoch;
  return 'dose:v1|${_segmento(tratamentoId)}|${_segmento(regraId)}|$instante';
}

String _segmento(String valor) => '${valor.length}:$valor';
