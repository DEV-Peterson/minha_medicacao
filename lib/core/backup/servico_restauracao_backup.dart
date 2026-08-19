import 'dart:convert';
import 'dart:io';

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

typedef MigrarBancoRestaurado =
    Future<void> Function(File banco, int versaoOrigem, int versaoDestino);

class CicloRestauracaoBackup {
  const CicloRestauracaoBackup({
    required this.fecharBanco,
    required this.reabrirBanco,
    required this.validarBancoReaberto,
    required this.cancelarNotificacoes,
    required this.reconstruirNotificacoes,
    this.migrarBanco,
    this.atualizarEstado,
  });

  final Future<void> Function() fecharBanco;
  final Future<void> Function() reabrirBanco;
  final Future<void> Function() validarBancoReaberto;
  final Future<void> Function() cancelarNotificacoes;
  final Future<void> Function() reconstruirNotificacoes;
  final MigrarBancoRestaurado? migrarBanco;
  final Future<void> Function()? atualizarEstado;
}

class AvisoRestauracao {
  const AvisoRestauracao(this.mensagem, this.causa);

  final String mensagem;
  final Object causa;
}

class ResultadoRestauracaoBackup {
  const ResultadoRestauracaoBackup({
    required this.manifest,
    required this.backupSeguranca,
    this.avisos = const <AvisoRestauracao>[],
  });

  final BackupManifest manifest;
  final File backupSeguranca;
  final List<AvisoRestauracao> avisos;
}

class ServicoRestauracaoBackup {
  ServicoRestauracaoBackup({
    required this.ciclo,
    required this.criarBackupSeguranca,
    Future<Directory> Function()? raizDados,
    Future<Directory> Function()? diretorioTemporario,
    Future<File> Function()? arquivoBanco,
    ValidadorBackup? validador,
    ExclusaoMutuaArquivos? exclusaoMutua,
    Uuid? uuid,
    this.limites = const LimitesBackup(),
    this.versaoSchemaAtual = versaoSchemaBancoAtual,
    DateTime Function()? agora,
  }) : _raizDados = raizDados ?? AppPaths.raiz,
       _diretorioTemporario = diretorioTemporario ?? AppPaths.temporarios,
       _arquivoBanco = arquivoBanco ?? AppPaths.arquivoBanco,
       _validador =
           validador ??
           ValidadorBackup(
             versaoSchemaAtual: versaoSchemaAtual,
             limites: limites,
           ),
       _exclusaoMutua = exclusaoMutua ?? ExclusaoMutuaArquivos.compartilhada,
       _uuid = uuid ?? const Uuid(),
       _agora = agora ?? const RelogioSistema().agora;

  final CicloRestauracaoBackup ciclo;
  final Future<File> Function() criarBackupSeguranca;
  final Future<Directory> Function() _raizDados;
  final Future<Directory> Function() _diretorioTemporario;
  final Future<File> Function() _arquivoBanco;
  final ValidadorBackup _validador;
  final ExclusaoMutuaArquivos _exclusaoMutua;
  final Uuid _uuid;
  final DateTime Function() _agora;
  final LimitesBackup limites;
  final int versaoSchemaAtual;

