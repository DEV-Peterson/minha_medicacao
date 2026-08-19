import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/arquivos/exclusao_mutua_arquivos.dart';
import 'package:minha_medicacao/core/backup/backup_excecao.dart';
import 'package:minha_medicacao/core/backup/backup_manifest.dart';
import 'package:minha_medicacao/core/backup/limites_backup.dart';
import 'package:minha_medicacao/core/backup/servico_backup.dart';
import 'package:minha_medicacao/core/backup/validador_backup.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:path/path.dart' as p;

import 'backup_teste.dart';

void main() {
  late Directory temporario;
  late Directory raizDados;
  late Directory staging;
  late Directory backups;
  late AppDatabase db;

  setUp(() async {
    temporario = await Directory.systemTemp.createTemp('servico-backup-');
    raizDados = Directory(p.join(temporario.path, 'dados'));
    staging = Directory(p.join(temporario.path, 'temporarios'));
    backups = Directory(p.join(temporario.path, 'backups'));
    await raizDados.create(recursive: true);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await inserirMedicamentoNome(db, 'Losartana');
  });

  tearDown(() async {
    await db.close();
    if (await temporario.exists()) {
      await temporario.delete(recursive: true);
    }
  });

  test(
    'gera ZIP autocontido com snapshot, manifest e anexo verificados',
    () async {
      const caminhoAnexo = 'anexos/medicamentos/foto-teste.jpg';
      final foto = File(
        p.joinAll(<String>[raizDados.path, ...p.posix.split(caminhoAnexo)]),
      );
      await foto.parent.create(recursive: true);
      await foto.writeAsBytes(<int>[0xff, 0xd8, 0xff, 1, 2, 3, 4]);
      await db
          .into(db.anexos)
          .insert(
            AnexosCompanion.insert(
              id: 'anexo-1',
              medicamentoId: 'medicamento-1',
              tipo: 'fotoMedicamento',
              caminhoRelativo: caminhoAnexo,
              criadoEm: DateTime.utc(2026, 8, 18),
            ),
          );

      final servico = ServicoBackup(
        db,
        raizDados: () async => raizDados,
        diretorioTemporario: () async => staging,
        diretorioBackups: () async => backups,
        versaoAplicativo: () async => '1.0.0+1',
        agora: () => DateTime.utc(2026, 8, 18, 21, 30),
        exclusaoMutua: ExclusaoMutuaArquivos(),
      );

      final resultado = await servico.criar();

      expect(await resultado.arquivo.exists(), isTrue);
      expect(resultado.arquivo.path, endsWith('.zip'));
      expect(resultado.manifest.versaoSchemaBanco, versaoSchemaBancoAtual);
      expect(
        resultado.manifest.arquivos.map((arquivo) => arquivo.caminho),
        containsAll(<String>[caminhoBancoBackup, caminhoAnexo]),
      );

      final validacao = Directory(p.join(temporario.path, 'validacao-externa'));
      final validado = await const ValidadorBackup().validarEExtrair(
        resultado.arquivo,
        validacao,
      );
      expect(await validado.banco.exists(), isTrue);
      expect(
        await File(
          p.joinAll(<String>[validacao.path, ...p.posix.split(caminhoAnexo)]),
        ).readAsBytes(),
        await foto.readAsBytes(),
      );
    },
  );

  test('rejeita ZIP corrompido e remove staging parcial', () async {
    final corrompido = File(p.join(temporario.path, 'corrompido.zip'));
    await corrompido.writeAsBytes(utf8.encode('isto não é um zip'));
    final destino = Directory(p.join(temporario.path, 'extraido-corrompido'));

    await expectLater(
      const ValidadorBackup().validarEExtrair(corrompido, destino),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.zipCorrompido,
        ),
      ),
    );
    expect(await destino.exists(), isFalse);
  });

  test('rejeita Zip Slip antes de escrever fora do staging', () async {
    final malicioso = File(p.join(temporario.path, 'zip-slip.zip'));
    final archive = Archive()
      ..add(ArchiveFile.string('../fora.txt', 'conteúdo'));
    await malicioso.writeAsBytes(ZipEncoder().encode(archive));
    final destino = Directory(p.join(temporario.path, 'extraido-slip'));

    await expectLater(
      const ValidadorBackup().validarEExtrair(malicioso, destino),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.caminhoInseguro,
        ),
      ),
    );
    expect(await File(p.join(temporario.path, 'fora.txt')).exists(), isFalse);
  });

  test('rejeita schema futuro antes de substituir qualquer dado', () async {
    final original = await ServicoBackup(
      db,
      raizDados: () async => raizDados,
      diretorioTemporario: () async => staging,
      diretorioBackups: () async => backups,
      versaoAplicativo: () async => '1.0.0+1',
      exclusaoMutua: ExclusaoMutuaArquivos(),
    ).criar();
    final bytes = await original.arquivo.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final json = resultadoManifestoComSchema(original.manifest, 99);
    archive.add(ArchiveFile.string(caminhoManifestBackup, jsonEncode(json)));
    final futuro = File(p.join(temporario.path, 'schema-futuro.zip'));
    await futuro.writeAsBytes(ZipEncoder().encode(archive));

    await expectLater(
      const ValidadorBackup().validarEExtrair(
        futuro,
        Directory(p.join(temporario.path, 'extraido-futuro')),
      ),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.schemaIncompativel,
        ),
      ),
    );
  });

  test('rejeita conteúdo cujo SHA-256 diverge do manifest', () async {
    final original = await ServicoBackup(
      db,
      raizDados: () async => raizDados,
      diretorioTemporario: () async => staging,
      diretorioBackups: () async => backups,
      versaoAplicativo: () async => '1.0.0+1',
      exclusaoMutua: ExclusaoMutuaArquivos(),
    ).criar();
    final archive = ZipDecoder().decodeBytes(
      await original.arquivo.readAsBytes(),
    );
    final json = original.manifest.toJson();
    final arquivos = (json['arquivos']! as List<Object?>)
        .map((entrada) => Map<String, Object>.from(entrada! as Map))
        .toList();
    arquivos.firstWhere(
      (entrada) => entrada['caminho'] == caminhoBancoBackup,
    )['sha256'] = '0' * 64;
    json['arquivos'] = arquivos;
    archive.add(ArchiveFile.string(caminhoManifestBackup, jsonEncode(json)));
    final adulterado = File(p.join(temporario.path, 'hash-invalido.zip'));
    await adulterado.writeAsBytes(ZipEncoder().encode(archive));

    await expectLater(
      const ValidadorBackup().validarEExtrair(
        adulterado,
        Directory(p.join(temporario.path, 'extraido-hash')),
      ),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.hashInvalido,
        ),
      ),
    );
  });

  test('limites configuráveis bloqueiam entrada grande', () async {
    final original = await ServicoBackup(
      db,
      raizDados: () async => raizDados,
      diretorioTemporario: () async => staging,
      diretorioBackups: () async => backups,
      versaoAplicativo: () async => '1.0.0+1',
      exclusaoMutua: ExclusaoMutuaArquivos(),
    ).criar();
    const limites = LimitesBackup(
      maximoZipBytes: 1024 * 1024,
      maximoArquivoBytes: 32,
      maximoTotalExtraidoBytes: 1024,
    );

    await expectLater(
      const ValidadorBackup(limites: limites).validarEExtrair(
        original.arquivo,
        Directory(p.join(temporario.path, 'extraido-limite')),
      ),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.limiteExcedido,
        ),
      ),
    );
  });
}

Map<String, Object> resultadoManifestoComSchema(
  BackupManifest original,
  int schema,
) => <String, Object>{...original.toJson(), 'versaoSchemaBanco': schema};
