import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../arquivos/app_paths.dart';
import '../arquivos/arquivo_seguro.dart';
import '../arquivos/exclusao_mutua_arquivos.dart';
import '../banco/app_database.dart';
import '../data_hora/relogio.dart';
import 'backup_excecao.dart';
import 'backup_manifest.dart';
import 'limites_backup.dart';
import 'validador_backup.dart';

class ResultadoCriacaoBackup {
  const ResultadoCriacaoBackup({required this.arquivo, required this.manifest});

  final File arquivo;
  final BackupManifest manifest;
}

class ServicoBackup {
  ServicoBackup(
    this._db, {
    Future<Directory> Function()? raizDados,
    Future<Directory> Function()? diretorioTemporario,
    Future<Directory> Function()? diretorioBackups,
    Future<String> Function()? versaoAplicativo,
    DateTime Function()? agora,
    Uuid? uuid,
    ExclusaoMutuaArquivos? exclusaoMutua,
    ValidadorBackup? validador,
    this.limites = const LimitesBackup(),
  }) : _raizDados = raizDados ?? AppPaths.raiz,
       _diretorioTemporario = diretorioTemporario ?? AppPaths.temporarios,
       _diretorioBackups = diretorioBackups ?? AppPaths.backups,
       _versaoAplicativo = versaoAplicativo ?? _obterVersaoAplicativo,
       _agora = agora ?? const RelogioSistema().agora,
       _uuid = uuid ?? const Uuid(),
       _exclusaoMutua = exclusaoMutua ?? ExclusaoMutuaArquivos.compartilhada,
       _validador =
           validador ??
           ValidadorBackup(
             versaoSchemaAtual: _db.schemaVersion,
             limites: limites,
           );

  final AppDatabase _db;
  final Future<Directory> Function() _raizDados;
  final Future<Directory> Function() _diretorioTemporario;
  final Future<Directory> Function() _diretorioBackups;
  final Future<String> Function() _versaoAplicativo;
  final DateTime Function() _agora;
  final Uuid _uuid;
  final ExclusaoMutuaArquivos _exclusaoMutua;
  final ValidadorBackup _validador;
  final LimitesBackup limites;

