import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/models/theme_pack.dart';
import 'package:studdy_game/state/app_state.dart';

ThemePack _pack(String id, int bg) {
  final hex = '#${(bg & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  return ThemePack.fromJson(<String, dynamic>{
    'id': id,
    'name': id,
    'appTitle': id,
    'tagline': '',
    'colors': <String, dynamic>{
      'bg': hex,
      'surface': hex,
      'surfaceAlt': hex,
      'primary': '#0B6E3A',
      'accent': '#C6F432',
      'textPrimary': '#10261A',
      'textSecondary': '#4B6B57',
    },
    'icons': <String, dynamic>{},
    'words': <String, dynamic>{},
    'copy': <String, dynamic>{},
    'prompts': <String, dynamic>{},
  });
}

void main() {
  late AppState state;
  setUp(() {
    state = AppState(
      packs: {
        'futebol': _pack('futebol', 0xFFF4FBF0),
        'games': _pack('games', 0xFF0F1117),
      },
    );
  });

  test('herói começa com 320 pontos, nível 2 e sequência 4', () {
    expect(state.hero.points, 320);
    expect(state.heroLevel, 2);
    expect(state.hero.streak, 4);
  });

  test('trocar de tema notifica e mantém pontos', () {
    var notified = 0;
    state.addListener(() => notified++);
    state.addPoints(100);
    state.selectTheme('games');
    expect(state.themeId, 'games');
    expect(state.hero.points, 420);
    expect(notified, 2);
  });

  test('edições do herói persistem na sessão', () {
    state.updateHero(name: 'Bia', emoji: '🦊', color: const Color(0xFF00AAFF));
    expect(state.hero.name, 'Bia');
    expect(state.hero.emoji, '🦊');
    expect(state.hero.color, const Color(0xFF00AAFF));
  });

  test('sequência sobe uma vez por atividade concluída', () {
    state.bumpStreak();
    expect(state.hero.streak, 5);
  });

  test('rank conta quantos colegas têm mais pontos', () {
    expect(state.rank, greaterThan(1));
  });
}
