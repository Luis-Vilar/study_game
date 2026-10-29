import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/app.dart';
import 'package:studdy_game/data/theme_packs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home mostra abas, pontos e o título do tema', (tester) async {
    final packs = await loadThemePacks(rootBundle);
    await tester.pumpWidget(StuddyApp(packs: packs));
    await tester.pumpAndSettle();

    expect(find.text('Studdy FC'), findsOneWidget);
    expect(find.text('Duelos'), findsOneWidget);
    expect(find.text('Praticar'), findsOneWidget);
    expect(find.text('320'), findsWidgets);
  });
}
