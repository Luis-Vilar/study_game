import 'dart:ui';

/// Paleta de un pack de tema.
class ThemeColors {
  const ThemeColors({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;

  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    return ThemeColors(
      bg: _hex(json['bg'] as String),
      surface: _hex(json['surface'] as String),
      surfaceAlt: _hex(json['surfaceAlt'] as String),
      primary: _hex(json['primary'] as String),
      accent: _hex(json['accent'] as String),
      textPrimary: _hex(json['textPrimary'] as String),
      textSecondary: _hex(json['textSecondary'] as String),
    );
  }

  static Color _hex(String value) {
    final cleaned = value.replaceFirst('#', '');
    return Color(int.parse(cleaned, radix: 16) | 0xFF000000);
  }
}

/// Pack de tema: paleta, tipografia, vocabulário, textos y enunciados.
///
/// Un pack nuevo entra agregando un JSON en `assets/themes/`; no se toca
/// código de pantallas.
class ThemePack {
  const ThemePack({
    required this.id,
    required this.name,
    required this.appTitle,
    required this.tagline,
    required this.fontFamily,
    required this.uppercaseLabels,
    required this.radius,
    required this.colors,
    required this.icons,
    required this.words,
    required this.copy,
    required this.prompts,
    this.gradient,
  });

  final String id;
  final String name;
  final String appTitle;
  final String tagline;
  final String fontFamily;
  final bool uppercaseLabels;
  final double radius;
  final ThemeColors colors;
  final List<Color>? gradient;
  final Map<String, String> icons;
  final Map<String, String> words;
  final Map<String, String> copy;
  final Map<String, String> prompts;

  factory ThemePack.fromJson(Map<String, dynamic> json) {
    final gradient = json['gradient'] as List<dynamic>?;
    return ThemePack(
      id: json['id'] as String,
      name: json['name'] as String,
      appTitle: json['appTitle'] as String,
      tagline: (json['tagline'] ?? '') as String,
      fontFamily: (json['fontFamily'] ?? 'sans') as String,
      uppercaseLabels: (json['uppercaseLabels'] ?? false) as bool,
      radius: ((json['radius'] ?? 12) as num).toDouble(),
      colors: ThemeColors.fromJson(json['colors'] as Map<String, dynamic>),
      gradient:
          gradient?.map((value) => ThemeColors._hex(value as String)).toList(),
      icons: _stringMap(json['icons']),
      words: _stringMap(json['words']),
      copy: _stringMap(json['copy']),
      prompts: _stringMap(json['prompts']),
    );
  }

  bool get isDark => colors.bg.computeLuminance() < 0.4;

  String word(String key) => words[key] ?? '';

  String text(String key) => copy[key] ?? '';

  String promptFor(String questionId, String fallback) =>
      prompts[questionId] ?? fallback;

  static Map<String, String> _stringMap(Object? source) {
    if (source is! Map) return <String, String>{};
    return source.map((key, value) => MapEntry(key as String, '$value'));
  }
}
