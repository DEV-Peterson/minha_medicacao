import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';
import 'package:minha_medicacao/features/estoque/dados/estoque_repository.dart';

import 'suporte_widget.dart';

void main() {
  final agora = DateTime(2026, 8, 18, 10);

  testWidgetsComBanco('home vazia orienta o cadastro do primeiro medicamento', (
    tester,
    db,
  ) async {
    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.text('Nenhum medicamento cadastrado'), findsOneWidget);
    expect(
      find.text('Cadastre o primeiro medicamento para montar sua agenda.'),
      findsOneWidget,
    );
    expect(find.text('Cadastrar medicamento'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgetsComBanco(
    'home diferencia medicamento cadastrado sem dose no dia',
    (tester, db) async {
      final cenario = await semearMedicacaoWidget(db, dataReferencia: agora);
      await (db.update(
        db.tratamentos,
      )..where((table) => table.id.equals(cenario.tratamentoId))).write(
        TratamentosCompanion(dataInicio: Value(DateTime(2026, 8, 19))),
      );

      await montarAplicativo(tester, db: db, agora: agora);

      expect(find.text('Nenhuma dose programada para hoje'), findsOneWidget);
      expect(find.text('Nenhum medicamento cadastrado'), findsNothing);
    },
  );

  testWidgetsComBanco('home mostra resumo, próxima dose e estados do dia', (
    tester,
    db,
  ) async {
    await semearMedicacaoWidget(db, dataReferencia: agora);

    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.text('0 de 2 doses tomadas'), findsOneWidget);
    expect(find.text('2 doses restantes hoje'), findsOneWidget);
    expect(find.text('Próxima dose'), findsOneWidget);
    expect(find.text('Doses de hoje'), findsOneWidget);
    expect(
      find.text('Dose não confirmada. Horário previsto: 08:00'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Pendente'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Losartana 50 mg'), findsWidgets);
  });

  testWidgetsComBanco('confirmar dose atualiza home e cria somente uma saída', (
    tester,
    db,
  ) async {
    await semearMedicacaoWidget(
      db,
      dataReferencia: agora,
      horarios: const [(8, 0)],
      controlarEstoque: true,
      estoqueInicial: 10,
    );

    await montarAplicativo(tester, db: db, agora: agora);

    final botaoTomei = find.widgetWithText(FilledButton, 'Tomei').first;
    await tester.ensureVisible(botaoTomei);
    await tester.tap(botaoTomei);
    await bombearInterface(tester);

    final registros = await db.select(db.registrosDose).get();
    final movimentos = await db.select(db.movimentacoesEstoque).get();
    expect(find.text('1 de 1 doses tomadas'), findsOneWidget);
    expect(find.text('Nenhuma dose pendente hoje'), findsOneWidget);
    expect(find.text('Tomada às 10:00'), findsOneWidget);
    expect(registros, hasLength(1));
    expect(registros.single.status, 'tomada');
    expect(movimentos.where((item) => item.tipo == 'saidaDose'), hasLength(1));
  });

  testWidgetsComBanco(
    'formulário cadastra medicamento com tratamento e horário',
    (tester, db) async {
      await montarAplicativo(tester, db: db, agora: agora);

      await tester.tap(find.text('Cadastrar medicamento'));
      await bombearInterface(tester);
      expect(find.text('Novo medicamento'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('campo_nome_medicamento')),
        'Losartana',
      );
      tester.testTextInput.hide();
      await selecionarEtapaStepper(tester, 5);
      expect(find.text('Revisão'), findsOneWidget);
      await tocarBotaoPreenchido(tester, 'Salvar');
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await bombearInterface(tester);

      final medicamentos = await db.select(db.medicamentos).get();
      final tratamentos = await db.select(db.tratamentos).get();
      final horarios = await db.select(db.horariosTratamento).get();
      expect(medicamentos, hasLength(1));
      expect(medicamentos.single.nome, 'Losartana');
      expect(tratamentos, hasLength(1));
      expect(tratamentos.single.dataInicio, DateTime(2026, 8, 18));
      expect(horarios, hasLength(1));
      expect((horarios.single.hora, horarios.single.minuto), (8, 0));
      expect(find.text('Novo medicamento'), findsNothing);
      expect(find.text('Losartana'), findsWidgets);
    },
  );

  testWidgetsComBanco('adicionar estoque atualiza ledger, saldo e cartão', (
    tester,
    db,
  ) async {
    await semearMedicacaoWidget(
      db,
      dataReferencia: agora,
      controlarEstoque: true,
      estoqueInicial: 6,
    );
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await bombearInterface(tester);
    expect(find.text('Restam: 6 comprimidos'), findsOneWidget);

    await tester.tap(find.text('Adicionar estoque'));
    await bombearInterface(tester);
    await tester.enterText(
      find.byKey(const Key('campo_quantidade_estoque')),
      '30',
    );
    await tocarBotaoPreenchido(tester, 'Salvar');

    final saldo = await EstoqueRepository(
      db,
    ).calcularSaldo('medicamento-widget');
    final movimentos = await db.select(db.movimentacoesEstoque).get();
    expect(find.text('Estoque adicionado.'), findsOneWidget);
    expect(find.text('Restam: 36 comprimidos'), findsOneWidget);
    expect(saldo, 36);
    expect(
      movimentos.where((item) => item.tipo == 'entradaReposicao'),
      hasLength(2),
    );
  });

  testWidgetsComBanco('histórico agrupa tomadas e não tomadas por data', (
    tester,
    db,
  ) async {
    final cenario = await semearMedicacaoWidget(db, dataReferencia: agora);
    await inserirRegistroHistoricoWidget(
      db,
      cenario: cenario,
      id: 'registro-tomada',
      programada: DateTime(2026, 8, 18, 8),
      acao: DateTime(2026, 8, 18, 8, 7),
      status: 'tomada',
    );
    await inserirRegistroHistoricoWidget(
      db,
      cenario: cenario,
      id: 'registro-nao-tomada',
      programada: DateTime(2026, 8, 17, 20),
      acao: DateTime(2026, 8, 17, 20, 30),
      status: 'naoTomada',
    );
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.byIcon(Icons.history_outlined));
    await bombearInterface(tester);

    expect(find.text('18/08/2026'), findsOneWidget);
    expect(find.text('17/08/2026'), findsOneWidget);
    expect(find.text('08:00  Losartana 50 mg'), findsOneWidget);
    expect(find.text('20:00  Losartana 50 mg'), findsOneWidget);
    expect(find.text('Tomada às 08:07'), findsOneWidget);
    expect(find.text('Não tomada'), findsOneWidget);
  });

  testWidgetsComBanco('ativar controle de estoque registra saldo inicial', (
    tester,
    db,
  ) async {
    await semearMedicacaoWidget(db, dataReferencia: agora);
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await bombearInterface(tester);
    expect(
      find.text('Controle não ativado para este medicamento.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Ativar controle de estoque'));
    await bombearInterface(tester);
    await tester.enterText(
      find.byKey(const Key('campo_unidade_estoque')),
      'comprimidos',
    );
    await tester.enterText(
      find.byKey(const Key('campo_quantidade_disponivel')),
      '10',
    );
    await tester.enterText(
      find.byKey(const Key('campo_consumo_por_dose')),
      '1',
    );
    await tocarBotaoPreenchido(tester, 'Ativar');

    final medicamento = await (db.select(
      db.medicamentos,
    )..where((tabela) => tabela.id.equals('medicamento-widget'))).getSingle();
    final tratamento = await db.select(db.tratamentos).getSingle();
    final movimentos = await db.select(db.movimentacoesEstoque).get();

    expect(find.text('Controle de estoque ativado.'), findsOneWidget);
    expect(find.text('Restam: 10 comprimidos'), findsOneWidget);
    expect(medicamento.controleEstoque, isTrue);
    expect(medicamento.unidadeEstoque, 'comprimidos');
    expect(tratamento.consumoEstoquePorDose, 1);
    expect(movimentos, hasLength(1));
    expect(movimentos.single.tipo, 'entradaReposicao');
    expect(movimentos.single.quantidade, 10);
  });
}
