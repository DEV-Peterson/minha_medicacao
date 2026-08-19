import 'dart:io';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/arquivos/arquivo_seguro.dart';
import 'package:minha_medicacao/core/arquivos/exclusao_mutua_arquivos.dart';
import 'package:minha_medicacao/core/backup/backup_manifest.dart';
import 'package:minha_medicacao/core/backup/backup_excecao.dart';
import 'package:minha_medicacao/core/backup/servico_backup.dart';
import 'package:minha_medicacao/core/backup/servico_restauracao_backup.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:path/path.dart' as p;

import '../../drift/app_database/generated/schema_v1.dart' as v1;
import 'backup_teste.dart';

void main() {
  setUpAll(() {
    // O teste abre o banco atual e o arquivo extraído ao mesmo tempo. Eles são
    // executores distintos, então o alerta genérico do Drift não se aplica.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });
  tearDownAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
  });

  late Directory temporario;
  late Directory raizAtual;
  late File bancoAtualArquivo;
  late File zipParaRestaurar;
  AppDatabase? bancoAtual;

  setUp(() async {
    temporario = await Directory.systemTemp.createTemp('restauracao-backup-');
    raizAtual = Directory(p.join(temporario.path, 'atual'));
    bancoAtualArquivo = File(
      p.join(raizAtual.path, 'banco', 'minha_medicacao.sqlite'),
    );

    final raizOrigem = Directory(p.join(temporario.path, 'origem'));
    final bancoOrigemArquivo = File(
      p.join(raizOrigem.path, 'banco', 'minha_medicacao.sqlite'),
    );
    final bancoOrigem = await abrirBancoArquivo(bancoOrigemArquivo);
    await inserirMedicamentoNome(bancoOrigem, 'Estado do backup');
    final resultado = await ServicoBackup(
      bancoOrigem,
      raizDados: () async => raizOrigem,
      diretorioTemporario: () async =>
          Directory(p.join(temporario.path, 'tmp-origem')),
      diretorioBackups: () async =>
          Directory(p.join(temporario.path, 'backups-origem')),
      versaoAplicativo: () async => '1.0.0+1',
      exclusaoMutua: ExclusaoMutuaArquivos(),
    ).criar();
    zipParaRestaurar = resultado.arquivo;
    await bancoOrigem.close();

    bancoAtual = await abrirBancoArquivo(bancoAtualArquivo);
    await inserirMedicamentoNome(bancoAtual!, 'Estado atual');
  });

  tearDown(() async {
    await bancoAtual?.close();
    if (await temporario.exists()) {
      await temporario.delete(recursive: true);
    }
  });

  ServicoRestauracaoBackup criarServico({
    required ExclusaoMutuaArquivos mutex,
    required bool falharNaPrimeiraReabertura,
    required bool falharNotificacoes,
    MigrarBancoRestaurado? migrarBanco,
  }) {
    var reaberturas = 0;
    final backupAtual = ServicoBackup(
      bancoAtual!,
      raizDados: () async => raizAtual,
      diretorioTemporario: () async =>
          Directory(p.join(temporario.path, 'tmp-atual')),
      diretorioBackups: () async =>
          Directory(p.join(temporario.path, 'backups-atual')),
      versaoAplicativo: () async => '1.0.0+1',
      exclusaoMutua: mutex,
    );

    return ServicoRestauracaoBackup(
      ciclo: CicloRestauracaoBackup(
        fecharBanco: () async {
          final atual = bancoAtual;
          bancoAtual = null;
          await atual?.close();
        },
        reabrirBanco: () async {
          reaberturas++;
          if (falharNaPrimeiraReabertura && reaberturas == 1) {
            throw StateError('Falha simulada ao abrir o banco restaurado.');
          }
          bancoAtual = await abrirBancoArquivo(bancoAtualArquivo);
        },
        validarBancoReaberto: () => bancoAtual!.verificarIntegridade(),
        cancelarNotificacoes: () async {},
        reconstruirNotificacoes: () async {
          if (falharNotificacoes) {
            throw StateError('Falha simulada nas notificações.');
          }
        },
        migrarBanco: migrarBanco,
      ),
      criarBackupSeguranca: () async => (await backupAtual.criar()).arquivo,
      raizDados: () async => raizAtual,
      diretorioTemporario: () async =>
          Directory(p.join(temporario.path, 'tmp-restore')),
      arquivoBanco: () async => bancoAtualArquivo,
      exclusaoMutua: mutex,
    );
  }

  test('restaura dados e trata falha de notificações como aviso', () async {
    final mutex = ExclusaoMutuaArquivos();
    final servico = criarServico(
      mutex: mutex,
      falharNaPrimeiraReabertura: false,
      falharNotificacoes: true,
    );

    final resultado = await servico.restaurar(zipParaRestaurar);

    final medicamentos = await bancoAtual!
        .select(bancoAtual!.medicamentos)
        .get();
    expect(medicamentos.single.nome, 'Estado do backup');
    expect(await resultado.backupSeguranca.exists(), isTrue);
    expect(resultado.avisos, hasLength(1));
    expect(resultado.avisos.single.mensagem, contains('notificações'));
    expect(
      await File(
        p.join(raizAtual.path, '.restauracao_em_andamento.json'),
      ).exists(),
      isFalse,
    );
  });

  test('restaura schema 1 após migrar datas civis para schema 2', () async {
    final backupV1 = await _criarBackupSchemaV1(temporario);
    final servico = criarServico(
      mutex: ExclusaoMutuaArquivos(),
      falharNaPrimeiraReabertura: false,
      falharNotificacoes: false,
      migrarBanco: migrarArquivoBanco,
    );

    final resultado = await servico.restaurar(backupV1);

    final tratamento = await bancoAtual!
        .select(bancoAtual!.tratamentos)
        .getSingle();
    final bruto = await bancoAtual!.customSelect('''
          SELECT data_inicio, criado_em
          FROM tratamentos
          WHERE id = 'tratamento-backup-v1'
        ''').getSingle();
    final versao = await bancoAtual!
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(resultado.manifest.versaoSchemaBanco, 1);
    expect(tratamento.dataInicio, DateTime(2026, 8, 18));
    expect(bruto.read<int>('data_inicio'), 20260818);
    expect(
      bruto.read<int>('criado_em'),
      DateTime(2026, 8, 17, 22).millisecondsSinceEpoch ~/ 1000,
    );
    expect(versao.read<int>('user_version'), versaoSchemaBancoAtual);
  });

  test('falha ao abrir banco novo restaura banco anterior', () async {
    final mutex = ExclusaoMutuaArquivos();
    final servico = criarServico(
      mutex: mutex,
      falharNaPrimeiraReabertura: true,
      falharNotificacoes: false,
    );

    await expectLater(
      servico.restaurar(zipParaRestaurar),
      throwsA(
        isA<FalhaNaRestauracao>().having(
          (erro) => erro.rollbackConcluido,
          'rollbackConcluido',
          isTrue,
        ),
      ),
    );

    final medicamentos = await bancoAtual!
        .select(bancoAtual!.medicamentos)
        .get();
    expect(medicamentos.single.nome, 'Estado atual');
    expect(
      await File(
        p.join(raizAtual.path, '.restauracao_em_andamento.json'),
      ).exists(),
      isFalse,
    );
  });

  test(
    'recupera troca interrompida a partir do marcador persistente',
    () async {
      final mutex = ExclusaoMutuaArquivos();
      final servico = criarServico(
        mutex: mutex,
        falharNaPrimeiraReabertura: false,
        falharNotificacoes: false,
      );
      const id = '00000000-0000-4000-8000-000000000000';
      final rollback = Directory(
        p.join(raizAtual.path, '.restauracao_rollback-$id'),
      );
      await rollback.create(recursive: true);
      final aberto = bancoAtual;
      bancoAtual = null;
      await aberto!.close();
      await bancoAtualArquivo.rename(p.join(rollback.path, 'database.sqlite'));
      await bancoAtualArquivo.parent.create(recursive: true);
      await bancoAtualArquivo.writeAsString('banco novo incompleto');
      final marker = File(
        p.join(raizAtual.path, '.restauracao_em_andamento.json'),
      );
      await marker.writeAsString(
        jsonEncode(<String, Object>{
          'operacaoId': id,
          'bancoExistia': true,
          'anexosExistiam': false,
          'backupSeguranca': 'teste.zip',
        }),
      );

      expect(await servico.recuperarSeNecessario(), isTrue);

      final medicamentos = await bancoAtual!
          .select(bancoAtual!.medicamentos)
          .get();
      expect(medicamentos.single.nome, 'Estado atual');
      expect(await marker.exists(), isFalse);
      expect(await rollback.exists(), isFalse);
    },
  );
}

