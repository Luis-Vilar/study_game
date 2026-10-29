import 'package:flutter/material.dart';

import '../models/theme_pack.dart';
import '../state/app_scope.dart';
import '../widgets/classmate_tile.dart';
import '../widgets/hero_drawer.dart';
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
        drawer: const HeroDrawer(),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Tooltip(
                message: 'Abrir menu',
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: state.hero.color.withValues(alpha: 0.2),
                    child: Text(
                      state.hero.emoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                  _DuelList(theme: theme),
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

class _DuelList extends StatelessWidget {
  const _DuelList({required this.theme});

  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final ranked = [...state.classmates]
      ..sort((a, b) => b.points.compareTo(a.points));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
      itemCount: ranked.length + 2,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) return _HeroCard(theme: theme);
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 2),
            child: Text(
              theme.word('classmates'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.colors.textSecondary,
              ),
            ),
          );
        }
        final student = ranked[index - 2];
        return ClassmateTile(student: student, onChallenge: () {});
      },
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.theme});

  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final hero = state.hero;
    final progress = (hero.points % 250) / 250;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(theme.radius),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(hero.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hero.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${theme.word('level')} ${state.heroLevel} · #${state.rank}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colors.accent),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        theme.word('practice'),
        style: TextStyle(color: theme.colors.textSecondary),
      ),
    );
  }
}