  Future<ResultadoRestauracaoBackup> restaurar(File arquivoZip) {
    return _exclusaoMutua.executar(() async {
      final root = await _raizDados();
      final marker = _marker(root);
      if (await marker.exists()) throw const RestauracaoJaEmAndamento();

      final id = validarIdentificadorArquivo(_uuid.v4());
      final temporarios = await _diretorioTemporario();
      final extraido = Directory(p.join(temporarios.path, 'restore-$id'));
      final incoming = _incoming(root, id);
      final rollback = _rollback(root, id);
      final falha = _falha(root, id);
      final commit = _commit(root, id);
      final bancoAtual = await _arquivoBanco();
      _garantirCaminhosDaAplicacao(root, bancoAtual);

      BackupValidado? validado;
      File? backupSeguranca;
      try {
        validado = await _validador.validarEExtrair(arquivoZip, extraido);
        if (validado.manifest.versaoSchemaBanco < versaoSchemaAtual) {
          final migrar = ciclo.migrarBanco;
          if (migrar == null) {
            throw const BackupInvalido(
              MotivoBackupInvalido.schemaIncompativel,
              'O backup exige uma migração que não foi configurada.',
            );
          }
          await migrar(
            validado.banco,
            validado.manifest.versaoSchemaBanco,
            versaoSchemaAtual,
          );
          await _validador.validarBancoRestaurado(
            validado.banco,
            schemaEsperado: versaoSchemaAtual,
            caminhosAnexosEsperados: _caminhosAnexos(validado.manifest),
          );
        }

        // Obrigatório e persistente: permanece disponível mesmo após sucesso.
        backupSeguranca = await criarBackupSeguranca();
        final bancoExistia = await bancoAtual.exists();
        final anexosAtual = Directory(p.join(root.path, 'anexos'));
        final anexosExistiam = await anexosAtual.exists();
        await escreverJsonAtomico(marker, <String, Object?>{
          'operacaoId': id,
          'bancoExistia': bancoExistia,
          'anexosExistiam': anexosExistiam,
          'backupSeguranca': backupSeguranca.path,
        });
        await _prepararIncoming(validado, incoming);

        await ciclo.fecharBanco();
        await _protegerEstadoAtual(
          root: root,
          bancoAtual: bancoAtual,
          rollback: rollback,
          bancoExistia: bancoExistia,
          anexosExistiam: anexosExistiam,
        );
        await _ativarIncoming(
          root: root,
          bancoAtual: bancoAtual,
          incoming: incoming,
        );

        await ciclo.reabrirBanco();
        await ciclo.validarBancoReaberto();
        await escreverJsonAtomico(commit, <String, Object?>{
          'operacaoId': id,
          'concluidoEmUtc': _agora().toUtc().toIso8601String(),
        });
      } on Object catch (erro) {
        if (!await marker.exists()) {
          if (await incoming.exists()) {
            await excluirSemPropagar(incoming, recursive: true);
          }
          if (erro is BackupInvalido) rethrow;
          throw FalhaNaRestauracao(
            'A restauração falhou antes de alterar os dados atuais.',
            causa: erro,
          );
        }
        Object? erroRollback;
        try {
          // Também fecha uma abertura parcial: um callback de reabertura pode
          // lançar depois de já ter adquirido o arquivo.
          await ciclo.fecharBanco();
          final dadosMarker = await _lerMarker(marker);
          await _reverter(
            root: root,
            bancoAtual: bancoAtual,
            id: id,
            bancoExistia: dadosMarker.bancoExistia,
            anexosExistiam: dadosMarker.anexosExistiam,
          );
          await ciclo.reabrirBanco();
          await marker.delete();
        } on Object catch (falhaRollback) {
          erroRollback = falhaRollback;
        }
        throw FalhaNaRestauracao(
          erroRollback == null
              ? 'A restauração falhou e o estado anterior foi recuperado.'
              : 'A restauração e o rollback automático falharam.',
          causa: erro,
          falhaNoRollback: erroRollback,
        );
      } finally {
        await excluirSemPropagar(extraido, recursive: true);
      }

      final avisos = <AvisoRestauracao>[];
      try {
        await ciclo.cancelarNotificacoes();
        await ciclo.reconstruirNotificacoes();
      } on Object catch (erro) {
        avisos.add(
          AvisoRestauracao(
            'Os dados foram restaurados, mas as notificações não puderam ser reconstruídas.',
            erro,
          ),
        );
      }
      final atualizarEstado = ciclo.atualizarEstado;
      if (atualizarEstado != null) {
        try {
          await atualizarEstado();
        } on Object catch (erro) {
          avisos.add(
            AvisoRestauracao(
              'Os dados foram restaurados, mas a tela precisa ser reaberta.',
              erro,
            ),
          );
        }
      }

      await _limparAposCommit(
        marker: marker,
        commit: commit,
        rollback: rollback,
        incoming: incoming,
        falha: falha,
        avisos: avisos,
      );
      return ResultadoRestauracaoBackup(
        manifest: validado.manifest,
        backupSeguranca: backupSeguranca,
        avisos: List<AvisoRestauracao>.unmodifiable(avisos),
      );
    });
  }

  /// Recupera uma troca interrompida. Deve ser chamada antes de expor o banco
  /// ao restante da aplicação durante a inicialização.
  Future<bool> recuperarSeNecessario() {
    return _exclusaoMutua.executar(() async {
      final root = await _raizDados();
      final marker = _marker(root);
      if (!await marker.exists()) return false;
      final dados = await _lerMarker(marker);
      final bancoAtual = await _arquivoBanco();
      _garantirCaminhosDaAplicacao(root, bancoAtual);
      final commit = _commit(root, dados.operacaoId);

      await ciclo.fecharBanco();
      try {
        if (!await commit.exists()) {
          await _reverter(
            root: root,
            bancoAtual: bancoAtual,
            id: dados.operacaoId,
            bancoExistia: dados.bancoExistia,
            anexosExistiam: dados.anexosExistiam,
          );
        }
        await ciclo.reabrirBanco();
        await ciclo.validarBancoReaberto();
      } catch (erro) {
        throw FalhaNaRestauracao(
          'Não foi possível recuperar a restauração interrompida.',
          causa: erro,
        );
      }

      final rollback = _rollback(root, dados.operacaoId);
      final incoming = _incoming(root, dados.operacaoId);
      final falha = _falha(root, dados.operacaoId);
      await _excluirDiretorioSeExistir(rollback);
      await _excluirDiretorioSeExistir(incoming);
      await _excluirDiretorioSeExistir(falha);
      if (await marker.exists()) await marker.delete();
      if (await commit.exists()) await commit.delete();
      return true;
    });
  }

