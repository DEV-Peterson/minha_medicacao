import 'dart:io';

import 'package:drift/drift.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/arquivos/armazenamento_anexos.dart';
import '../../../core/arquivos/exclusao_mutua_arquivos.dart';
import '../../../core/banco/app_database.dart';
import '../../../core/data_hora/relogio.dart';

class AnexoRepository {
  AnexoRepository(
    this._db, {
    ArmazenamentoAnexos? armazenamento,
    ExclusaoMutuaArquivos? exclusaoMutua,
    Uuid? uuid,
    this.relogio = const RelogioSistema(),
  }) : _armazenamento = armazenamento ?? ArmazenamentoAnexos(),
       _exclusaoMutua = exclusaoMutua ?? ExclusaoMutuaArquivos.compartilhada,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final ArmazenamentoAnexos _armazenamento;
  final ExclusaoMutuaArquivos _exclusaoMutua;
  final Uuid _uuid;
  final Relogio relogio;

  Stream<List<AnexoDb>> observarDoMedicamento(String medicamentoId) {
    return (_db.select(_db.anexos)
          ..where((anexo) => anexo.medicamentoId.equals(medicamentoId))
          ..orderBy([(anexo) => OrderingTerm.asc(anexo.criadoEm)]))
        .watch();
  }

  Future<List<AnexoDb>> obterTodos() => _db.select(_db.anexos).get();

  /// Importa a imagem para o diretório privado antes de persistir seu vínculo.
  ///
  /// Se o insert falhar, a cópia recém-criada é removida para não deixar um
  /// arquivo órfão. O caminho persistido é sempre relativo à raiz do app.
  Future<AnexoDb> adicionar({
    required String medicamentoId,
    required TipoArquivoAnexo tipo,
    required XFile imagem,
    String? nomeOriginal,
    DateTime? agora,
  }) {
    return _exclusaoMutua.executar(() async {
      final salvo = await _armazenamento.importarImagem(imagem, tipo);
      final id = _uuid.v4();
      final criadoEm = agora ?? relogio.agora();
      try {
        await _db
            .into(_db.anexos)
            .insert(
              AnexosCompanion.insert(
                id: id,
                medicamentoId: medicamentoId,
                tipo: tipo.valorBanco,
                caminhoRelativo: salvo.caminhoRelativo,
                nomeOriginal: Value(_nomeSeguro(nomeOriginal ?? imagem.name)),
                criadoEm: criadoEm,
              ),
            );
      } catch (_) {
        await _armazenamento
            .excluirSeExistir(salvo.caminhoRelativo)
            .catchError((Object _) {});
        rethrow;
      }
      return AnexoDb(
        id: id,
        medicamentoId: medicamentoId,
        tipo: tipo.valorBanco,
        caminhoRelativo: salvo.caminhoRelativo,
        nomeOriginal: _nomeSeguro(nomeOriginal ?? imagem.name),
        criadoEm: criadoEm,
      );
    });
  }

  Future<File> arquivoDe(AnexoDb anexo) =>
      _armazenamento.resolver(anexo.caminhoRelativo);

  /// Exclui primeiro o vínculo transacional e depois tenta remover o arquivo.
  ///
  /// Uma falha de filesystem pode deixar um órfão recuperável, mas nunca uma
  /// linha do banco apontando para um arquivo removido.
  Future<void> remover(String id) {
    return _exclusaoMutua.executar(() async {
      final anexo = await (_db.select(
        _db.anexos,
      )..where((item) => item.id.equals(id))).getSingleOrNull();
      if (anexo == null) return;
      await (_db.delete(_db.anexos)..where((item) => item.id.equals(id))).go();
      await _armazenamento.excluirSeExistir(anexo.caminhoRelativo);
    });
  }
}

String? _nomeSeguro(String? nome) {
  final valor = nome?.trim();
  if (valor == null || valor.isEmpty) return null;
  // O nome é apenas metadado para exibição. Remove caracteres de controle e
  // limita o tamanho para que nunca participe da resolução de caminhos.
  final filtrado = valor.replaceAll(RegExp(r'[\x00-\x1f\x7f]'), '');
  if (filtrado.isEmpty) return null;
  return filtrado.length <= 255 ? filtrado : filtrado.substring(0, 255);
}
