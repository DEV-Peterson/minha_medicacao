class LimitesBackup {
  const LimitesBackup({
    this.maximoZipBytes = 512 * 1024 * 1024,
    this.maximoEntradas = 1000,
    this.maximoManifestBytes = 1024 * 1024,
    this.maximoArquivoBytes = 256 * 1024 * 1024,
    this.maximoTotalExtraidoBytes = 1024 * 1024 * 1024,
    this.maximaRazaoCompressao = 1000,
  });

  final int maximoZipBytes;
  final int maximoEntradas;
  final int maximoManifestBytes;
  final int maximoArquivoBytes;
  final int maximoTotalExtraidoBytes;
  final double maximaRazaoCompressao;
}
