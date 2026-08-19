import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'suporte_widget.dart';

/// Estes testes falham automaticamente se algum layout estourar: o framework
/// registra a exceção de overflow e o `testWidgets` a propaga.
void main() {
  final agora = DateTime(2026, 8, 18, 10);

  testWidgetsComBanco('tela larga usa trilha lateral no lugar da barra', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(1280, 900));
    await semearMedicacaoWidget(db, dataReferencia: agora);
    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.byIcon(Icons.inventory_2_outlined));
    await bombearInterface(tester);
    expect(find.text('Sem controle de estoque'), findsOneWidget);
  });

  testWidgetsComBanco('celular pequeno percorre as quatro abas sem estouro', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(320, 640));
    await semearMedicacaoWidget(
      db,
      dataReferencia: agora,
      controlarEstoque: true,
      estoqueInicial: 6,
    );
    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.byType(NavigationBar), findsOneWidget);
    for (final icone in [
      Icons.medication_outlined,
      Icons.inventory_2_outlined,
      Icons.history_outlined,
      Icons.today_outlined,
    ]) {
      await tester.tap(find.byIcon(icone));
      await bombearInterface(tester);
    }
    expect(find.text('Próxima dose'), findsOneWidget);
  });

  testWidgetsComBanco('agenda do dia suporta fonte ampliada', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(360, 760), escalaDeFonte: 1.6);
    await semearMedicacaoWidget(db, dataReferencia: agora);
    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.text('Próxima dose'), findsOneWidget);
    expect(find.text('Tomei'), findsWidgets);
  });

  testWidgetsComBanco('formulário mostra o passo Tratamento sem cortar', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(360, 760));
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.text('Cadastrar medicamento'));
    await bombearInterface(tester);
    await tester.enterText(
      find.byKey(const Key('campo_nome_medicamento')),
      'Losartana',
    );
    await selecionarEtapaStepper(tester, 1);

    // O rótulo flutuante fica acima da borda do campo; se o passo não tiver
    // respiro no topo, o Stepper corta o texto.
    final rotulo = tester.getRect(find.text('Quantidade *').first);
    final passo = tester.getRect(find.text('Tratamento').first);
    expect(rotulo.top, greaterThan(passo.bottom));
    expect(find.text('Unidade *'), findsOneWidget);
  });

  testWidgetsComBanco('todos os passos do formulário cabem em tela estreita', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(320, 640));
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.text('Cadastrar medicamento'));
    await bombearInterface(tester);
    for (var passo = 0; passo <= 5; passo++) {
      await selecionarEtapaStepper(tester, passo);
    }
    expect(find.text('Revisão'), findsOneWidget);
  });

  testWidgetsComBanco('detalhes e configurações com fonte ampliada', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(360, 740), escalaDeFonte: 1.4);
    await semearMedicacaoWidget(
      db,
      dataReferencia: agora,
      controlarEstoque: true,
      estoqueInicial: 12,
    );
    await montarAplicativo(tester, db: db, agora: agora);

    await tester.tap(find.byIcon(Icons.medication_outlined));
    await bombearInterface(tester);
    await tester.tap(find.text('Losartana 50 mg').first);
    await bombearInterface(tester);
    expect(find.text('Detalhes'), findsOneWidget);

    // A interface está em pt-BR, então o botão de voltar usa "Voltar" como
    // tooltip; `pageBack` procura o rótulo em inglês.
    await tester.tap(find.byTooltip('Voltar'));
    await bombearInterface(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await bombearInterface(tester);
    expect(find.text('Configurações'), findsOneWidget);
  });

  testWidgetsComBanco('celular em paisagem mantém a agenda utilizável', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(740, 360));
    await semearMedicacaoWidget(db, dataReferencia: agora);
    await montarAplicativo(tester, db: db, agora: agora);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Próxima dose'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.history_outlined));
    await bombearInterface(tester);
    expect(find.text('Nenhuma dose registrada neste período.'), findsOneWidget);
  });
}
