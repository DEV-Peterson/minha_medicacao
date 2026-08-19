import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/banco/conversor_data_civil.dart';
import 'package:path/path.dart' as p;

import '../../drift/app_database/generated/schema.dart';
import '../../drift/app_database/generated/schema_v1.dart' as v1;
import 'banco_teste.dart';

void main() {
  group('datas civis no banco', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('persiste início e fim como YYYYMMDD e mantém timestamps', () async {
      await inserirMedicamentoTeste(db);
      final criadoEm = DateTime.utc(2026, 8, 17, 23, 58, 57);

      await db
          .into(db.tratamentos)
          .insert(
            TratamentosCompanion.insert(
              id: 'tratamento-data-civil',
              medicamentoId: 'medicamento-1',
              quantidadeDose: 1,
              unidadeDose: 'comprimido',
              dataInicio: DateTime.utc(2026, 8, 18, 23, 59),
              dataFim: Value(DateTime(2026, 12, 31, 7, 30)),
              usoContinuo: false,
              tipoAgendamento: 'horariosFixos',
              criadoEm: criadoEm,
              atualizadoEm: criadoEm,
            ),
          );

      final bruto = await db.customSelect('''
            SELECT data_inicio, data_fim, criado_em, atualizado_em
            FROM tratamentos
            WHERE id = 'tratamento-data-civil'
          ''').getSingle();
      final tratamento =
          await (db.select(db.tratamentos)
                ..where((tabela) => tabela.id.equals('tratamento-data-civil')))
              .getSingle();

      expect(bruto.read<int>('data_inicio'), 20260818);
      expect(bruto.read<int>('data_fim'), 20261231);
      expect(
        bruto.read<int>('criado_em'),
        criadoEm.millisecondsSinceEpoch ~/ 1000,
      );
      expect(
        bruto.read<int>('atualizado_em'),
        criadoEm.millisecondsSinceEpoch ~/ 1000,
      );
      expect(tratamento.dataInicio, DateTime(2026, 8, 18));
      expect(tratamento.dataFim, DateTime(2026, 12, 31));
    });

    test('mantém fim nulo para tratamento contínuo', () async {
      await inserirMedicamentoTeste(db);
      final tratamento = await inserirTratamentoTeste(db);
      final bruto = await db
          .customSelect(
            'SELECT data_inicio, data_fim FROM tratamentos WHERE id = ?',
            variables: [Variable<String>(tratamento.id)],
          )
          .getSingle();

      expect(bruto.read<int>('data_inicio'), 20260818);
      expect(bruto.readNullable<int>('data_fim'), isNull);
      expect(tratamento.dataInicio, DateTime(2026, 8, 18));
      expect(tratamento.dataFim, isNull);
    });
  });

  test(
    'migração v1 converte epoch para YYYYMMDD sem tocar timestamps',
    () async {
      final verifier = SchemaVerifier(GeneratedHelper());
      final schema = await verifier.schemaAt(1);
      addTearDown(schema.close);

      final inicioLegado = DateTime(2026, 8, 18);
      final fimLegado = DateTime(2026, 12, 31);
      final criadoEm = DateTime(2026, 8, 17, 22, 45);
      final inicioEpoch = inicioLegado.millisecondsSinceEpoch ~/ 1000;
      final fimEpoch = fimLegado.millisecondsSinceEpoch ~/ 1000;
      final criadoEpoch = criadoEm.millisecondsSinceEpoch ~/ 1000;

      schema.rawDatabase.execute(
        '''
        INSERT INTO medicamentos (
          id, nome, controle_estoque, ativo, criado_em, atualizado_em
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
        ['medicamento-v1', 'Legado', 0, 1, criadoEpoch, criadoEpoch],
      );
      schema.rawDatabase.execute(
        '''
        INSERT INTO tratamentos (
          id, medicamento_id, quantidade_dose, unidade_dose,
          data_inicio, data_fim, uso_continuo, tipo_agendamento,
          ativo, criado_em, atualizado_em
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          'tratamento-v1',
          'medicamento-v1',
          1.0,
          'comprimido',
          inicioEpoch,
          fimEpoch,
          0,
          'horariosFixos',
          1,
          criadoEpoch,
          criadoEpoch,
        ],
      );
      schema.rawDatabase.execute(
        '''
        INSERT INTO tratamentos (
          id, medicamento_id, quantidade_dose, unidade_dose,
          data_inicio, uso_continuo, tipo_agendamento,
          ativo, criado_em, atualizado_em
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
        [
          'tratamento-v1-ja-civil',
          'medicamento-v1',
          1.0,
          'comprimido',
          20260901,
          1,
          'horariosFixos',
          1,
          criadoEpoch,
          criadoEpoch,
        ],
      );

      final db = AppDatabase.forTesting(schema.newConnection());
      addTearDown(db.close);
      await verifier.migrateAndValidate(db, versaoSchemaBancoAtual);

      const conversor = ConversorDataCivil();
      final bruto = await db.customSelect('''
          SELECT data_inicio, data_fim, criado_em, atualizado_em
          FROM tratamentos
          WHERE id = 'tratamento-v1'
        ''').getSingle();
      final tratamento = await (db.select(
        db.tratamentos,
      )..where((tabela) => tabela.id.equals('tratamento-v1'))).getSingle();
      final jaCivil = await db.customSelect('''
          SELECT data_inicio
          FROM tratamentos
          WHERE id = 'tratamento-v1-ja-civil'
        ''').getSingle();
      final versao = await db.customSelect('PRAGMA user_version').getSingle();

      expect(
        bruto.read<int>('data_inicio'),
        conversor.toSql(
          DateTime.fromMillisecondsSinceEpoch(inicioEpoch * 1000),
        ),
      );
      expect(
        bruto.read<int>('data_fim'),
        conversor.toSql(DateTime.fromMillisecondsSinceEpoch(fimEpoch * 1000)),
      );
      expect(bruto.read<int>('criado_em'), criadoEpoch);
      expect(bruto.read<int>('atualizado_em'), criadoEpoch);
      expect(jaCivil.read<int>('data_inicio'), 20260901);
      expect(tratamento.dataInicio, inicioLegado);
      expect(tratamento.dataFim, fimLegado);
      expect(versao.read<int>('user_version'), versaoSchemaBancoAtual);
    },
  );

  test('migrarArquivoBanco atualiza um arquivo v1 e o fecha', () async {
    final temporario = await Directory.systemTemp.createTemp(
      'data-civil-migracao-',
    );
    addTearDown(() => temporario.delete(recursive: true));
    final arquivo = File(p.join(temporario.path, 'legado.sqlite'));
    final inicio = DateTime(2026, 8, 18);
    final inicioEpoch = inicio.millisecondsSinceEpoch ~/ 1000;
    final criadoEpoch =
        DateTime(2026, 8, 17, 22).millisecondsSinceEpoch ~/ 1000;

    final legado = v1.DatabaseAtV1(NativeDatabase(arquivo));
    await legado.customStatement(
      '''
        INSERT INTO medicamentos (
          id, nome, controle_estoque, ativo, criado_em, atualizado_em
        ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      ['medicamento-arquivo', 'Legado', 0, 1, criadoEpoch, criadoEpoch],
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
        'tratamento-arquivo',
        'medicamento-arquivo',
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

    await migrarArquivoBanco(arquivo, 1, versaoSchemaBancoAtual);

    final migrado = AppDatabase.forTesting(NativeDatabase(arquivo));
    final tratamento = await migrado.select(migrado.tratamentos).getSingle();
    final bruto = await migrado
        .customSelect(
          'SELECT data_inicio, criado_em FROM tratamentos WHERE id = ?',
          variables: [const Variable<String>('tratamento-arquivo')],
        )
        .getSingle();
    await migrado.close();

    expect(tratamento.dataInicio, inicio);
    expect(bruto.read<int>('data_inicio'), 20260818);
    expect(bruto.read<int>('criado_em'), criadoEpoch);
    expect(await arquivo.exists(), isTrue);
  });
}
