import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/app.dart';

import 'support/test_packs.dart';

Future<void> _openDuel(WidgetTester tester, {String subject = 'Matemática'}) async {
  final packs = await loadTestPacks();
  await tester.pumpWidget(StuddyApp(packs: packs));
  await tester.pumpAndSettle();
  await tester.tap(find.text('RETAR').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(subject));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('responder as 5 perguntas leva ao resultado e soma pontos',
      (tester) async {
    await _openDuel(tester);
    expect(find.text('Pergunta 1 de 5'), findsOneWidget);

    for (final answer in ['5', '8', '42', '8', '15']) {
      await tester.tap(find.text(answer));
      await tester.pump(); // feedback
      await tester.pump(const Duration(milliseconds: 700)); // avança
    }
    await tester.pumpAndSettle();

    expect(find.text('Voltar aos duelos'), findsOneWidget);
    expect(find.text('600'), findsOneWidget);

    await tester.tap(find.text('Voltar aos duelos'));
    await tester.pumpAndSettle();
    expect(find.text('920'), findsOneWidget);
  });

  testWidgets('tempo esgotado fecha a pergunta e avança', (tester) async {
    await _openDuel(tester);
    expect(find.text('Pergunta 1 de 5'), findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Pergunta 2 de 5'), findsOneWidget);
  });

  testWidgets('sair do duelo cancela o timer', (tester) async {
    await _openDuel(tester);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Studdy FC'), findsOneWidget);
  });
}
