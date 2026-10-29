import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/models/theme_pack.dart';

Map<String, dynamic> jsonDecodeMap(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('futebol.json vira ThemePack completo', () async {
    final raw = await rootBundle.loadString('assets/themes/futebol.json');
    final pack = ThemePack.fromJson(jsonDecodeMap(raw));

    expect(pack.id, 'futebol');
    expect(pack.appTitle, 'Studdy FC');
    expect(pack.colors.primary, const Color(0xFF0B6E3A));
    expect(pack.word('challenge'), 'RETAR');
    expect(pack.text('duelWin'), isNotEmpty);
    expect(pack.isDark, isFalse);
  });

  test('promptFor cai no fallback quando o pack não tem o enunciado', () {
    final pack = ThemePack.fromJson(<String, dynamic>{
      'id': 'x',
      'name': 'X',
      'appTitle': 'X',
      'tagline': '',
      'fontFamily': 'sans',
      'uppercaseLabels': false,
      'radius': 12.0,
      'colors': <String, dynamic>{
        'bg': '#FFFFFF',
        'surface': '#FFFFFF',
        'surfaceAlt': '#EEEEEE',
        'primary': '#000000',
        'accent': '#FF0000',
        'textPrimary': '#111111',
        'textSecondary': '#666666',
      },
      'icons': <String, dynamic>{},
      'words': <String, dynamic>{},
      'copy': <String, dynamic>{},
      'prompts': <String, dynamic>{},
    });

    expect(pack.promptFor('m1', 'Quanto é 3 + 2?'), 'Quanto é 3 + 2?');
  });
}
