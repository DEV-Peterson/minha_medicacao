import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minha_medicacao/core/banco/app_database.dart';

import 'suporte_widget.dart';

void main() {
  final agora = DateTime(2026, 8, 18, 10);

  Future<void> inativar(AppDatabase db, String medicamentoId) async {
    await (db.update(db.medicamentos)
          ..where((tabela) => tabela.id.equals(medicamentoId)))
        .write(const MedicamentosCompanion(ativo: Value(false)));
    await (db.update(db.tratamentos)
          ..where((tabela) => tabela.medicamentoId.equals(medicamentoId)))
        .write(const TratamentosCompanion(ativo: Value(false)));
  }

  Future<void> abrirAba(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.medication_outlined));
    await bombearInterface(tester);
  }

  testWidgetsComBanco('inativado sai da lista e volta pela busca', (
    tester,
    db,
  ) async {
    final cenario = await semearMedicacaoWidget(db, dataReferencia: agora);
    await inativar(db, cenario.medicamentoId);
    await montarAplicativo(tester, db: db, agora: agora);
    await abrirAba(tester);

    expect(find.text('Losartana 50 mg'), findsNothing);
    expect(find.text('Nenhum medicamento ativo.'), findsOneWidget);
    expect(find.text('1 inativado'), findsOneWidget);

    await tester.tap(find.text('1 inativado'));
    await bombearInterface(tester);
    expect(find.text('Losartana 50 mg'), findsOneWidget);
  });

  testWidgetsComBanco('busca encontra medicamento inativado pelo nome', (
    tester,
    db,
  ) async {
    final cenario = await semearMedicacaoWidget(db, dataReferencia: agora);
    await inativar(db, cenario.medicamentoId);
    // Um segundo medicamento ativo faz o campo de busca aparecer.
    for (var indice = 0; indice < 4; indice++) {
      await db
          .into(db.medicamentos)
          .insert(
            MedicamentosCompanion.insert(
              id: 'ativo-$indice',
              nome: 'Metformina $indice',
              criadoEm: agora,
              atualizadoEm: agora,
            ),
          );
    }
    await montarAplicativo(tester, db: db, agora: agora);
    await abrirAba(tester);

    expect(find.text('Losartana 50 mg'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('campo_busca_medicamento')),
      'losar',
    );
    await bombearInterface(tester);

    expect(find.text('Inativados'), findsOneWidget);
    expect(find.text('Losartana 50 mg'), findsOneWidget);
    expect(find.text('Metformina 0'), findsNothing);
  });

  testWidgetsComBanco('exclui medicamento sem histórico pela tela', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(420, 1800));
    await semearMedicacaoWidget(db, dataReferencia: agora);
    await montarAplicativo(tester, db: db, agora: agora);
    await abrirAba(tester);

    await tester.tap(find.text('Losartana 50 mg'));
    await bombearInterface(tester);
    await tester.tap(find.text('Excluir medicamento'));
    // A tela consulta o histórico antes de decidir qual diálogo abrir.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await bombearInterface(tester);

    expect(find.text('Excluir medicamento?'), findsOneWidget);
    await tocarBotaoPreenchido(tester, 'Excluir');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await bombearInterface(tester);

    expect(await db.select(db.medicamentos).get(), isEmpty);
    expect(await db.select(db.tratamentos).get(), isEmpty);
    expect(find.text('Medicamento excluído.'), findsOneWidget);
  });

  testWidgetsComBanco('medicamento com histórico oferece inativar', (
    tester,
    db,
  ) async {
    usarTela(tester, const Size(420, 1800));
    final cenario = await semearMedicacaoWidget(db, dataReferencia: agora);
    await inserirRegistroHistoricoWidget(
      db,
      cenario: cenario,
      id: 'registro-1',
      programada: DateTime(2026, 8, 17, 8),
      acao: DateTime(2026, 8, 17, 8, 5),
      status: 'tomada',
    );
    await montarAplicativo(tester, db: db, agora: agora);
    await abrirAba(tester);

    await tester.tap(find.text('Losartana 50 mg'));
    await bombearInterface(tester);
    await tester.tap(find.text('Excluir medicamento'));
    // A tela consulta o histórico antes de decidir qual diálogo abrir.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await bombearInterface(tester);

    expect(find.text('Não é possível excluir'), findsOneWidget);
    expect(find.textContaining('1 dose registrada'), findsOneWidget);

    await tocarBotaoPreenchido(tester, 'Inativar');
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await bombearInterface(tester);

    final medicamento = await db.select(db.medicamentos).getSingle();
    expect(medicamento.ativo, isFalse);
    // O histórico continua intacto.
    expect(await db.select(db.registrosDose).get(), hasLength(1));
  });
}
