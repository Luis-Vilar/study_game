import 'dart:math';

import 'question.dart';

const int kQuestionsPerDuel = 5;
const int kSecondsPerQuestion = 15;

/// Puntos de una respuesta: 100 por acertar, 20 extra si fue en ≤ 5 s.
int pointsForAnswer({required bool correct, required int elapsedMs}) {
  if (!correct) return 0;
  return elapsedMs <= 5000 ? 120 : 100;
}

/// Puntos de la práctica solo.
int practicePoints(bool correct) => correct ? 50 : 0;

/// Placar simulado del rival: 180 a 600, independiente de su total acumulado.
int opponentScore(Random random) => 180 + random.nextInt(421);

class DuelResult {
  const DuelResult({
    required this.score,
    required this.opponentScore,
    required this.correct,
    required this.total,
  });

  final int score;
  final int opponentScore;
  final int correct;
  final int total;

  bool get tied => score == opponentScore;

  bool get won => score > opponentScore;
}

/// Motor puro del duelo: sin widgets, sin timers, fácil de testear.
class DuelEngine {
  DuelEngine({required this.questions, required this.opponentScore});

  final List<Question> questions;
  final int opponentScore;

  int index = 0;
  int correct = 0;
  int score = 0;

  Question get current => questions[index];

  bool get finished => index >= questions.length;

  /// Registra una respuesta y avanza. Devuelve si fue correcta.
  bool answer(String option, int elapsedMs) {
    if (finished) return false;
    final wasCorrect = option == current.answer;
    if (wasCorrect) correct++;
    score += pointsForAnswer(correct: wasCorrect, elapsedMs: elapsedMs);
    index++;
    return wasCorrect;
  }

  DuelResult get result => DuelResult(
        score: score,
        opponentScore: opponentScore,
        correct: correct,
        total: questions.length,
      );
}
