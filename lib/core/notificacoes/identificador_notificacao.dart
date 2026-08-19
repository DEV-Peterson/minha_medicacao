import 'dart:convert';

/// Gera IDs positivos de 31 bits, aceitos pelo Android, a partir de uma chave
/// estável. Colisões continuam teoricamente possíveis e devem ser tratadas na
/// camada que reconcilia os agendamentos.
abstract final class IdentificadorNotificacao {
  static int paraChave(String chaveEstavel) {
    if (chaveEstavel.isEmpty) {
      throw ArgumentError.value(
        chaveEstavel,
        'chaveEstavel',
        'A chave não pode ser vazia.',
      );
    }

    // FNV-1a de 32 bits: algoritmo explícito e independente de hashCode.
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(chaveEstavel)) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }

    final positivo = hash & 0x7fffffff;
    return positivo == 0 ? 1 : positivo;
  }
}
