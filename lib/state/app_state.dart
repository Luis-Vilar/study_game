import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/mock_students.dart';
import '../models/student.dart';
import '../models/theme_pack.dart';

/// Estado único de la demo: herói, tema actual y colegas.
///
/// Vive en memoria: al reiniciar la app todo vuelve al estado inicial.
class AppState extends ChangeNotifier {
  AppState({
    required this.packs,
    String initialThemeId = 'futebol',
    Student? hero,
    List<Student>? classmates,
  })  : _themeId =
            packs.containsKey(initialThemeId) ? initialThemeId : packs.keys.first,
        _hero = hero ?? kHero,
        _classmates = List<Student>.from(classmates ?? kClassmates);

  final Map<String, ThemePack> packs;

  String _themeId;
  Student _hero;
  final List<Student> _classmates;

  String get themeId => _themeId;

  ThemePack get theme => packs[_themeId]!;

  Student get hero => _hero;

  List<Student> get classmates => List<Student>.unmodifiable(_classmates);

  int get heroLevel => _hero.points ~/ 250 + 1;

  /// Posición en la turma: cuántos colegas tienen más puntos, más uno.
  int get rank => _classmates.where((c) => c.points > _hero.points).length + 1;

  void selectTheme(String id) {
    if (!packs.containsKey(id) || id == _themeId) return;
    _themeId = id;
    notifyListeners();
  }

  void updateHero({String? name, String? emoji, Color? color}) {
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isEmpty) return;
    _hero = _hero.copyWith(name: trimmed, emoji: emoji, color: color);
    notifyListeners();
  }

  void addPoints(int amount) {
    if (amount == 0) return;
    _hero = _hero.copyWith(points: _hero.points + amount);
    notifyListeners();
  }

  void bumpStreak() {
    _hero = _hero.copyWith(streak: _hero.streak + 1);
    notifyListeners();
  }
}