Future<File> _criarBackupSchemaV1(Directory temporario) async {
  final staging = Directory(p.join(temporario.path, 'backup-schema-v1'));
  await staging.create(recursive: true);
  final banco = File(p.join(staging.path, caminhoBancoBackup));
  final criadoEpoch = DateTime(2026, 8, 17, 22).millisecondsSinceEpoch ~/ 1000;
  final inicioEpoch = DateTime(2026, 8, 18).millisecondsSinceEpoch ~/ 1000;

  final legado = v1.DatabaseAtV1(NativeDatabase(banco));
  await legado.customStatement(
    '''
      INSERT INTO medicamentos (
        id, nome, controle_estoque, ativo, criado_em, atualizado_em
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''',
    ['medicamento-backup-v1', 'Estado legado', 0, 1, criadoEpoch, criadoEpoch],
  );
  await legado.customStatement(
    '''
      INSERT INTO tratamentos (
        id, medicamento_id, quantidade_dose, unidade_dose,
        data_inicio, uso_continuo, tipo_agendamento,
        ativo, criado_em, atualizado_em
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
    [
      'tratamento-backup-v1',
      'medicamento-backup-v1',
      1.0,
      'comprimido',
      inicioEpoch,
      1,
      'horariosFixos',
      1,
      criadoEpoch,
      criadoEpoch,
    ],
  );
  await legado.close();

  final resumo = await resumirArquivo(banco);
  final manifest = BackupManifest(
    versaoFormato: versaoFormatoBackupAtual,
    versaoSchemaBanco: 1,
    versaoAplicativo: '1.0.0+1',
    criadoEmUtc: DateTime.utc(2026, 8, 18, 12),
    arquivos: [
      ArquivoManifestoBackup(
        caminho: caminhoBancoBackup,
        tamanhoBytes: resumo.tamanhoBytes,
        sha256: resumo.sha256,
      ),
    ],
  );
  final manifesto = File(p.join(staging.path, caminhoManifestBackup));
  await manifesto.writeAsString(manifest.codificar());

  final zip = File(p.join(temporario.path, 'backup-schema-v1.zip'));
  final encoder = ZipFileEncoder();
  encoder.create(zip.path);
  await encoder.addFile(manifesto, caminhoManifestBackup);
  await encoder.addFile(banco, caminhoBancoBackup);
  await encoder.close();
  return zip;
}
