import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../arquivos/app_paths.dart';
import '../arquivos/arquivo_seguro.dart';
import 'backup_excecao.dart';
import 'limites_backup.dart';

class ServicoSelecaoBackup {
  ServicoSelecaoBackup({
    Future<Directory> Function()? diretorioTemporario,
    Uuid? uuid,
    this.limites = const LimitesBackup(),
  }) : _diretorioTemporario = diretorioTemporario ?? AppPaths.temporarios,
       _uuid = uuid ?? const Uuid();

  final Future<Directory> Function() _diretorioTemporario;
  final Uuid _uuid;
  final LimitesBackup limites;

  /// Abre o seletor do sistema e copia o conteúdo escolhido via stream.
  ///
  /// [PlatformFile.path] não é usado: provedores SAF, inclusive Google Drive,
  /// podem oferecer apenas uma URI legível pelo plugin.
  Future<File?> selecionarParaRestauracao() async {
    final selecionado = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const <String>['zip'],
      dialogTitle: 'Selecione o backup da Minha Medicação',
    );
    if (selecionado == null) return null;
    final tamanho = await selecionado.length();
    if (tamanho > limites.maximoZipBytes) {
      throw BackupInvalido(
        MotivoBackupInvalido.arquivoMuitoGrande,
        'O arquivo selecionado excede o limite permitido.',
      );
    }
    return copiarSelecaoParaTemporario(
      selecionado.readAsByteStream(),
      tamanhoInformado: tamanho,
    );
  }

  Future<File> copiarSelecaoParaTemporario(
    Stream<List<int>> stream, {
    int? tamanhoInformado,
  }) async {
    if (tamanhoInformado != null &&
        (tamanhoInformado <= 0 || tamanhoInformado > limites.maximoZipBytes)) {
      throw BackupInvalido(
        MotivoBackupInvalido.arquivoMuitoGrande,
        'O arquivo selecionado possui tamanho inválido.',
      );
    }
    final temporarios = await _diretorioTemporario();
    await temporarios.create(recursive: true);
    final id = validarIdentificadorArquivo(_uuid.v4());
    final destino = File(p.join(temporarios.path, 'backup-importado-$id.zip'));
    try {
      final resumo = await copiarStreamComHash(
        stream,
        destino,
        limiteBytes: limites.maximoZipBytes,
      );
      if (resumo.tamanhoBytes <= 0 ||
          (tamanhoInformado != null &&
              resumo.tamanhoBytes != tamanhoInformado)) {
        throw const BackupInvalido(
          MotivoBackupInvalido.zipCorrompido,
          'A cópia do arquivo selecionado ficou incompleta.',
        );
      }
      return destino;
    } on LimiteArquivoExcedido catch (erro) {
      await excluirSemPropagar(destino);
      throw BackupInvalido(
        MotivoBackupInvalido.arquivoMuitoGrande,
        'O arquivo selecionado excede o limite permitido.',
        erro,
      );
    } catch (_) {
      await excluirSemPropagar(destino);
      rethrow;
    }
  }
}

class ServicoCompartilhamentoBackup {
  const ServicoCompartilhamentoBackup();

  Future<ShareResult> compartilhar(File backup) async {
    final stat = await backup.stat();
    if (stat.type != FileSystemEntityType.file || stat.size <= 0) {
      throw FileSystemException(
        'O arquivo de backup não está disponível para compartilhar.',
        backup.path,
      );
    }
    return SharePlus.instance.share(
      ShareParams(
        title: 'Backup da Minha Medicação',
        subject: 'Backup da Minha Medicação',
        files: <XFile>[XFile(backup.path, mimeType: 'application/zip')],
        fileNameOverrides: <String>[p.basename(backup.path)],
      ),
    );
  }
}
