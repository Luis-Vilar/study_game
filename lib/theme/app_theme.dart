import 'package:flutter/material.dart';

import '../models/theme_pack.dart';

/// Traduce un pack de tema a un [ThemeData] de Material 3.
ThemeData buildAppTheme(ThemePack pack) {
  final colors = pack.colors;
  final fontFamily = pack.fontFamily == 'mono' ? 'monospace' : null;

  final scheme = ColorScheme.fromSeed(
    seedColor: colors.primary,
    brightness: pack.isDark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: colors.primary,
    secondary: colors.accent,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    onPrimary: pack.isDark ? colors.bg : Colors.white,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: fontFamily,
  );

  return base.copyWith(
    scaffoldBackgroundColor: colors.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: pack.uppercaseLabels ? 0.5 : 0,
        color: colors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(pack.radius),
        side: BorderSide(color: colors.surfaceAlt),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: pack.isDark ? colors.bg : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pack.radius * 0.6),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          letterSpacing: pack.uppercaseLabels ? 0.6 : 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.surfaceAlt),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(pack.radius * 0.6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(pack.radius * 0.6),
        borderSide: BorderSide.none,
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.surfaceAlt),
  );
}
