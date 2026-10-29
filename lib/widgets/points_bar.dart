import 'package:flutter/material.dart';

import '../models/theme_pack.dart';
import '../state/app_scope.dart';

/// Chips compactos con puntos y sequência del herói.
class PointsBar extends StatelessWidget {
  const PointsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = state.theme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(
          icon: theme.icons['points'] ?? '⭐',
          value: '${state.hero.points}',
          theme: theme,
        ),
        const SizedBox(width: 6),
        _Chip(
          icon: theme.icons['streak'] ?? '🔥',
          value: '${state.hero.streak}',
          theme: theme,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.value,
    required this.theme,
  });

  final String icon;
  final String value;
  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colors.surfaceAlt,
        borderRadius: BorderRadius.circular(theme.radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: theme.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
