import 'dart:io';
import 'dart:math' as math;

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

import '../arquivos/arquivo_seguro.dart';
import '../banco/app_database.dart';
import 'backup_excecao.dart';
import 'backup_manifest.dart';
import 'limites_backup.dart';

class BackupValidado {
  const BackupValidado({
    required this.manifest,
    required this.diretorioExtraido,
  });

  final BackupManifest manifest;
  final Directory diretorioExtraido;

  File get banco =>
      resolverArquivoRelativo(diretorioExtraido, caminhoBancoBackup);

  Directory get anexos => Directory(p.join(diretorioExtraido.path, 'anexos'));
}

class ValidadorBackup {
  const ValidadorBackup({
    this.versaoSchemaAtual = versaoSchemaBancoAtual,
    this.versaoSchemaMinima = 1,
    this.limites = const LimitesBackup(),
  });

  final int versaoSchemaAtual;
  final int versaoSchemaMinima;
  final LimitesBackup limites;

  Future<BackupValidado> validarEExtrair(File zip, Directory destino) async {
    if (await destino.exists()) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O diretório de validação precisa ser novo.',
      );
    }
    final tamanhoZip = await zip.length();
    if (tamanhoZip <= 0 || tamanhoZip > limites.maximoZipBytes) {
      throw BackupInvalido(
        MotivoBackupInvalido.arquivoMuitoGrande,
        'O ZIP está vazio ou excede o limite de ${limites.maximoZipBytes} bytes.',
      );
    }
    final assinatura = await zip
        .openRead(0, 4)
        .fold<List<int>>(<int>[], (anterior, bloco) => anterior..addAll(bloco));
    if (assinatura.length != 4 ||
        assinatura[0] != 0x50 ||
        assinatura[1] != 0x4b ||
        assinatura[2] != 0x03 ||
        assinatura[3] != 0x04) {
      throw const BackupInvalido(
        MotivoBackupInvalido.zipCorrompido,
        'O arquivo não possui uma assinatura ZIP válida.',
      );
    }
    await _validarCatalogoZip(zip, tamanhoZip);

    await destino.create(recursive: true);
    try {
      return await _validarEExtrairInterno(zip, destino);
    } catch (_) {
      await excluirSemPropagar(destino, recursive: true);
      rethrow;
    }
  }

  Future<BackupValidado> _validarEExtrairInterno(
    File zip,
    Directory destino,
  ) async {
    InputFileStream? input;
    Archive? archive;
    final nomes = <String>{};
    final nomesSemCaixa = <String>{};
    var numeroEntradas = 0;
    var totalDeclarado = 0;

    try {
      input = InputFileStream(zip.path);
      archive = ZipDecoder().decodeStream(
        input,
        callback: (entrada) {
          numeroEntradas++;
          if (numeroEntradas > limites.maximoEntradas) {
            throw const BackupInvalido(
              MotivoBackupInvalido.limiteExcedido,
              'O ZIP contém arquivos demais.',
            );
          }
          _validarEntrada(entrada, nomes, nomesSemCaixa);
          totalDeclarado += entrada.size;
          if (totalDeclarado > limites.maximoTotalExtraidoBytes) {
            throw const BackupInvalido(
              MotivoBackupInvalido.limiteExcedido,
              'O conteúdo descompactado excede o limite permitido.',
            );
          }
        },
      );

      final entradaManifest = archive.find(caminhoManifestBackup);
      if (entradaManifest == null ||
          entradaManifest.size > limites.maximoManifestBytes) {
        throw const BackupInvalido(
          MotivoBackupInvalido.manifestInvalido,
          'O manifest está ausente ou excede o limite permitido.',
        );
      }
      final memoriaManifest = OutputMemoryStream(
        size: math.min(entradaManifest.size, limites.maximoManifestBytes),
      );
      final manifestLimitado = _OutputLimitado(
        memoriaManifest,
        limite: limites.maximoManifestBytes,
        registrarBytes: (_) {},
      );
      entradaManifest.writeContent(manifestLimitado, freeMemory: false);
      final bytesManifest = memoriaManifest.getBytes();
      if (bytesManifest.length != entradaManifest.size) {
        throw const BackupInvalido(
          MotivoBackupInvalido.manifestInvalido,
          'O tamanho real do manifest é inválido.',
        );
      }
      final manifest = BackupManifest.decodificar(bytesManifest);
      _validarCompatibilidade(manifest);

      final esperados = <String>{
        caminhoManifestBackup,
        for (final arquivo in manifest.arquivos) arquivo.caminho,
      };
      if (esperados.length != nomes.length || !esperados.containsAll(nomes)) {
        throw const BackupInvalido(
          MotivoBackupInvalido.estruturaInvalida,
          'O ZIP contém arquivos ausentes ou não declarados no manifest.',
        );
      }

      var totalReal = 0;
      for (final entrada in archive) {
        final declarado = entrada.name == caminhoManifestBackup
            ? null
            : manifest.arquivo(entrada.name);
        if (declarado != null && declarado.tamanhoBytes != entrada.size) {
          throw BackupInvalido(
            MotivoBackupInvalido.hashInvalido,
            'O tamanho declarado de ${entrada.name} não corresponde ao ZIP.',
          );
        }

        final arquivo = resolverArquivoRelativo(destino, entrada.name);
        await arquivo.parent.create(recursive: true);
        final parcial = File('${arquivo.path}.part');
        final output = OutputFileStream(parcial.path);
        final limiteEntrada = entrada.name == caminhoManifestBackup
            ? limites.maximoManifestBytes
            : math.min(limites.maximoArquivoBytes, declarado!.tamanhoBytes);
        final limitado = _OutputLimitado(
          output,
          limite: limiteEntrada,
          registrarBytes: (quantidade) {
            totalReal += quantidade;
            if (totalReal > limites.maximoTotalExtraidoBytes) {
              throw const BackupInvalido(
                MotivoBackupInvalido.limiteExcedido,
                'O conteúdo real descompactado excede o limite permitido.',
              );
            }
          },
        );
        try {
          entrada.writeContent(limitado);
          await output.close();
          if (limitado.length != entrada.size) {
            throw BackupInvalido(
              MotivoBackupInvalido.hashInvalido,
              'O tamanho real de ${entrada.name} é inválido.',
            );
          }
          await parcial.rename(arquivo.path);
        } catch (_) {
          await output.close().catchError((Object _) {});
          await excluirSemPropagar(parcial);
          rethrow;
        }

        if (declarado != null) {
          final resumo = await resumirArquivo(arquivo);
          if (resumo.tamanhoBytes != declarado.tamanhoBytes ||
              resumo.sha256 != declarado.sha256) {
            throw BackupInvalido(
              MotivoBackupInvalido.hashInvalido,
              'O arquivo ${entrada.name} está corrompido.',
            );
          }
        }
      }

      final banco = resolverArquivoRelativo(destino, caminhoBancoBackup);
      final caminhosAnexos = manifest.arquivos
          .map((arquivo) => arquivo.caminho)
          .where((caminho) => caminho.startsWith('anexos/'))
          .toSet();
      await validarBancoRestaurado(
        banco,
        schemaEsperado: manifest.versaoSchemaBanco,
        caminhosAnexosEsperados: caminhosAnexos,
      );
      return BackupValidado(manifest: manifest, diretorioExtraido: destino);
    } on BackupInvalido {
      rethrow;
    } on Object catch (erro) {
      throw BackupInvalido(
        MotivoBackupInvalido.zipCorrompido,
        'Não foi possível ler o arquivo ZIP.',
        erro,
      );
    } finally {
      await archive?.clear().catchError((Object _) {});
      await input?.close().catchError((Object _) {});
    }
  }

  Future<void> validarBancoRestaurado(
    File banco, {
    required int schemaEsperado,
    Set<String>? caminhosAnexosEsperados,
  }) async {
    final cabecalho = await banco
        .openRead(0, 16)
        .fold<List<int>>(<int>[], (anterior, bloco) => anterior..addAll(bloco));
    if (String.fromCharCodes(cabecalho) != 'SQLite format 3\u0000') {
      throw const BackupInvalido(
        MotivoBackupInvalido.bancoInvalido,
        'O arquivo database.sqlite não possui cabeçalho SQLite válido.',
      );
    }

    final database = NativeDatabase(
      banco,
      enableMigrations: false,
      setup: (database) {
        database.execute('PRAGMA query_only = ON');
        database.execute('PRAGMA trusted_schema = OFF');
      },
    );
    try {
      await database.ensureOpen(_UsuarioLeituraSqlite(schemaEsperado));
      final versao =
          (await database.runSelect(
                'PRAGMA user_version',
                const <Object?>[],
              )).single['user_version']
              as int;
      if (versao != schemaEsperado) {
        throw BackupInvalido(
          MotivoBackupInvalido.schemaIncompativel,
          'O schema do SQLite ($versao) difere do manifest ($schemaEsperado).',
        );
      }

      final integridade = await database.runSelect(
        'PRAGMA integrity_check',
        const <Object?>[],
      );
      if (integridade.length != 1 ||
          integridade.single['integrity_check'] != 'ok') {
        throw const BackupInvalido(
          MotivoBackupInvalido.bancoInvalido,
          'O SQLite não passou no PRAGMA integrity_check.',
        );
      }
      final chavesEstrangeiras = await database.runSelect(
        'PRAGMA foreign_key_check',
        const <Object?>[],
      );
      if (chavesEstrangeiras.isNotEmpty) {
        throw const BackupInvalido(
          MotivoBackupInvalido.bancoInvalido,
          'O SQLite contém referências de chave estrangeira inválidas.',
        );
      }

      final tabelas = (await database.runSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
        const <Object?>[],
      )).map((linha) => linha['name'] as String).toSet();
      const obrigatorias = <String>{
        'medicamentos',
        'tratamentos',
        'horarios_tratamento',
        'registros_dose',
        'movimentacoes_estoque',
        'anexos',
        'configuracoes',
        'adiamentos_dose',
      };
      if (!tabelas.containsAll(obrigatorias)) {
        throw const BackupInvalido(
          MotivoBackupInvalido.bancoInvalido,
          'O SQLite não contém todas as tabelas obrigatórias.',
        );
      }
      const consultasEstruturais = <String>[
        'SELECT id, nome, concentracao, forma_farmaceutica, '
            'unidade_dose_padrao, unidade_estoque, observacoes, '
            'controle_estoque, ativo, criado_em, atualizado_em '
            'FROM medicamentos LIMIT 0',
        'SELECT id, medicamento_id, quantidade_dose, unidade_dose, '
            'consumo_estoque_por_dose, data_inicio, data_fim, uso_continuo, '
            'tipo_agendamento, data_hora_ancora, intervalo_minutos, '
            'instrucoes, ativo, encerrado_em, criado_em, atualizado_em '
            'FROM tratamentos LIMIT 0',
        'SELECT id, tratamento_id, hora, minuto, ordem '
            'FROM horarios_tratamento LIMIT 0',
        'SELECT id, dose_key, tratamento_id, medicamento_id, '
            'data_hora_programada, data_hora_acao, quantidade_dose, '
            'unidade_dose, status, observacao, criado_em, atualizado_em '
            'FROM registros_dose LIMIT 0',
        'SELECT id, medicamento_id, registro_dose_id, '
            'movimentacao_origem_id, tipo, quantidade, unidade, data_hora, '
            'observacao FROM movimentacoes_estoque LIMIT 0',
        'SELECT id, medicamento_id, tipo, caminho_relativo, nome_original, '
            'criado_em FROM anexos LIMIT 0',
        'SELECT chave, valor, atualizado_em FROM configuracoes LIMIT 0',
        'SELECT id, dose_key, tratamento_id, medicamento_id, '
            'data_hora_programada, lembrar_em, notificacao_id, criado_em '
            'FROM adiamentos_dose LIMIT 0',
      ];
      for (final consulta in consultasEstruturais) {
        await database.runSelect(consulta, const <Object?>[]);
      }

      if (caminhosAnexosEsperados != null) {
        final anexos = await database.runSelect(
          'SELECT tipo, caminho_relativo FROM anexos',
          const <Object?>[],
        );
        final caminhosBanco = <String>{};
        for (final anexo in anexos) {
          final caminhoRelativo = anexo['caminho_relativo'] as String;
          final tipo = anexo['tipo'] as String;
          try {
            validarCaminhoRelativo(caminhoRelativo);
          } on FormatException catch (erro) {
            throw BackupInvalido(
              MotivoBackupInvalido.anexoInconsistente,
              'O banco contém caminho de anexo inseguro.',
              erro,
            );
          }
          final prefixo = tipo == 'fotoMedicamento'
              ? 'anexos/medicamentos/'
              : tipo == 'receita'
              ? 'anexos/receitas/'
              : '';
          if (prefixo.isEmpty || !caminhoRelativo.startsWith(prefixo)) {
            throw const BackupInvalido(
              MotivoBackupInvalido.anexoInconsistente,
              'Um anexo está armazenado em diretório incompatível com seu tipo.',
            );
          }
          if (!caminhosBanco.add(caminhoRelativo)) {
            throw const BackupInvalido(
              MotivoBackupInvalido.anexoInconsistente,
              'O banco referencia o mesmo arquivo de anexo mais de uma vez.',
            );
          }
        }
        if (caminhosBanco.length != caminhosAnexosEsperados.length ||
            !caminhosBanco.containsAll(caminhosAnexosEsperados)) {
          throw const BackupInvalido(
            MotivoBackupInvalido.anexoInconsistente,
            'Os anexos do ZIP não correspondem aos vínculos do banco.',
          );
        }
      }
    } on BackupInvalido {
      rethrow;
    } on Object catch (erro) {
      throw BackupInvalido(
        MotivoBackupInvalido.bancoInvalido,
        'Não foi possível validar o banco SQLite.',
        erro,
      );
    } finally {
      await database.close().catchError((Object _) {});
    }
  }

  void _validarCompatibilidade(BackupManifest manifest) {
    if (manifest.versaoFormato != versaoFormatoBackupAtual) {
      throw BackupInvalido(
        MotivoBackupInvalido.formatoIncompativel,
        'Versão de formato de backup não suportada: '
        '${manifest.versaoFormato}.',
      );
    }
    if (manifest.versaoSchemaBanco < versaoSchemaMinima ||
        manifest.versaoSchemaBanco > versaoSchemaAtual) {
      throw BackupInvalido(
        MotivoBackupInvalido.schemaIncompativel,
        'Versão de banco não suportada: ${manifest.versaoSchemaBanco}.',
      );
    }
  }

  Future<void> _validarCatalogoZip(File zip, int tamanhoZip) async {
    // O decoder do pacote materializa o catálogo antes de chamar callbacks.
    // Validar o EOCD primeiro impede que uma contagem falsa force milhões de
    // objetos em memória antes de aplicarmos [maximoEntradas].
    final tamanhoCauda = math.min(tamanhoZip, 65 * 1024 + 22);
    final inicioCauda = tamanhoZip - tamanhoCauda;
    final cauda = await zip
        .openRead(inicioCauda, tamanhoZip)
        .fold<List<int>>(<int>[], (anterior, bloco) => anterior..addAll(bloco));
    var eocd = -1;
    for (var i = cauda.length - 22; i >= 0; i--) {
      if (cauda[i] == 0x50 &&
          cauda[i + 1] == 0x4b &&
          cauda[i + 2] == 0x05 &&
          cauda[i + 3] == 0x06) {
        eocd = i;
        break;
      }
    }
    if (eocd < 0) {
      throw const BackupInvalido(
        MotivoBackupInvalido.zipCorrompido,
        'O catálogo central do ZIP não foi encontrado.',
      );
    }
    int u16(int offset) =>
        cauda[eocd + offset] | (cauda[eocd + offset + 1] << 8);
    int u32(int offset) => u16(offset) | (u16(offset + 2) << 16);

    final disco = u16(4);
    final discoCatalogo = u16(6);
    final entradasDisco = u16(8);
    final entradas = u16(10);
    final tamanhoCatalogo = u32(12);
    final offsetCatalogo = u32(16);
    final tamanhoComentario = u16(20);
    final posicaoEocd = inicioCauda + eocd;
    if (disco != 0 ||
        discoCatalogo != 0 ||
        entradasDisco != entradas ||
        entradas <= 0 ||
        entradas > limites.maximoEntradas ||
        entradas == 0xffff ||
        tamanhoCatalogo == 0xffffffff ||
        offsetCatalogo == 0xffffffff ||
        eocd + 22 + tamanhoComentario != cauda.length ||
        offsetCatalogo + tamanhoCatalogo != posicaoEocd) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O catálogo do ZIP é inválido, multidisco, ZIP64 ou excede os limites.',
      );
    }
  }

  void _validarEntrada(
    ArchiveFile entrada,
    Set<String> nomes,
    Set<String> nomesSemCaixa,
  ) {
    final nome = entrada.name;
    try {
      validarCaminhoRelativo(nome);
    } on FormatException catch (erro) {
      throw BackupInvalido(
        MotivoBackupInvalido.caminhoInseguro,
        'O ZIP contém caminho inseguro.',
        erro,
      );
    }
    if (!entrada.isFile || entrada.isSymbolicLink) {
      throw const BackupInvalido(
        MotivoBackupInvalido.caminhoInseguro,
        'Diretórios e links não são aceitos no backup.',
      );
    }
    if (!nomes.add(nome) || !nomesSemCaixa.add(nome.toLowerCase())) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O ZIP contém nomes duplicados ou ambíguos.',
      );
    }
    if (!_nomePermitido(nome)) {
      throw BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O ZIP contém um arquivo não permitido: $nome.',
      );
    }
    if (entrada.size < 0 || entrada.size > limites.maximoArquivoBytes) {
      throw const BackupInvalido(
        MotivoBackupInvalido.limiteExcedido,
        'Uma entrada excede o limite individual permitido.',
      );
    }
    final raw = entrada.rawContent;
    if (raw is ZipFile && (raw.flags & 0x1) != 0) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'ZIPs criptografados não são suportados.',
      );
    }
    if (raw is! ZipFile) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O ZIP usa um método de armazenamento não suportado.',
      );
    }
    final header = raw.header;
    if (header == null ||
        (header.compressionMethod != 0 && header.compressionMethod != 8) ||
        header.diskNumberStart != 0) {
      throw const BackupInvalido(
        MotivoBackupInvalido.estruturaInvalida,
        'O catálogo da entrada ZIP é inválido.',
      );
    }
    final comprimido = raw.length;
    if (entrada.size > 0 && comprimido <= 0) {
      throw const BackupInvalido(
        MotivoBackupInvalido.zipCorrompido,
        'Uma entrada possui tamanho comprimido inválido.',
      );
    }
    if (comprimido > 0 &&
        entrada.size / comprimido > limites.maximaRazaoCompressao) {
      throw const BackupInvalido(
        MotivoBackupInvalido.limiteExcedido,
        'O ZIP apresenta razão de compressão insegura.',
      );
    }
  }

  bool _nomePermitido(String nome) {
    if (nome == caminhoManifestBackup || nome == caminhoBancoBackup) {
      return true;
    }
    return RegExp(
      r'^anexos/(medicamentos|receitas)/'
      r'[A-Za-z0-9][A-Za-z0-9._-]{0,127}\.'
      r'(jpg|jpeg|png|webp|heic|heif)$',
    ).hasMatch(nome);
  }
}

