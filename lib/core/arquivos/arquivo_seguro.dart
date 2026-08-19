import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

class LimiteArquivoExcedido implements Exception {
  const LimiteArquivoExcedido(this.limiteBytes);

  final int limiteBytes;

  @override
  String toString() =>
      'O arquivo excede o limite permitido de $limiteBytes bytes.';
}

class ResumoArquivo {
  const ResumoArquivo({required this.tamanhoBytes, required this.sha256});

  final int tamanhoBytes;
  final String sha256;
}

/// Copia um stream para [destino] sem acumular seu conteúdo na memória.
///
/// A gravação usa um arquivo `.part` no mesmo diretório e só publica o destino
/// depois de fechar e descarregar os dados.
Future<ResumoArquivo> copiarStreamComHash(
  Stream<List<int>> origem,
  File destino, {
  required int limiteBytes,
}) async {
  if (limiteBytes <= 0) {
    throw ArgumentError.value(limiteBytes, 'limiteBytes');
  }
  await destino.parent.create(recursive: true);
  final parcial = File('${destino.path}.part');
  if (await parcial.exists()) await parcial.delete();
  if (await destino.exists()) {
    throw FileSystemException('O arquivo de destino já existe.', destino.path);
  }

  final acumulador = _DigestSink();
  final hashSink = sha256.startChunkedConversion(acumulador);
  final output = parcial.openWrite(mode: FileMode.writeOnly);
  var total = 0;
  var hashFechado = false;
  var outputFechado = false;

  try {
    await for (final bloco in origem) {
      if (bloco.isEmpty) continue;
      total += bloco.length;
      if (total > limiteBytes) {
        throw LimiteArquivoExcedido(limiteBytes);
      }
      hashSink.add(bloco);
      output.add(bloco);
    }
    hashSink.close();
    hashFechado = true;
    await output.flush();
    await output.close();
    outputFechado = true;
    await parcial.rename(destino.path);
    return ResumoArquivo(
      tamanhoBytes: total,
      sha256: acumulador.valor!.toString(),
    );
  } catch (_) {
    if (!hashFechado) hashSink.close();
    if (!outputFechado) await output.close().catchError((Object _) {});
    await excluirSemPropagar(parcial);
    rethrow;
  }
}

Future<ResumoArquivo> resumirArquivo(File arquivo) async {
  final acumulador = _DigestSink();
  final sink = sha256.startChunkedConversion(acumulador);
  var tamanho = 0;
  await for (final bloco in arquivo.openRead()) {
    tamanho += bloco.length;
    sink.add(bloco);
  }
  sink.close();
  return ResumoArquivo(
    tamanhoBytes: tamanho,
    sha256: acumulador.valor!.toString(),
  );
}

/// Resolve um caminho POSIX relativo dentro de [raiz].
///
/// Rejeita caminhos ambíguos antes de convertê-los para o separador local.
File resolverArquivoRelativo(Directory raiz, String caminhoRelativo) {
  validarCaminhoRelativo(caminhoRelativo);
  final partes = p.posix.split(caminhoRelativo);
  return File(p.joinAll(<String>[raiz.path, ...partes]));
}

void validarCaminhoRelativo(String caminho) {
  if (caminho.isEmpty ||
      caminho.contains('\\') ||
      caminho.contains('\u0000') ||
      p.posix.isAbsolute(caminho) ||
      p.posix.normalize(caminho) != caminho) {
    throw FormatException('Caminho relativo inválido: $caminho');
  }
  final partes = p.posix.split(caminho);
  if (partes.any((parte) => parte.isEmpty || parte == '.' || parte == '..')) {
    throw FormatException('Caminho relativo inválido: $caminho');
  }
}

String validarIdentificadorArquivo(String valor) {
  if (!RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
    r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(valor)) {
    throw FormatException('Identificador de arquivo inválido: $valor');
  }
  return valor;
}

Future<void> garantirArquivoRegularDentroDaRaiz(
  Directory raiz,
  File arquivo,
) async {
  final stat = await arquivo.stat();
  if (stat.type != FileSystemEntityType.file) {
    throw FileSystemException(
      'O caminho não é um arquivo regular.',
      arquivo.path,
    );
  }

  final raizReal = await raiz.resolveSymbolicLinks();
  final arquivoReal = await arquivo.resolveSymbolicLinks();
  if (arquivoReal == raizReal || !p.isWithin(raizReal, arquivoReal)) {
    throw FileSystemException(
      'O arquivo está fora do diretório privado esperado.',
      arquivo.path,
    );
  }
}

Future<void> escreverJsonAtomico(
  File destino,
  Map<String, Object?> json,
) async {
  await destino.parent.create(recursive: true);
  final parcial = File('${destino.path}.part');
  if (await parcial.exists()) await parcial.delete();
  final output = parcial.openWrite(mode: FileMode.writeOnly);
  try {
    output.add(utf8.encode(jsonEncode(json)));
    await output.flush();
    await output.close();
    if (await destino.exists()) await destino.delete();
    await parcial.rename(destino.path);
  } catch (_) {
    await output.close().catchError((Object _) {});
    await excluirSemPropagar(parcial);
    rethrow;
  }
}

Future<void> excluirSemPropagar(
  FileSystemEntity entidade, {
  bool recursive = false,
}) async {
  try {
    if (await entidade.exists()) await entidade.delete(recursive: recursive);
  } on FileSystemException {
    // Usado somente para limpar artefatos parciais depois de outra falha.
  }
}

class _DigestSink implements Sink<Digest> {
  Digest? valor;

  @override
  void add(Digest data) => valor = data;

  @override
  void close() {}
}

Uint8List prefixoBytes(List<int> bytes, int quantidade) =>
    Uint8List.fromList(bytes.take(quantidade).toList(growable: false));
