import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/theme_packs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packs = await loadThemePacks(rootBundle);
  runApp(StuddyApp(packs: packs));
}
