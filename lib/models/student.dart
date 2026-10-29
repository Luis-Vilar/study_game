import 'dart:ui';

import 'question.dart';

/// Persona del juego: el herói y cada colega de la lista.
class Student {
  const Student({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.favoriteSubject,
    required this.points,
    required this.level,
    required this.streak,
  });

  final String id;
  final String name;
  final String emoji;
  final Color color;
  final Subject favoriteSubject;
  final int points;
  final int level;
  final int streak;

  Student copyWith({
    String? name,
    String? emoji,
    Color? color,
    int? points,
    int? level,
    int? streak,
  }) {
    return Student(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      favoriteSubject: favoriteSubject,
      points: points ?? this.points,
      level: level ?? this.level,
      streak: streak ?? this.streak,
    );
  }
}
