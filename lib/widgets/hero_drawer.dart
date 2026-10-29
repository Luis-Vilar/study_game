import 'package:flutter/material.dart';

import '../state/app_scope.dart';

const List<String> _kAvatars = [
  '🦸',
  '🧑‍🚀',
  '🦊',
  '🐯',
  '🐼',
  '👾',
  '🧙',
  '🏆',
];

const List<Color> _kColors = [
  Color(0xFF0B6E3A),
  Color(0xFF00B8D9),
  Color(0xFF8F5BFF),
  Color(0xFFFF9F0A),
  Color(0xFFFF3B30),
  Color(0xFF1D1D1F),
];

/// Drawer para editar el herói y cambiar el tema en caliente.
class HeroDrawer extends StatefulWidget {
  const HeroDrawer({super.key});

  @override
  State<HeroDrawer> createState() => _HeroDrawerState();
}

class _HeroDrawerState extends State<HeroDrawer> {
  final TextEditingController _nameController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _nameController.text = AppScope.of(context).hero.name;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = state.theme;
    final hero = state.hero;

    return Drawer(
      backgroundColor: theme.colors.bg,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text(
              theme.text('drawerTitle'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: theme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: CircleAvatar(
                radius: 38,
                backgroundColor: hero.color.withValues(alpha: 0.2),
                child: Text(hero.emoji, style: const TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: ValueKey('hero-name-${hero.name}'),
              controller: _nameController,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onFieldSubmitted: (value) => state.updateHero(name: value),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${theme.word('level')} ${state.heroLevel} · #${state.rank}',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Avatar'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final avatar in _kAvatars)
                  _Choice(
                    selected: hero.emoji == avatar,
                    onTap: () => state.updateHero(emoji: avatar),
                    child: Text(avatar, style: const TextStyle(fontSize: 20)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Cor'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final color in _kColors)
                  GestureDetector(
                    onTap: () => state.updateHero(color: color),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: hero.color == color
                              ? theme.colors.textPrimary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Tema'),
            const SizedBox(height: 8),
            for (final pack in state.packs.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ThemeOption(
                  name: pack.name,
                  swatch: pack.colors.primary,
                  accent: pack.colors.accent,
                  selected: pack.id == state.themeId,
                  onTap: () => state.selectTheme(pack.id),
                ),
              ),
            const SizedBox(height: 12),
            Divider(color: theme.colors.surfaceAlt),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${theme.icons['points'] ?? '⭐'} ${hero.points}',
                    style: TextStyle(color: theme.colors.textPrimary)),
                Text(
                  '${theme.icons['streak'] ?? '🔥'} ${hero.streak} ${theme.word('streak')}',
                  style: TextStyle(color: theme.colors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: theme.colors.textSecondary,
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? theme.colors.surfaceAlt : theme.colors.surface,
          borderRadius: BorderRadius.circular(theme.radius * 0.7),
          border: Border.all(
            color: selected ? theme.colors.primary : theme.colors.surfaceAlt,
            width: 2,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.name,
    required this.swatch,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final Color swatch;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colors.surface,
          borderRadius: BorderRadius.circular(theme.radius * 0.7),
          border: Border.all(
            color: selected ? theme.colors.primary : theme.colors.surfaceAlt,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [swatch, accent]),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: theme.colors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 18, color: theme.colors.primary),
          ],
        ),
      ),
    );
  }
}
