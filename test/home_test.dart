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
}