  Future<ResultadoCriacaoBackup> criar() {
    return _exclusaoMutua.executar(() async {
      final operacaoId = validarIdentificadorArquivo(_uuid.v4());
      final temporarios = await _diretorioTemporario();
      final staging = Directory(p.join(temporarios.path, 'backup-$operacaoId'));
      final validacao = Directory(
        p.join(temporarios.path, 'validacao-$operacaoId'),
      );
      await staging.create(recursive: true);

      File? parcial;
      try {
        final root = await _raizDados();
        final entradas = <ArquivoManifestoBackup>[];
        var totalConteudo = 0;
        await _db.exclusively(() async {
          final anexos =
              await (_db.select(_db.anexos)..orderBy([
                    (anexo) => OrderingTerm.asc(anexo.caminhoRelativo),
                  ]))
                  .get();
          if (anexos.length + 2 > limites.maximoEntradas) {
            throw const FalhaAoCriarBackup(
              'A quantidade de anexos excede o limite do formato de backup.',
            );
          }
          final snapshot = File(p.join(staging.path, caminhoBancoBackup));
          if (await snapshot.exists()) await snapshot.delete();
          await _db.customStatement('VACUUM INTO ?', <Object?>[snapshot.path]);
          final resumoBanco = await resumirArquivo(snapshot);
          if (resumoBanco.tamanhoBytes > limites.maximoArquivoBytes) {
            throw const FalhaAoCriarBackup(
              'O banco de dados excede o limite individual do backup.',
            );
          }
          totalConteudo += resumoBanco.tamanhoBytes;
          if (totalConteudo > limites.maximoTotalExtraidoBytes) {
            throw const FalhaAoCriarBackup(
              'O conteúdo total excede o limite do backup.',
            );
          }
          entradas.add(
            ArquivoManifestoBackup(
              caminho: caminhoBancoBackup,
              tamanhoBytes: resumoBanco.tamanhoBytes,
              sha256: resumoBanco.sha256,
            ),
          );

          final caminhos = <String>{};
          final caminhosSemCaixa = <String>{};
          for (final anexo in anexos) {
            final relativo = anexo.caminhoRelativo;
            _validarCaminhoAnexo(relativo, anexo.tipo);
            if (!caminhos.add(relativo) ||
                !caminhosSemCaixa.add(relativo.toLowerCase())) {
              throw const FalhaAoCriarBackup(
                'O banco contém caminhos de anexo duplicados.',
              );
            }
            final origem = resolverArquivoRelativo(root, relativo);
            await garantirArquivoRegularDentroDaRaiz(root, origem);
            final destino = resolverArquivoRelativo(staging, relativo);
            final resumo = await copiarStreamComHash(
              origem.openRead(),
              destino,
              limiteBytes: limites.maximoArquivoBytes,
            );
            totalConteudo += resumo.tamanhoBytes;
            if (totalConteudo > limites.maximoTotalExtraidoBytes) {
              throw const FalhaAoCriarBackup(
                'O conteúdo total excede o limite do backup.',
              );
            }
            entradas.add(
              ArquivoManifestoBackup(
                caminho: relativo,
                tamanhoBytes: resumo.tamanhoBytes,
                sha256: resumo.sha256,
              ),
            );
          }
        });

        final manifest = BackupManifest(
          versaoFormato: versaoFormatoBackupAtual,
          versaoSchemaBanco: _db.schemaVersion,
          versaoAplicativo: await _versaoAplicativo(),
          criadoEmUtc: _agora().toUtc(),
          arquivos: entradas,
        );
        final manifestFile = File(p.join(staging.path, caminhoManifestBackup));
        await escreverJsonAtomico(manifestFile, manifest.toJson());

        final backups = await _diretorioBackups();
        await backups.create(recursive: true);
        final nome = _nomeBackup(manifest.criadoEmUtc, operacaoId);
        final destino = File(p.join(backups.path, nome));
        parcial = File('${destino.path}.part');
        if (await parcial.exists()) await parcial.delete();
        if (await destino.exists()) {
          throw FalhaAoCriarBackup('O arquivo de backup já existe: $nome');
        }

        final encoder = ZipFileEncoder();
        var aberto = false;
        try {
          encoder.create(parcial.path);
          aberto = true;
          await encoder.addFile(manifestFile, caminhoManifestBackup);
          for (final entrada in entradas) {
            await encoder.addFile(
              resolverArquivoRelativo(staging, entrada.caminho),
              entrada.caminho,
            );
          }
          await encoder.close();
          aberto = false;
          if (await parcial.length() > limites.maximoZipBytes) {
            throw const FalhaAoCriarBackup(
              'O ZIP gerado excede o limite permitido.',
            );
          }
        } catch (_) {
          if (aberto) await encoder.close().catchError((Object _) {});
          rethrow;
        }

        final validado = await _validador.validarEExtrair(parcial, validacao);
        if (validado.manifest.codificar() != manifest.codificar()) {
          throw const FalhaAoCriarBackup(
            'O ZIP gerado não preservou o manifest esperado.',
          );
        }
        await validacao.delete(recursive: true);
        await parcial.rename(destino.path);
        parcial = null;
        return ResultadoCriacaoBackup(arquivo: destino, manifest: manifest);
      } on FalhaAoCriarBackup {
        rethrow;
      } on Object catch (erro) {
        throw FalhaAoCriarBackup(
          'Não foi possível criar um backup consistente.',
          erro,
        );
      } finally {
        if (parcial != null && await parcial.exists()) {
          await excluirSemPropagar(parcial);
        }
        await excluirSemPropagar(validacao, recursive: true);
        await excluirSemPropagar(staging, recursive: true);
      }
    });
  }

  void _validarCaminhoAnexo(String caminho, String tipo) {
    try {
      validarCaminhoRelativo(caminho);
    } on FormatException catch (erro) {
      throw FalhaAoCriarBackup('Caminho de anexo inválido.', erro);
    }
    final prefixo = tipo == 'fotoMedicamento'
        ? 'anexos/medicamentos/'
        : tipo == 'receita'
        ? 'anexos/receitas/'
        : '';
    if (prefixo.isEmpty || !caminho.startsWith(prefixo)) {
      throw const FalhaAoCriarBackup(
        'O tipo e o diretório de um anexo são incompatíveis.',
      );
    }
  }
}

Future<String> _obterVersaoAplicativo() async {
  final info = await PackageInfo.fromPlatform();
  return info.buildNumber.isEmpty
      ? info.version
      : '${info.version}+${info.buildNumber}';
}

String _nomeBackup(DateTime dataUtc, String id) {
  String dois(int valor) => valor.toString().padLeft(2, '0');
  final local = dataUtc.toLocal();
  final sufixo = id.replaceAll('-', '').substring(0, 8);
  return 'medicamentos_backup_${local.year}-'
      '${dois(local.month)}-${dois(local.day)}_'
      '${dois(local.hour)}${dois(local.minute)}${dois(local.second)}_'
      '$sufixo.zip';
}
