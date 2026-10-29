import 'package:flutter/material.dart';

import 'models/theme_pack.dart';
import 'state/app_state.dart';
import 'state/app_scope.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

class StuddyApp extends StatefulWidget {
  const StuddyApp({
    super.key,
    required this.packs,
    this.initialThemeId = 'futebol',
  });

  final Map<String, ThemePack> packs;
  final String initialThemeId;

  @override
  State<StuddyApp> createState() => _StuddyAppState();
}

class _StuddyAppState extends State<StuddyApp> {
  late final AppState _state = AppState(
    packs: widget.packs,
    initialThemeId: widget.initialThemeId,
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          final theme = _state.theme;
          return MaterialApp(
            title: theme.appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(theme),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
