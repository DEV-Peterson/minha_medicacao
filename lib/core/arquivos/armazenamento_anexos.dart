import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import 'app_paths.dart';
import 'arquivo_seguro.dart';

enum TipoArquivoAnexo {
  fotoMedicamento('fotoMedicamento', 'medicamentos'),
  receita('receita', 'receitas');

  const TipoArquivoAnexo(this.valorBanco, this.diretorio);

  final String valorBanco;
  final String diretorio;

  static TipoArquivoAnexo doBanco(String valor) => values.firstWhere(
    (tipo) => tipo.valorBanco == valor,
    orElse: () => throw ArgumentError.value(valor, 'valor', 'Tipo inválido'),
  );
}

class ArquivoAnexoSalvo {
  const ArquivoAnexoSalvo({
    required this.caminhoRelativo,
    required this.tamanhoBytes,
  });

  final String caminhoRelativo;
  final int tamanhoBytes;
}

class FormatoImagemNaoSuportado implements Exception {
  const FormatoImagemNaoSuportado();

  @override
  String toString() => 'O arquivo selecionado não é uma imagem suportada.';
}

class ArmazenamentoAnexos {
  ArmazenamentoAnexos({
    Future<Directory> Function()? raiz,
    Uuid? uuid,
    this.limiteImagemBytes = 40 * 1024 * 1024,
  }) : _raiz = raiz ?? AppPaths.raiz,
       _uuid = uuid ?? const Uuid();

  final Future<Directory> Function() _raiz;
  final Uuid _uuid;
  final int limiteImagemBytes;

  Future<ArquivoAnexoSalvo> importarImagem(
    XFile origem,
    TipoArquivoAnexo tipo,
  ) async {
    final root = await _raiz();
    await root.create(recursive: true);
    final diretorio = Directory(p.join(root.path, 'anexos', tipo.diretorio));
    await diretorio.create(recursive: true);

    // Copia primeiro com extensão neutra. A extensão final vem da assinatura
    // do conteúdo, nunca apenas do nome fornecido pelo seletor.
    final id = validarIdentificadorArquivo(_uuid.v4());
    final temporario = File(p.join(diretorio.path, '$id.imagem'));
    final resumo = await copiarStreamComHash(
      origem.openRead(),
      temporario,
      limiteBytes: limiteImagemBytes,
    );

    try {
      final extensao = await _detectarExtensao(temporario);
      if (extensao == null) throw const FormatoImagemNaoSuportado();
      final finalFile = File(p.join(diretorio.path, '$id.$extensao'));
      if (await finalFile.exists()) {
        throw FileSystemException(
          'Já existe um anexo com o identificador gerado.',
          finalFile.path,
        );
      }
      await temporario.rename(finalFile.path);
      final relativo = p.posix.join(
        'anexos',
        tipo.diretorio,
        p.basename(finalFile.path),
      );
      return ArquivoAnexoSalvo(
        caminhoRelativo: relativo,
        tamanhoBytes: resumo.tamanhoBytes,
      );
    } catch (_) {
      await excluirSemPropagar(temporario);
      rethrow;
    }
  }

  Future<File> resolver(String caminhoRelativo) async {
    final root = await _raiz();
    final arquivo = resolverArquivoRelativo(root, caminhoRelativo);
    await garantirArquivoRegularDentroDaRaiz(root, arquivo);
    return arquivo;
  }

  Future<void> excluirSeExistir(String caminhoRelativo) async {
    final root = await _raiz();
    final arquivo = resolverArquivoRelativo(root, caminhoRelativo);
    if (!await arquivo.exists()) return;
    await garantirArquivoRegularDentroDaRaiz(root, arquivo);
    await arquivo.delete();
  }

  Future<String?> _detectarExtensao(File arquivo) async {
    final bytes = await arquivo
        .openRead(0, 16)
        .fold<List<int>>(
          <int>[],
          (anteriores, bloco) => anteriores..addAll(bloco),
        );
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'jpg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a) {
      return 'png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'webp';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp') {
      final marca = String.fromCharCodes(bytes.sublist(8, 12));
      if (<String>{'heic', 'heix', 'hevc', 'hevx'}.contains(marca)) {
        return 'heic';
      }
      if (<String>{'mif1', 'msf1', 'heif'}.contains(marca)) {
        return 'heif';
      }
    }
    return null;
  }
}
