import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minha_medicacao/core/arquivos/armazenamento_anexos.dart';
import 'package:minha_medicacao/core/arquivos/exclusao_mutua_arquivos.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/medicamentos/dados/anexo_repository.dart';
import 'package:path/path.dart' as p;

import '../../../core/banco/banco_teste.dart';

void main() {
  late Directory temporario;
  late Directory raizDados;
  late AppDatabase db;
  late AnexoRepository repository;

  setUp(() async {
    temporario = await Directory.systemTemp.createTemp('anexo-repository-');
    raizDados = Directory(p.join(temporario.path, 'dados'));
    await raizDados.create(recursive: true);
    db = criarBancoEmMemoria();
    await inserirMedicamentoTeste(db);
    repository = AnexoRepository(
      db,
      armazenamento: ArmazenamentoAnexos(
        raiz: () async => raizDados,
        limiteImagemBytes: 1024,
      ),
      exclusaoMutua: ExclusaoMutuaArquivos(),
    );
  });

  tearDown(() async {
    await db.close();
    if (await temporario.exists()) {
      await temporario.delete(recursive: true);
    }
  });

  test(
    'copia imagem para área privada e persiste somente caminho relativo',
    () async {
      final selecionada = File(p.join(temporario.path, 'foto-sem-confiar.txt'));
      await selecionada.writeAsBytes(<int>[0xff, 0xd8, 0xff, 0xe0, 1, 2, 3]);

      final anexo = await repository.adicionar(
        medicamentoId: 'medicamento-1',
        tipo: TipoArquivoAnexo.fotoMedicamento,
        imagem: XFile(selecionada.path),
        agora: DateTime.utc(2026, 8, 18),
      );

      expect(
        anexo.caminhoRelativo,
        matches(r'^anexos/medicamentos/[0-9a-f-]+\.jpg$'),
      );
      expect(p.isAbsolute(anexo.caminhoRelativo), isFalse);
      final copia = await repository.arquivoDe(anexo);
      expect(await copia.readAsBytes(), await selecionada.readAsBytes());
      expect((await repository.obterTodos()).single.id, anexo.id);

      await repository.remover(anexo.id);
      expect(await copia.exists(), isFalse);
      expect(await repository.obterTodos(), isEmpty);
    },
  );

  test(
    'rejeita conteúdo que apenas finge ser imagem sem gravar vínculo',
    () async {
      final selecionada = File(p.join(temporario.path, 'falsa.jpg'));
      await selecionada.writeAsString('não é uma imagem');

      await expectLater(
        repository.adicionar(
          medicamentoId: 'medicamento-1',
          tipo: TipoArquivoAnexo.receita,
          imagem: XFile(selecionada.path),
        ),
        throwsA(isA<FormatoImagemNaoSuportado>()),
      );
      expect(await repository.obterTodos(), isEmpty);
      final receitas = Directory(p.join(raizDados.path, 'anexos', 'receitas'));
      expect(
        await receitas.list().where((item) => item is File).toList(),
        isEmpty,
      );
    },
  );
}
