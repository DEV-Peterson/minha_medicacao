import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/backup/backup_excecao.dart';
import 'package:minha_medicacao/core/backup/limites_backup.dart';
import 'package:minha_medicacao/core/backup/transporte_backup.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory temporario;

  setUp(() async {
    temporario = await Directory.systemTemp.createTemp('transporte-backup-');
  });

  tearDown(() async {
    if (await temporario.exists()) {
      await temporario.delete(recursive: true);
    }
  });

  test('copia seleção por stream sem depender de PlatformFile.path', () async {
    final servico = ServicoSelecaoBackup(
      diretorioTemporario: () async => temporario,
      limites: const LimitesBackup(maximoZipBytes: 64),
    );
    final blocos = <Uint8List>[
      Uint8List.fromList(<int>[0x50, 0x4b]),
      Uint8List.fromList(<int>[0x03, 0x04, 1, 2, 3]),
    ];

    final arquivo = await servico.copiarSelecaoParaTemporario(
      Stream<Uint8List>.fromIterable(blocos),
      tamanhoInformado: 7,
    );

    expect(await arquivo.readAsBytes(), <int>[0x50, 0x4b, 0x03, 0x04, 1, 2, 3]);
    expect(p.extension(arquivo.path), '.zip');
  });

  test('interrompe stream que ultrapassa o limite e remove parcial', () async {
    final servico = ServicoSelecaoBackup(
      diretorioTemporario: () async => temporario,
      limites: const LimitesBackup(maximoZipBytes: 4),
    );

    await expectLater(
      servico.copiarSelecaoParaTemporario(
        Stream<List<int>>.fromIterable(<List<int>>[
          <int>[1, 2, 3],
          <int>[4, 5],
        ]),
      ),
      throwsA(
        isA<BackupInvalido>().having(
          (erro) => erro.motivo,
          'motivo',
          MotivoBackupInvalido.arquivoMuitoGrande,
        ),
      ),
    );
    expect(
      await temporario.list().where((entidade) => entidade is File).toList(),
      isEmpty,
    );
  });
}