class _UsuarioLeituraSqlite implements QueryExecutorUser {
  const _UsuarioLeituraSqlite(this.schemaVersion);

  @override
  final int schemaVersion;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

class _OutputLimitado extends OutputStream {
  _OutputLimitado(
    this._destino, {
    required this.limite,
    required this.registrarBytes,
  }) : super(byteOrder: _destino.byteOrder);

  final OutputStream _destino;
  final int limite;
  final void Function(int quantidade) registrarBytes;
  int _tamanho = 0;

  @override
  int get length => _tamanho;

  void _antesDeEscrever(int quantidade) {
    if (quantidade < 0 || _tamanho + quantidade > limite) {
      throw const BackupInvalido(
        MotivoBackupInvalido.limiteExcedido,
        'Uma entrada descompactou além do limite permitido.',
      );
    }
    registrarBytes(quantidade);
    _tamanho += quantidade;
  }

  @override
  void writeByte(int value) {
    _antesDeEscrever(1);
    _destino.writeByte(value);
  }

  @override
  void writeBytes(List<int> bytes, {int? length}) {
    final quantidade = length ?? bytes.length;
    _antesDeEscrever(quantidade);
    _destino.writeBytes(bytes, length: quantidade);
  }

  @override
  void writeStream(InputStream stream) {
    while (!stream.isEOS) {
      final quantidade = math.min(64 * 1024, stream.length);
      writeBytes(stream.readBytes(quantidade).toUint8List());
    }
  }

  @override
  void flush() => _destino.flush();

  @override
  void clear() => _destino.clear();

  @override
  Uint8List subset(int start, [int? end]) => _destino.subset(start, end);
}
