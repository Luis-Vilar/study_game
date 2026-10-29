import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/models/duel_engine.dart';
import 'package:studdy_game/models/question.dart';

List<Question> _five() => List<Question>.generate(
      5,
      (i) => Question(
        id: 'q$i',
        subject: Subject.matematica,
        difficulty: 1,
        basePrompt: 'Quanto é 3 + 2?',
        options: const ['4', '5', '6', '7'],
        answer: '5',
      ),
    );

void main() {
  test('acerto rápido vale 120 e acerto lento 100', () {
    expect(pointsForAnswer(correct: true, elapsedMs: 4999), 120);
    expect(pointsForAnswer(correct: true, elapsedMs: 5001), 100);
    expect(pointsForAnswer(correct: false, elapsedMs: 1000), 0);
  });

  test('tempo esgotado fecha a pergunta como errada', () {
    final engine = DuelEngine(questions: _five(), opponentScore: 300);
    expect(engine.answer('', 15000), isFalse);
    expect(engine.correct, 0);
    expect(engine.index, 1);
  });

  test('placar do oponente fica entre 180 e 600', () {
    final r = Random(7);
    for (var i = 0; i < 200; i++) {
      final s = opponentScore(r);
      expect(s, inInclusiveRange(180, 600));
    }
  });

  test('responder as 5 encerra o duelo e calcula o resultado', () {
    final engine = DuelEngine(questions: _five(), opponentScore: 400);
    for (var i = 0; i < 5; i++) {
      engine.answer(engine.current.answer, 6000);
    }
    expect(engine.finished, isTrue);
    expect(engine.result.correct, 5);
    expect(engine.result.score, 500);
    expect(engine.result.won, isTrue);
  });
}
