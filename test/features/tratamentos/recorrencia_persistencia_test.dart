import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/hoje/dados/agenda_repository.dart';
import 'package:minha_medicacao/features/hoje/dominio/gerador_agenda.dart';
import 'package:minha_medicacao/features/medicamentos/dados/medicamento_repository.dart';
import 'package:minha_medicacao/features/medicamentos/dominio/cadastro_medicamento.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/modelos_agenda.dart';
import 'package:minha_medicacao/features/tratamentos/dominio/recorrencia_persistida.dart';

import '../../drift/app_database/generated/schema.dart';

void main() {
  group('recorrência persistida', () {
    late AppDatabase db;
    late MedicamentoRepository repository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repository = MedicamentoRepository(db);
    });

    tearDown(() => db.close());

    test(
      'cadastro mensal grava colunas e volta como regra do domínio',
      () async {
        final id = await repository.cadastrar(
          _cadastro(recorrencia: RecorrenciaMensal(31, aCadaMeses: 2)),
          agora: DateTime(2026, 8, 18, 7),
        );

        final tratamento = await (db.select(
          db.tratamentos,
        )..where((tabela) => tabela.medicamentoId.equals(id))).getSingle();

        expect(tratamento.recorrencia, 'mensal');
        expect(tratamento.recorrenciaDiaDoMes, 31);
        expect(tratamento.recorrenciaIntervalo, 2);
        expect(tratamento.recorrenciaDiasSemana, null);

        final volta = RecorrenciaPersistida.doTratamento(tratamento);
        expect(volta, isA<RecorrenciaMensal>());
        expect((volta as RecorrenciaMensal).diaDoMes, 31);
        expect(volta.aCadaMeses, 2);
      },
    );

    test('dias da semana são gravados ordenados e voltam iguais', () async {
      await repository.cadastrar(
        _cadastro(
          recorrencia: RecorrenciaDiasDaSemana({
            DateTime.thursday,
            DateTime.monday,
          }, aCadaSemanas: 2),
        ),
        agora: DateTime(2026, 8, 18, 7),
      );

      final tratamento = await db.select(db.tratamentos).getSingle();
      expect(tratamento.recorrenciaDiasSemana, '1,4');
      expect(tratamento.recorrenciaIntervalo, 2);

      final volta =
          RecorrenciaPersistida.doTratamento(tratamento)
              as RecorrenciaDiasDaSemana;
      expect(volta.diasDaSemana, {DateTime.monday, DateTime.thursday});
      expect(volta.aCadaSemanas, 2);
    });

    test('cadastro sem recorrência continua diário', () async {
      await repository.cadastrar(_cadastro(), agora: DateTime(2026, 8, 18, 7));

      final tratamento = await db.select(db.tratamentos).getSingle();
      expect(tratamento.recorrencia, 'diaria');
      expect(tratamento.recorrenciaIntervalo, null);
      expect(
        RecorrenciaPersistida.doTratamento(tratamento),
        isA<RecorrenciaDiaria>(),
      );
    });

    test('agenda lida do banco respeita a recorrência gravada', () async {
      await repository.cadastrar(
        _cadastro(recorrencia: RecorrenciaCadaNDias(3)),
        agora: DateTime(2026, 8, 18, 7),
      );

      final agenda = AgendaRepository(db);
      final completos = await agenda.obterTratamentosAtivos();
      final tratamento = agenda.converterTratamento(completos.single);
      const gerador = GeradorAgenda();

      final datas = gerador
          .gerar(
            tratamento: tratamento,
            periodo: PeriodoAgenda(
              inicio: DateTime(2026, 8, 18),
              fimExclusivo: DateTime(2026, 8, 28),
            ),
          )
          .map((dose) => dose.dataHoraProgramada)
          .toList();

      expect(datas, [
        DateTime(2026, 8, 18, 8),
        DateTime(2026, 8, 21, 8),
        DateTime(2026, 8, 24, 8),
        DateTime(2026, 8, 27, 8),
      ]);
    });

    test('intervalo em horas recusa recorrência por dias', () async {
      await expectLater(
        repository.cadastrar(
          CadastroMedicamento(
            nome: 'Amoxicilina',
            formaFarmaceutica: 'cápsula',
            unidadeDosePadrao: 'cápsula',
            quantidadeDose: 1,
            unidadeDose: 'cápsula',
            dataInicio: DateTime(2026, 8, 18),
            usoContinuo: true,
            tipoAgendamento: TipoAgendamentoCadastro.intervalo,
            dataHoraAncora: DateTime(2026, 8, 18, 6),
            intervaloMinutos: 480,
            recorrencia: RecorrenciaCadaNDias(2),
          ),
        ),
        throwsA(isA<FormularioInvalido>()),
      );
    });
  });

  test('migração da versão 2 preserva tratamentos como diários', () async {
    final verificador = SchemaVerifier(GeneratedHelper());
    final schema = await verificador.schemaAt(2);
    addTearDown(schema.close);

    final criadoEm = DateTime(2026, 8, 17, 22).millisecondsSinceEpoch ~/ 1000;
    schema.rawDatabase.execute(
      '''
      INSERT INTO medicamentos (
        id, nome, controle_estoque, ativo, criado_em, atualizado_em
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      ['medicamento-v2', 'Losartana', 0, 1, criadoEm, criadoEm],
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
        'tratamento-v2',
        'medicamento-v2',
        1.0,
        'comprimido',
        20260818,
        1,
        'horariosFixos',
        1,
        criadoEm,
        criadoEm,
      ],
    );
    schema.rawDatabase.execute(
      '''
      INSERT INTO horarios_tratamento (id, tratamento_id, hora, minuto, ordem)
      VALUES (?, ?, ?, ?, ?)
      ''',
      ['horario-v2', 'tratamento-v2', 8, 0, 0],
    );

    final migrado = AppDatabase.forTesting(schema.newConnection());
    addTearDown(migrado.close);
    await verificador.migrateAndValidate(migrado, 3);

    final tratamento = await migrado.select(migrado.tratamentos).getSingle();
    final horarios = await migrado.select(migrado.horariosTratamento).get();

    expect(tratamento.id, 'tratamento-v2');
    expect(tratamento.dataInicio, DateTime(2026, 8, 18));
    expect(tratamento.recorrencia, 'diaria');
    expect(tratamento.recorrenciaIntervalo, null);
    expect(tratamento.recorrenciaDiasSemana, null);
    expect(tratamento.recorrenciaDiaDoMes, null);
    // O vínculo com os horários sobrevive à reconstrução da tabela.
    expect(horarios.single.tratamentoId, 'tratamento-v2');
  });
}

CadastroMedicamento _cadastro({
  RecorrenciaDias recorrencia = const RecorrenciaDiaria(),
}) => CadastroMedicamento(
  nome: 'Losartana',
  formaFarmaceutica: 'comprimido',
  unidadeDosePadrao: 'comprimido',
  quantidadeDose: 1,
  unidadeDose: 'comprimido',
  dataInicio: DateTime(2026, 8, 18),
  usoContinuo: true,
  tipoAgendamento: TipoAgendamentoCadastro.horariosFixos,
  horarios: const [HorarioCadastro(8, 0)],
  recorrencia: recorrencia,
);
