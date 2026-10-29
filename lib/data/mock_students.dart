import 'dart:ui';

import '../models/question.dart';
import '../models/student.dart';

const Student kHero = Student(
  id: 'hero',
  name: 'Você',
  emoji: '🦸',
  color: Color(0xFF0B6E3A),
  favoriteSubject: Subject.matematica,
  points: 320,
  level: 2,
  streak: 4,
);

const List<Student> kClassmates = [
  Student(
    id: 'ana',
    name: 'Ana Ruiz',
    emoji: '👩‍🎓',
    color: Color(0xFFFF9F0A),
    favoriteSubject: Subject.matematica,
    points: 1240,
    level: 9,
    streak: 6,
  ),
  Student(
    id: 'diego',
    name: 'Diego Paz',
    emoji: '🧑‍🚀',
    color: Color(0xFF5E5CE6),
    favoriteSubject: Subject.ciencias,
    points: 980,
    level: 7,
    streak: 3,
  ),
  Student(
    id: 'luz',
    name: 'Luz Mora',
    emoji: '👩‍🔬',
    color: Color(0xFF34C759),
    favoriteSubject: Subject.historia,
    points: 1450,
    level: 10,
    streak: 8,
  ),
  Student(
    id: 'iker',
    name: 'Iker Sosa',
    emoji: '🧑‍🎤',
    color: Color(0xFFFF3B30),
    favoriteSubject: Subject.matematica,
    points: 2010,
    level: 15,
    streak: 12,
  ),
  Student(
    id: 'nina',
    name: 'Nina Alves',
    emoji: '👩‍💻',
    color: Color(0xFF00B8D9),
    favoriteSubject: Subject.ciencias,
    points: 1120,
    level: 8,
    streak: 5,
  ),
  Student(
    id: 'theo',
    name: 'Theo Lima',
    emoji: '🧑‍🎨',
    color: Color(0xFFAF52DE),
    favoriteSubject: Subject.historia,
    points: 1780,
    level: 13,
    streak: 9,
  ),
];
