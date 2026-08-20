import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../arquivos/app_paths.dart';
import '../data_hora/relogio.dart';
import 'conversor_data_civil.dart';

part 'app_database.g.dart';

const int versaoSchemaBancoAtual = 3;

@DataClassName('MedicamentoDb')
@TableIndex(name: 'idx_medicamentos_nome', columns: {#nome})
class Medicamentos extends Table {
  TextColumn get id => text()();
  TextColumn get nome => text().withLength(min: 1, max: 200)();
  TextColumn get concentracao => text().nullable()();
  TextColumn get formaFarmaceutica => text().nullable()();
  TextColumn get unidadeDosePadrao => text().nullable()();
  TextColumn get unidadeEstoque => text().nullable()();
  TextColumn get observacoes => text().nullable()();
  BoolColumn get controleEstoque =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TratamentoDb')
@TableIndex(name: 'idx_tratamentos_medicamento', columns: {#medicamentoId})
@TableIndex(name: 'idx_tratamentos_ativos', columns: {#ativo, #dataInicio})
class Tratamentos extends Table {
  TextColumn get id => text()();
  TextColumn get medicamentoId => text().references(
    Medicamentos,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  RealColumn get quantidadeDose =>
      real().check(const CustomExpression('quantidade_dose > 0'))();
  TextColumn get unidadeDose => text().withLength(min: 1, max: 80)();
  RealColumn get consumoEstoquePorDose => real().nullable().check(
    const CustomExpression(
      'consumo_estoque_por_dose IS NULL OR consumo_estoque_por_dose > 0',
    ),
  )();
  IntColumn get dataInicio => integer().map(const ConversorDataCivil())();
  IntColumn get dataFim =>
      integer().map(const ConversorDataCivil()).nullable()();
  BoolColumn get usoContinuo => boolean()();
  TextColumn get tipoAgendamento => text().withLength(min: 1, max: 30)();
  DateTimeColumn get dataHoraAncora => dateTime().nullable()();
  IntColumn get intervaloMinutos => integer().nullable().check(
    const CustomExpression(
      'intervalo_minutos IS NULL OR intervalo_minutos > 0',
    ),
  )();

  /// Em quais dias os horários fixos valem: diaria, cadaNDias, diasDaSemana
  /// ou mensal. Tratamentos criados antes desta coluna continuam diários.
  TextColumn get recorrencia => text()
      .withLength(min: 1, max: 20)
      .withDefault(const Constant('diaria'))();

  /// Multiplicador da recorrência: dias, semanas ou meses, conforme o tipo.
  IntColumn get recorrenciaIntervalo => integer().nullable().check(
    const CustomExpression(
      'recorrencia_intervalo IS NULL OR recorrencia_intervalo > 0',
    ),
  )();

  /// Dias da semana no padrão de `DateTime.weekday`, separados por vírgula.
  TextColumn get recorrenciaDiasSemana =>
      text().withLength(min: 1, max: 20).nullable()();

  IntColumn get recorrenciaDiaDoMes => integer().nullable().check(
    const CustomExpression(
      'recorrencia_dia_do_mes IS NULL OR '
      '(recorrencia_dia_do_mes >= 1 AND recorrencia_dia_do_mes <= 31)',
    ),
  )();
  TextColumn get instrucoes => text().nullable()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get encerradoEm => dateTime().nullable()();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((uso_continuo = 1) OR (data_fim IS NOT NULL))',
    'CHECK (data_fim IS NULL OR data_fim >= data_inicio)',
    "CHECK (tipo_agendamento IN ('horariosFixos', 'intervalo'))",
    "CHECK ((tipo_agendamento = 'intervalo' AND data_hora_ancora IS NOT NULL "
        "AND intervalo_minutos IS NOT NULL) OR tipo_agendamento = 'horariosFixos')",
    "CHECK (recorrencia IN ('diaria', 'cadaNDias', 'diasDaSemana', 'mensal'))",
    "CHECK (recorrencia = 'diaria' OR tipo_agendamento = 'horariosFixos')",
    "CHECK (recorrencia <> 'cadaNDias' OR recorrencia_intervalo IS NOT NULL)",
    "CHECK (recorrencia <> 'diasDaSemana' OR recorrencia_dias_semana IS NOT NULL)",
    "CHECK (recorrencia <> 'mensal' OR recorrencia_dia_do_mes IS NOT NULL)",
  ];
}

@DataClassName('HorarioTratamentoDb')
@TableIndex(
  name: 'idx_horarios_tratamento_ordem',
  columns: {#tratamentoId, #ordem},
)
class HorariosTratamento extends Table {
  TextColumn get id => text()();
  TextColumn get tratamentoId => text().references(
    Tratamentos,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  IntColumn get hora =>
      integer().check(const CustomExpression('hora BETWEEN 0 AND 23'))();
  IntColumn get minuto =>
      integer().check(const CustomExpression('minuto BETWEEN 0 AND 59'))();
  IntColumn get ordem =>
      integer().check(const CustomExpression('ordem >= 0'))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {tratamentoId, hora, minuto},
  ];
}

@DataClassName('RegistroDoseDb')
@TableIndex(
  name: 'idx_registros_dose_programada',
  columns: {#dataHoraProgramada},
)
@TableIndex(
  name: 'idx_registros_dose_medicamento',
  columns: {#medicamentoId, #dataHoraProgramada},
)
class RegistrosDose extends Table {
  TextColumn get id => text()();
  TextColumn get doseKey => text().unique()();
  TextColumn get tratamentoId => text().references(
    Tratamentos,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get medicamentoId => text().references(
    Medicamentos,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  DateTimeColumn get dataHoraProgramada => dateTime()();
  DateTimeColumn get dataHoraAcao => dateTime()();
  RealColumn get quantidadeDose =>
      real().check(const CustomExpression('quantidade_dose > 0'))();
  TextColumn get unidadeDose => text().withLength(min: 1, max: 80)();
  TextColumn get status => text().check(
    const CustomExpression("status IN ('tomada', 'naoTomada')"),
  )();
  TextColumn get observacao => text().nullable()();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('MovimentacaoEstoqueDb')
@TableIndex(
  name: 'idx_movimentacoes_medicamento_data',
  columns: {#medicamentoId, #dataHora},
)
@TableIndex(name: 'idx_movimentacoes_registro_dose', columns: {#registroDoseId})
class MovimentacoesEstoque extends Table {
  TextColumn get id => text()();
  TextColumn get medicamentoId => text().references(
    Medicamentos,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get registroDoseId => text().nullable().references(
    RegistrosDose,
    #id,
    onDelete: KeyAction.restrict,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get movimentacaoOrigemId => text().nullable()();
  TextColumn get tipo => text().check(
    const CustomExpression(
      "tipo IN ('entradaReposicao', 'saidaDose', "
      "'ajusteEntrada', 'ajusteSaida')",
    ),
  )();
  RealColumn get quantidade =>
      real().check(const CustomExpression('quantidade > 0'))();
  TextColumn get unidade => text().withLength(min: 1, max: 80)();
  DateTimeColumn get dataHora => dateTime()();
  TextColumn get observacao => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AnexoDb')
@TableIndex(name: 'idx_anexos_medicamento', columns: {#medicamentoId})
class Anexos extends Table {
  TextColumn get id => text()();
  TextColumn get medicamentoId => text().references(
    Medicamentos,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get tipo => text().check(
    const CustomExpression("tipo IN ('fotoMedicamento', 'receita')"),
  )();
  TextColumn get caminhoRelativo => text()();
  TextColumn get nomeOriginal => text().nullable()();
  DateTimeColumn get criadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ConfiguracaoDb')
class Configuracoes extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();
  DateTimeColumn get atualizadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {chave};
}

@DataClassName('AdiamentoDoseDb')
@TableIndex(name: 'idx_adiamentos_lembrete', columns: {#lembrarEm})
class AdiamentosDose extends Table {
  TextColumn get id => text()();
  TextColumn get doseKey => text().unique()();
  TextColumn get tratamentoId => text().references(
    Tratamentos,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  TextColumn get medicamentoId => text().references(
    Medicamentos,
    #id,
    onDelete: KeyAction.cascade,
    onUpdate: KeyAction.cascade,
  )();
  DateTimeColumn get dataHoraProgramada => dateTime()();
  DateTimeColumn get lembrarEm => dateTime()();
  IntColumn get notificacaoId => integer()();
  DateTimeColumn get criadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Medicamentos,
    Tratamentos,
    HorariosTratamento,
    RegistrosDose,
    MovimentacoesEstoque,
    Anexos,
    Configuracoes,
    AdiamentosDose,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_abrirConexao());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => versaoSchemaBancoAtual;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      final now = const RelogioSistema().agora();
      await batch((batch) {
        batch.insertAll(configuracoes, [
          ConfiguracoesCompanion.insert(
            chave: 'diasAlertaEstoque',
            valor: '7',
            atualizadoEm: now,
          ),
          ConfiguracoesCompanion.insert(
            chave: 'versaoFormatoBackup',
            valor: '1',
            atualizadoEm: now,
          ),
          ConfiguracoesCompanion.insert(
            chave: 'configuracaoInicialConcluida',
            valor: 'false',
            atualizadoEm: now,
          ),
        ]);
      });
    },
    onUpgrade: (migrator, from, to) async {
      if (from > to) {
        throw StateError('Downgrade de banco não é suportado.');
      }
      // Reconstruir tabela referenciada por outras exige soltar as chaves
      // estrangeiras durante a migração; a verificação abaixo garante que
      // nenhum vínculo ficou órfão antes de religá-las.
      await customStatement('PRAGMA foreign_keys = OFF');
      if (from < 2) {
        // Na v1, o Drift armazenava estas datas como Unix timestamp. A
        // conversão usa o fuso local corrente, exatamente como a leitura da
        // coluna DateTime anterior, e congela o dia exibido no formato civil.
        await customStatement('''
          UPDATE tratamentos
          SET data_inicio = CASE
                WHEN data_inicio BETWEEN 10000101 AND 99991231
                  THEN data_inicio
                ELSE CAST(
                  strftime('%Y%m%d', data_inicio, 'unixepoch', 'localtime')
                  AS INTEGER
                )
              END,
              data_fim = CASE
                WHEN data_fim IS NULL
                  OR data_fim BETWEEN 10000101 AND 99991231
                  THEN data_fim
                ELSE CAST(
                  strftime('%Y%m%d', data_fim, 'unixepoch', 'localtime')
                  AS INTEGER
                )
              END
        ''');
      }
      if (from < 3) {
        // As colunas são aditivas e os tratamentos existentes passam a valer
        // como diários, mantendo o comportamento atual. A tabela é recriada
        // porque o SQLite não permite acrescentar CHECK de tabela por ALTER.
        await migrator.alterTable(
          TableMigration(
            tratamentos,
            newColumns: [
              tratamentos.recorrencia,
              tratamentos.recorrenciaIntervalo,
              tratamentos.recorrenciaDiasSemana,
              tratamentos.recorrenciaDiaDoMes,
            ],
          ),
        );
      }

      final vinculosQuebrados = await customSelect(
        'PRAGMA foreign_key_check',
      ).get();
      if (vinculosQuebrados.isNotEmpty) {
        throw StateError(
          'A migração deixaria ${vinculosQuebrados.length} vínculo(s) '
          'órfão(s); nada foi aplicado.',
        );
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
    beforeOpen: (_) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );

  Future<void> verificarIntegridade() async {
    final result = await customSelect('PRAGMA quick_check').getSingle();
    if (result.read<String>('quick_check') != 'ok') {
      throw StateError(
        'O banco de dados não passou na verificação de integridade.',
      );
    }
  }

  Future<void> checkpoint() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

DatabaseConnection _abrirConexao() {
  return driftDatabase(
    name: 'minha_medicacao',
    native: DriftNativeOptions(
      shareAcrossIsolates: true,
      databaseDirectory: () => AppPaths.banco(),
      tempDirectoryPath: () async => (await AppPaths.temporarios()).path,
    ),
  );
}

Future<File> arquivoDoBanco() => AppPaths.arquivoBanco();

/// Abre um arquivo SQLite isolado, executa as migrações do aplicativo e o
/// fecha somente depois de validar versão e integridade.
///
/// A assinatura coincide com `MigrarBancoRestaurado`, sem criar dependência
/// do banco em relação à camada de backup.
Future<void> migrarArquivoBanco(
  File arquivo,
  int versaoOrigem,
  int versaoDestino,
) async {
  if (versaoOrigem >= versaoDestino ||
      versaoDestino != versaoSchemaBancoAtual) {
    throw ArgumentError(
      'Migração de schema não suportada: '
      '$versaoOrigem -> $versaoDestino.',
    );
  }

  final db = AppDatabase.forTesting(NativeDatabase(arquivo));
  try {
    final resultado = await db.customSelect('PRAGMA user_version').getSingle();
    final versaoMigrada = resultado.read<int>('user_version');
    if (versaoMigrada != versaoDestino) {
      throw StateError(
        'O arquivo foi aberto no schema $versaoMigrada; '
        'esperado $versaoDestino.',
      );
    }
    await db.verificarIntegridade();
  } finally {
    await db.close();
  }
}