  Future<void> _prepararIncoming(
    BackupValidado validado,
    Directory incoming,
  ) async {
    if (await incoming.exists()) {
      throw const FalhaNaRestauracao(
        'O diretório de preparação da restauração já existe.',
      );
    }
    await incoming.create(recursive: true);
    final bancoDestino = File(p.join(incoming.path, 'database.sqlite'));
    await copiarStreamComHash(
      validado.banco.openRead(),
      bancoDestino,
      limiteBytes: limites.maximoArquivoBytes,
    );
    await Directory(
      p.join(incoming.path, 'anexos', 'medicamentos'),
    ).create(recursive: true);
    await Directory(
      p.join(incoming.path, 'anexos', 'receitas'),
    ).create(recursive: true);
    for (final caminho in _caminhosAnexos(validado.manifest)) {
      final origem = resolverArquivoRelativo(
        validado.diretorioExtraido,
        caminho,
      );
      final destino = resolverArquivoRelativo(incoming, caminho);
      final esperado = validado.manifest.arquivo(caminho);
      final resumo = await copiarStreamComHash(
        origem.openRead(),
        destino,
        limiteBytes: limites.maximoArquivoBytes,
      );
      if (resumo.tamanhoBytes != esperado.tamanhoBytes ||
          resumo.sha256 != esperado.sha256) {
        throw BackupInvalido(
          MotivoBackupInvalido.hashInvalido,
          'O anexo $caminho mudou durante a preparação.',
        );
      }
    }
    await _validador.validarBancoRestaurado(
      bancoDestino,
      schemaEsperado: versaoSchemaAtual,
      caminhosAnexosEsperados: _caminhosAnexos(validado.manifest),
    );
  }

  Future<void> _protegerEstadoAtual({
    required Directory root,
    required File bancoAtual,
    required Directory rollback,
    required bool bancoExistia,
    required bool anexosExistiam,
  }) async {
    await rollback.create(recursive: true);
    if (bancoExistia) {
      await bancoAtual.rename(p.join(rollback.path, 'database.sqlite'));
    }
    for (final sufixo in const <String>['-wal', '-shm', '-journal']) {
      final sidecar = File('${bancoAtual.path}$sufixo');
      if (await sidecar.exists()) {
        await sidecar.rename(p.join(rollback.path, 'database.sqlite$sufixo'));
      }
    }
    final anexos = Directory(p.join(root.path, 'anexos'));
    if (anexosExistiam) {
      await anexos.rename(p.join(rollback.path, 'anexos'));
    }
  }

  Future<void> _ativarIncoming({
    required Directory root,
    required File bancoAtual,
    required Directory incoming,
  }) async {
    await bancoAtual.parent.create(recursive: true);
    await File(
      p.join(incoming.path, 'database.sqlite'),
    ).rename(bancoAtual.path);
    await Directory(
      p.join(incoming.path, 'anexos'),
    ).rename(p.join(root.path, 'anexos'));
  }

