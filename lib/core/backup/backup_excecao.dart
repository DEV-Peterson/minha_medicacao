enum MotivoBackupInvalido {
  arquivoMuitoGrande,
  zipCorrompido,
  estruturaInvalida,
  caminhoInseguro,
  limiteExcedido,
  manifestInvalido,
  formatoIncompativel,
  schemaIncompativel,
  hashInvalido,
  bancoInvalido,
  anexoInconsistente,
}

class BackupInvalido implements Exception {
  const BackupInvalido(this.motivo, this.mensagem, [this.causa]);

  final MotivoBackupInvalido motivo;
  final String mensagem;
  final Object? causa;

  @override
  String toString() => 'BackupInvalido($motivo): $mensagem';
}

class FalhaAoCriarBackup implements Exception {
  const FalhaAoCriarBackup(this.mensagem, [this.causa]);

  final String mensagem;
  final Object? causa;

  @override
  String toString() => 'FalhaAoCriarBackup: $mensagem';
}

class RestauracaoJaEmAndamento implements Exception {
  const RestauracaoJaEmAndamento();

  @override
  String toString() =>
      'Existe uma restauração interrompida que precisa ser recuperada.';
}

class FalhaNaRestauracao implements Exception {
  const FalhaNaRestauracao(this.mensagem, {this.causa, this.falhaNoRollback});

  final String mensagem;
  final Object? causa;
  final Object? falhaNoRollback;

  bool get rollbackConcluido => falhaNoRollback == null;

  @override
  String toString() => 'FalhaNaRestauracao: $mensagem';
}
