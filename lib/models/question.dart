import 'theme_pack.dart';

enum Subject { matematica, historia, ciencias }

extension SubjectX on Subject {
  String get label => switch (this) {
    Subject.matematica => 'Matemática',
    Subject.historia => 'História',
    Subject.ciencias => 'Ciências',
  };

  String get key => switch (this) {
    Subject.matematica => 'matematica',
    Subject.historia => 'historia',
    Subject.ciencias => 'ciencias',
  };
}

/// Pregunta base: la respuesta y las opciones no cambian entre temas.
/// Lo único que cambia es el enunciado, que vive en el pack del tema.
class Question {
  const Question({
    required this.id,
    required this.subject,
    required this.difficulty,
    required this.basePrompt,
    required this.options,
    required this.answer,
  });

  final String id;
  final Subject subject;

  /// 1 = fácil, 2 = media, 3 = difícil.
  final int difficulty;

  final String basePrompt;
  final List<String> options;
  final String answer;

  String promptFor(ThemePack pack) => pack.promptFor(id, basePrompt);
}
