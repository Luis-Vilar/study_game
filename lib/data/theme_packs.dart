import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/theme_pack.dart';

/// Ids de los packs disponibles. Agregar un tema es sumar un id acá y un
/// JSON en `assets/themes/`.
const List<String> kThemeIds = ['futebol', 'musica', 'games'];

Future<Map<String, ThemePack>> loadThemePacks(AssetBundle bundle) async {
  final packs = <String, ThemePack>{};
  for (final id in kThemeIds) {
    final raw = await bundle.loadString('assets/themes/$id.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    packs[id] = ThemePack.fromJson(json);
  }
  return packs;
}
