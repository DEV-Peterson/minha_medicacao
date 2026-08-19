import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/app/app.dart';
import 'package:minha_medicacao/app/providers.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/core/data_hora/relogio.dart';

final class RelogioWidgetFalso implements Relogio {
  const RelogioWidgetFalso(this.instante);

  final DateTime instante;

  @override
  DateTime agora() => instante;
}

Future<AppDatabase> criarBancoWidget() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  // Força abertura, migrations e PRAGMAs antes de montar os streams da UI.
  await db.customSelect('SELECT 1').getSingle();
  return db;
}

Future<void> montarAplicativo(
  WidgetTester tester, {
  required AppDatabase db,
  required DateTime agora,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        relogioProvider.overrideWithValue(RelogioWidgetFalso(agora)),
        recuperacaoInicialBackupProvider.overrideWith((ref) async => false),
      ],
      child: const MinhaMedicacaoApp(),
    ),
  );
  for (var tentativa = 0; tentativa < 100; tentativa++) {
    await tester.pump(const Duration(milliseconds: 20));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 1)),
    );
    if (find.byType(NavigationBar).evaluate().isNotEmpty) break;
  }
  expect(find.byType(NavigationBar), findsOneWidget);
  await bombearInterface(tester);
}

void testWidgetsComBanco(
  String descricao,
  Future<void> Function(WidgetTester tester, AppDatabase db) corpo,
) {
  testWidgets(descricao, (tester) async {
    final db = await criarBancoWidget();
    try {
      await corpo(tester, db);
    } finally {
      await finalizarAplicativo(tester, db);
    }
  });
}

/// Avança apenas o necessário para streams, navegação e animações curtas.
///
/// O aplicativo possui um timer periódico e indicadores animados; por isso
/// `pumpAndSettle` não é uma primitiva segura para estes testes.
Future<void> bombearInterface(WidgetTester tester, {int ciclos = 20}) async {
  for (var ciclo = 0; ciclo < ciclos; ciclo++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> finalizarAplicativo(WidgetTester tester, AppDatabase db) async {
  // Deve ocorrer ainda dentro do corpo de testWidgets: o Drift agenda a
  // limpeza de streams em timers de duração zero durante o unmount.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.pumpWidget(const SizedBox.shrink());
  for (var ciclo = 0; ciclo < 4; ciclo++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
  await tester.runAsync(db.close);
  for (var ciclo = 0; ciclo < 4; ciclo++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}

final class CenarioMedicacaoWidget {
  const CenarioMedicacaoWidget({
    required this.medicamentoId,
    required this.tratamentoId,
  });

  final String medicamentoId;
  final String tratamentoId;
}

Future<CenarioMedicacaoWidget> semearMedicacaoWidget(
  AppDatabase db, {
  required DateTime dataReferencia,
  List<(int, int)> horarios = const [(8, 0), (20, 0)],
  bool controlarEstoque = false,
  double? estoqueInicial,
  double consumoEstoquePorDose = 1,
}) async {
  const medicamentoId = 'medicamento-widget';
  const tratamentoId = 'tratamento-widget';
  final criadoEm = DateTime(
    dataReferencia.year,
    dataReferencia.month,
    dataReferencia.day,
    7,
  );

  await db
      .into(db.medicamentos)
      .insert(
        MedicamentosCompanion.insert(
          id: medicamentoId,
          nome: 'Losartana',
          concentracao: const Value('50 mg'),
          formaFarmaceutica: const Value('Comprimido'),
          unidadeDosePadrao: const Value('comprimido'),
          unidadeEstoque: Value(controlarEstoque ? 'comprimidos' : null),
          controleEstoque: Value(controlarEstoque),
          criadoEm: criadoEm,
          atualizadoEm: criadoEm,
        ),
      );
  await db
      .into(db.tratamentos)
      .insert(
        TratamentosCompanion.insert(
          id: tratamentoId,
          medicamentoId: medicamentoId,
          quantidadeDose: 1,
          unidadeDose: 'comprimido',
          consumoEstoquePorDose: Value(
            controlarEstoque ? consumoEstoquePorDose : null,
          ),
          dataInicio: DateTime(
            dataReferencia.year,
            dataReferencia.month,
            dataReferencia.day,
          ).subtract(const Duration(days: 30)),
          usoContinuo: true,
          tipoAgendamento: 'horariosFixos',
          criadoEm: criadoEm,
          atualizadoEm: criadoEm,
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.horariosTratamento, [
      for (var indice = 0; indice < horarios.length; indice++)
        HorariosTratamentoCompanion.insert(
          id: 'horario-widget-$indice',
          tratamentoId: tratamentoId,
          hora: horarios[indice].$1,
          minuto: horarios[indice].$2,
          ordem: indice,
        ),
    ]);
  });
  if (controlarEstoque && (estoqueInicial ?? 0) > 0) {
    await db
        .into(db.movimentacoesEstoque)
        .insert(
          MovimentacoesEstoqueCompanion.insert(
            id: 'estoque-inicial-widget',
            medicamentoId: medicamentoId,
            tipo: 'entradaReposicao',
            quantidade: estoqueInicial!,
            unidade: 'comprimidos',
            dataHora: criadoEm,
            observacao: const Value('Estoque inicial'),
          ),
        );
  }

  return const CenarioMedicacaoWidget(
    medicamentoId: medicamentoId,
    tratamentoId: tratamentoId,
  );
}

Future<void> inserirRegistroHistoricoWidget(
  AppDatabase db, {
  required CenarioMedicacaoWidget cenario,
  required String id,
  required DateTime programada,
  required DateTime acao,
  required String status,
}) => db
    .into(db.registrosDose)
    .insert(
      RegistrosDoseCompanion.insert(
        id: id,
        doseKey: 'dose-key-$id',
        tratamentoId: cenario.tratamentoId,
        medicamentoId: cenario.medicamentoId,
        dataHoraProgramada: programada,
        dataHoraAcao: acao,
        quantidadeDose: 1,
        unidadeDose: 'comprimido',
        status: status,
        criadoEm: acao,
        atualizadoEm: acao,
      ),
    );

Future<void> tocarBotaoPreenchido(WidgetTester tester, String texto) async {
  final candidatos = find.widgetWithText(FilledButton, texto);
  expect(candidatos, findsWidgets);

  var visiveis = candidatos.hitTestable();
  if (visiveis.evaluate().isEmpty) {
    final stepper = find.byType(Stepper);
    expect(stepper, findsOneWidget);
    final rolagem = find.descendant(
      of: stepper,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable &&
            widget.physics is AlwaysScrollableScrollPhysics,
      ),
    );
    expect(rolagem, findsOneWidget);
    await tester.scrollUntilVisible(candidatos.last, 240, scrollable: rolagem);
    await tester.pump();
    visiveis = candidatos.hitTestable();
  }

  expect(visiveis, findsOneWidget);
  await tester.tap(visiveis);
  await bombearInterface(tester);
}

Future<void> selecionarEtapaStepper(WidgetTester tester, int indice) async {
  final stepper = find.byType(Stepper);
  expect(stepper, findsOneWidget);
  final widget = tester.widget<Stepper>(stepper);
  expect(widget.onStepTapped, isA<void Function(int)>());
  widget.onStepTapped!(indice);
  await bombearInterface(tester);
}
