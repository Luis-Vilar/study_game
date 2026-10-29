import 'package:flutter/material.dart';

import '../models/theme_pack.dart';
import '../state/app_scope.dart';
import '../widgets/points_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = state.theme;
    final hasGradient = theme.gradient != null;

    final screen = DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: hasGradient ? Colors.transparent : theme.colors.bg,
        appBar: AppBar(
          title: Text(theme.appTitle),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: PointsBar(),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(theme.radius),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: theme.colors.surface,
                    borderRadius: BorderRadius.circular(theme.radius * 0.7),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: theme.colors.textPrimary,
                  unselectedLabelColor: theme.colors.textSecondary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Duelos'),
                    Tab(text: 'Praticar'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DuelListPlaceholder(theme: theme),
                  _PracticeTabPlaceholder(theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return hasGradient
        ? DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradient!,
              ),
            ),
            child: screen,
          )
        : screen;
  }
}

class _DuelListPlaceholder extends StatelessWidget {
  const _DuelListPlaceholder({required this.theme});

  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${theme.word('classmates')}',
        style: TextStyle(color: theme.colors.textSecondary),
      ),
    );
  }
}

class _PracticeTabPlaceholder extends StatelessWidget {
  const _PracticeTabPlaceholder({required this.theme});

  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '${theme.word('practice')}',
        style: TextStyle(color: theme.colors.textSecondary),
      ),
    );
  }
}
