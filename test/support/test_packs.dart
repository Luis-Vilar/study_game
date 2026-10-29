import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:studdy_game/data/theme_packs.dart';
import 'package:studdy_game/models/theme_pack.dart';

/// Bundle que lee los packs desde el disco.
///
/// `rootBundle` cachea los futuros en la zona del primer test y deja colgado
/// al segundo `testWidgets`; leer del disco evita ese estado global.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final bytes = File(key).readAsBytesSync();
    return ByteData.view(Uint8List.fromList(bytes).buffer);
  }
}

Future<Map<String, ThemePack>> loadTestPacks() => loadThemePacks(_DiskBundle());
