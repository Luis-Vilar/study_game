import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/app.dart';
import 'support/test_packs.dart';

void main() {
  testWidgets('home mostra abas, pontos e o título do tema', (tester) async {
    final packs = await loadTestPacks();
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    expect(find.text('Studdy FC'), findsOneWidget);
    expect(find.text('Duelos'), findsOneWidget);
    expect(find.text('Praticar'), findsOneWidget);
    expect(find.text('320'), findsWidgets);
  });

  testWidgets('trocar para Games muda o título do app sem perder pontos',
      (tester) async {
    final packs = await loadTestPacks();
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(700, 400));
    await tester.pumpAndSettle();

    expect(find.text('STUDDY.EXE'), findsOneWidget);
    expect(find.text('320'), findsWidgets);
  });

  testWidgets('desafiar abre a folha com as três matérias', (tester) async {
    final packs = await loadTestPacks();
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('RETAR').first);
    await tester.pumpAndSettle();

    expect(find.text('Matemática'), findsOneWidget);
    expect(find.text('História'), findsOneWidget);
    expect(find.text('Ciências'), findsOneWidget);
  });

  testWidgets('praticar tem botão de começar', (tester) async {
    final packs = await loadTestPacks();
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Praticar'));
    await tester.pumpAndSettle();

    expect(find.text('Começar'), findsOneWidget);
  });

  testWidgets('praticar soma 250 pontos ao acertar as 5', (tester) async {
    final packs = await loadTestPacks();
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Praticar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    for (final answer in ['5', '1822', 'Célula', '42', 'Pau-brasil']) {
      await tester.tap(find.text(answer));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
    }
    await tester.pumpAndSettle();

    expect(find.text('570'), findsOneWidget);
  });
}
