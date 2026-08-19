import 'dart:convert';

import '../arquivos/arquivo_seguro.dart';
import 'backup_excecao.dart';

const tipoBackupMinhaMedicacao = 'br.com.minha_medicacao.backup';
const versaoFormatoBackupAtual = 1;
const caminhoManifestBackup = 'manifest.json';
const caminhoBancoBackup = 'database.sqlite';

class ArquivoManifestoBackup {
  const ArquivoManifestoBackup({
    required this.caminho,
    required this.tamanhoBytes,
    required this.sha256,
  });

  final String caminho;
  final int tamanhoBytes;
  final String sha256;

  Map<String, Object> toJson() => <String, Object>{
    'caminho': caminho,
    'tamanhoBytes': tamanhoBytes,
    'sha256': sha256,
  };

  factory ArquivoManifestoBackup.fromJson(Object? valor) {
    if (valor is! Map) {
      throw const BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'A lista de arquivos do manifest é inválida.',
      );
    }
    final caminho = valor['caminho'];
    final tamanho = valor['tamanhoBytes'];
    final hash = valor['sha256'];
    if (caminho is! String ||
        tamanho is! int ||
        tamanho < 0 ||
        hash is! String ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(hash)) {
      throw const BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'Uma entrada de arquivo do manifest é inválida.',
      );
    }
    try {
      validarCaminhoRelativo(caminho);
    } on FormatException catch (erro) {
      throw BackupInvalido(
        MotivoBackupInvalido.caminhoInseguro,
        'O manifest contém um caminho inseguro.',
        erro,
      );
    }
    return ArquivoManifestoBackup(
      caminho: caminho,
      tamanhoBytes: tamanho,
      sha256: hash,
    );
  }
}

class BackupManifest {
  const BackupManifest({
    required this.versaoFormato,
    required this.versaoSchemaBanco,
    required this.versaoAplicativo,
    required this.criadoEmUtc,
    required this.arquivos,
  });

  final int versaoFormato;
  final int versaoSchemaBanco;
  final String versaoAplicativo;
  final DateTime criadoEmUtc;
  final List<ArquivoManifestoBackup> arquivos;

  Map<String, Object> toJson() => <String, Object>{
    'tipo': tipoBackupMinhaMedicacao,
    'versaoFormato': versaoFormato,
    'versaoSchemaBanco': versaoSchemaBanco,
    'versaoAplicativo': versaoAplicativo,
    'criadoEmUtc': criadoEmUtc.toUtc().toIso8601String(),
    'arquivos': arquivos.map((arquivo) => arquivo.toJson()).toList(),
  };

  String codificar() => jsonEncode(toJson());

  factory BackupManifest.decodificar(List<int> bytes) {
    Object? json;
    try {
      json = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    } on Object catch (erro) {
      throw BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'Não foi possível ler o manifest do backup.',
        erro,
      );
    }
    if (json is! Map) {
      throw const BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'O manifest não é um objeto JSON.',
      );
    }

    final tipo = json['tipo'];
    final formato = json['versaoFormato'];
    final schema = json['versaoSchemaBanco'];
    final app = json['versaoAplicativo'];
    final criado = json['criadoEmUtc'];
    final lista = json['arquivos'];
    final data = criado is String ? DateTime.tryParse(criado) : null;
    if (tipo != tipoBackupMinhaMedicacao ||
        formato is! int ||
        schema is! int ||
        schema <= 0 ||
        app is! String ||
        app.isEmpty ||
        data == null ||
        !data.isUtc ||
        lista is! List) {
      throw const BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'Os metadados obrigatórios do manifest são inválidos.',
      );
    }

    final arquivos = lista
        .map<ArquivoManifestoBackup>(ArquivoManifestoBackup.fromJson)
        .toList(growable: false);
    final caminhos = <String>{};
    final caminhosSemCaixa = <String>{};
    for (final arquivo in arquivos) {
      if (!caminhos.add(arquivo.caminho) ||
          !caminhosSemCaixa.add(arquivo.caminho.toLowerCase())) {
        throw const BackupInvalido(
          MotivoBackupInvalido.manifestInvalido,
          'O manifest contém caminhos duplicados.',
        );
      }
    }
    if (!caminhos.contains(caminhoBancoBackup)) {
      throw const BackupInvalido(
        MotivoBackupInvalido.manifestInvalido,
        'O banco de dados não está listado no manifest.',
      );
    }
    return BackupManifest(
      versaoFormato: formato,
      versaoSchemaBanco: schema,
      versaoAplicativo: app,
      criadoEmUtc: data,
      arquivos: arquivos,
    );
  }

  ArquivoManifestoBackup arquivo(String caminho) => arquivos.firstWhere(
    (arquivo) => arquivo.caminho == caminho,
    orElse: () => throw BackupInvalido(
      MotivoBackupInvalido.manifestInvalido,
      'O arquivo $caminho não está no manifest.',
    ),
  );
}