  Future<void> _reverter({
    required Directory root,
    required File bancoAtual,
    required String id,
    required bool bancoExistia,
    required bool anexosExistiam,
  }) async {
    final rollback = _rollback(root, id);
    final incoming = _incoming(root, id);
    final falha = _falha(root, id);
    await falha.create(recursive: true);

    final bancoRollback = File(p.join(rollback.path, 'database.sqlite'));
    final restaurandoBancoOriginal = await bancoRollback.exists();
    if (restaurandoBancoOriginal) {
      if (await bancoAtual.exists()) {
        await bancoAtual.rename(p.join(falha.path, 'database.sqlite'));
      }
      await bancoAtual.parent.create(recursive: true);
      await bancoRollback.rename(bancoAtual.path);
    } else if (!bancoExistia && await bancoAtual.exists()) {
      await bancoAtual.rename(p.join(falha.path, 'database.sqlite'));
    }

    for (final sufixo in const <String>['-wal', '-shm', '-journal']) {
      final atual = File('${bancoAtual.path}$sufixo');
      final anterior = File(p.join(rollback.path, 'database.sqlite$sufixo'));
      if (await anterior.exists()) {
        if (await atual.exists()) {
          await atual.rename(p.join(falha.path, 'database.sqlite$sufixo'));
        }
        await anterior.rename(atual.path);
      } else if ((restaurandoBancoOriginal || !bancoExistia) &&
          await atual.exists()) {
        await atual.rename(p.join(falha.path, 'database.sqlite$sufixo'));
      }
    }

    final anexosAtual = Directory(p.join(root.path, 'anexos'));
    final anexosRollback = Directory(p.join(rollback.path, 'anexos'));
    if (await anexosRollback.exists()) {
      if (await anexosAtual.exists()) {
        await anexosAtual.rename(p.join(falha.path, 'anexos'));
      }
      await anexosRollback.rename(anexosAtual.path);
    } else if (!anexosExistiam && await anexosAtual.exists()) {
      await anexosAtual.rename(p.join(falha.path, 'anexos'));
    }

    await _excluirDiretorioSeExistir(incoming);
    await _excluirDiretorioSeExistir(rollback);
    await _excluirDiretorioSeExistir(falha);
  }

  Future<void> _limparAposCommit({
    required File marker,
    required File commit,
    required Directory rollback,
    required Directory incoming,
    required Directory falha,
    required List<AvisoRestauracao> avisos,
  }) async {
    try {
      // Enquanto houver artefatos para limpar, marker + commit fazem a
      // recuperação preservar o banco novo e terminar essa limpeza.
      await _excluirDiretorioSeExistir(rollback);
      await _excluirDiretorioSeExistir(incoming);
      await _excluirDiretorioSeExistir(falha);
      if (await marker.exists()) await marker.delete();
      if (await commit.exists()) await commit.delete();
    } on Object catch (erro) {
      avisos.add(
        AvisoRestauracao(
          'A restauração terminou, mas restaram arquivos temporários internos.',
          erro,
        ),
      );
    }
  }

  Future<_DadosMarker> _lerMarker(File marker) async {
    try {
      final json = jsonDecode(await marker.readAsString());
      if (json is! Map) throw const FormatException('Objeto esperado.');
      final id = json['operacaoId'];
      final bancoExistia = json['bancoExistia'];
      final anexosExistiam = json['anexosExistiam'];
      if (id is! String || bancoExistia is! bool || anexosExistiam is! bool) {
        throw const FormatException('Campos de marcador inválidos.');
      }
      validarIdentificadorArquivo(id);
      return _DadosMarker(
        operacaoId: id,
        bancoExistia: bancoExistia,
        anexosExistiam: anexosExistiam,
      );
    } on Object catch (erro) {
      throw FalhaNaRestauracao(
        'O marcador de restauração está corrompido.',
        causa: erro,
      );
    }
  }

  void _garantirCaminhosDaAplicacao(Directory root, File banco) {
    final raiz = p.normalize(p.absolute(root.path));
    final caminhoBanco = p.normalize(p.absolute(banco.path));
    if (!p.isWithin(raiz, caminhoBanco)) {
      throw const FalhaNaRestauracao(
        'O banco configurado está fora da raiz privada da aplicação.',
      );
    }
  }

  Set<String> _caminhosAnexos(BackupManifest manifest) => manifest.arquivos
      .map((arquivo) => arquivo.caminho)
      .where((caminho) => caminho.startsWith('anexos/'))
      .toSet();

  File _marker(Directory root) =>
      File(p.join(root.path, '.restauracao_em_andamento.json'));

  File _commit(Directory root, String id) =>
      File(p.join(root.path, '.restauracao_concluida-$id.json'));

  Directory _incoming(Directory root, String id) =>
      Directory(p.join(root.path, '.restauracao_entrada-$id'));

  Directory _rollback(Directory root, String id) =>
      Directory(p.join(root.path, '.restauracao_rollback-$id'));

  Directory _falha(Directory root, String id) =>
      Directory(p.join(root.path, '.restauracao_falha-$id'));

  Future<void> _excluirDiretorioSeExistir(Directory diretorio) async {
    if (await diretorio.exists()) await diretorio.delete(recursive: true);
  }
}

class _DadosMarker {
  const _DadosMarker({
    required this.operacaoId,
    required this.bancoExistia,
    required this.anexosExistiam,
  });

  final String operacaoId;
  final bool bancoExistia;
  final bool anexosExistiam;
}
