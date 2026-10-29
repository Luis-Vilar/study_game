import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/data/questions.dart';
import 'support/test_packs.dart';
import 'package:studdy_game/models/question.dart';

void main() {
  test('todo pack tem enunciado para as 18 perguntas', () async {
    final packs = await loadTestPacks();
    for (final pack in packs.values) {
      for (final q in kQuestions) {
        expect(
          pack.promptFor(q.id, ''),
          isNotEmpty,
          reason: '${pack.id} sem enunciado para ${q.id}',
        );
      }
    }
  });

  test('os números do enunciado base aparecem em todos os temas', () async {
    final packs = await loadTestPacks();
    for (final q in kQuestions) {
      final numbers =
          RegExp(r'\d+').allMatches(q.basePrompt).map((m) => m[0]!).toList();
      for (final pack in packs.values) {
        for (final n in numbers) {
          expect(
            pack.prompts[q.id],
            contains(n),
            reason: '${q.id} em ${pack.id} perdeu o número $n',
          );
        }
      }
    }
  });

  test('cada matéria tem 6 perguntas com 4 opções e resposta entre elas', () {
    for (final s in Subject.values) {
      final qs = questionsFor(s);
      expect(qs.length, 6);
      for (final q in qs) {
        expect(q.options.length, 4);
        expect(q.options, contains(q.answer));
      }
    }
  });
}
