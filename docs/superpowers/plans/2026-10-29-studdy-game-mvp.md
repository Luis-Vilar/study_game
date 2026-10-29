# Studdy Game MVP — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir la demo Flutter de Studdy Game: home con drawer, duelos jugables contra rivales simulados y práctica solo, todo re-tematizado por packs de tema (Futebol / Música / Games) y en portugués.

**Architecture:** Tres capas: `models/` (ThemePack, Student, Question, motor de duelo puro), `data/` (packs JSON en `assets/themes/`, banco de preguntas), `state/` (un único `AppState` que es `ChangeNotifier`, expuesto por un `InheritedNotifier`). Las pantallas solo leen estado y navegan con `Navigator`.

**Tech Stack:** Flutter 3.47.6 / Dart 3.13.5, Material 3, `dart:convert`, `ChangeNotifier`. Sin paquetes externos.

**Spec:** `docs/superpowers/specs/2026-10-29-studdy-game-mvp-design.md`

## Global Constraints

- Solo Android, orientación retrato.
- Toda la UI en **pt-BR**.
- Cero dependencias nuevas en `pubspec.yaml` (nada de `google_fonts`, `shared_preferences`, `provider`, `go_router`, `freezed`).
- Sin imágenes ni `.ttf` externos: emojis y fuentes del sistema (`sans` por defecto, `mono` = `monospace`).
- Estado en memoria; reiniciar la app vuelve al inicio (herói con 320 pts, sequência 4, tema Futebol).
- Todo el texto visible proviene del `ThemePack` (títulos, palabras, mensajes), excepto las preguntas base y los nombres de personas.
- Números de los enunciados siempre en dígitos (`3`, no `três`).
- Design tokens exactos del pack Futebol: fondo `#F4FBF0`, superficie `#FFFFFF`, primaria `#0B6E3A`, acento `#C6F432`, texto `#10261A`.
- Commits frecuentes, uno por tarea.

## Review Focus

- **Timer zerado:** si el contador llega a 0, la pregunta debe cerrarse como incorrecta y avanzar sola; nunca quedarse trabada ni sumar puntos.
- **Timer vivo al salir:** abandonar el duelo con el botón atrás no debe dejar un `Timer` corriendo ni disparar `setState` después de `dispose`.
- **Texto largo en pt:** nombres como "Revolução Francesa" u opciones como "Produzir energia" deben entrar en la lista y en los botones sin desbordar (máx. 2 líneas + ellipsis).
- **Cambio de tema en caliente:** cambiar de tema en el drawer no debe resetear puntos, sequência ni la pantalla actual.
- **Prompt faltante:** si un pack no trae enunciado para una pregunta, se usa el `basePrompt` de la pregunta; nunca una cadena vacía.

---

## File Structure

```
lib/
  main.dart
  app.dart
  theme/app_theme.dart
  models/theme_pack.dart
  models/student.dart
  models/question.dart
  models/duel_engine.dart
  data/theme_packs.dart
  data/questions.dart
  data/mock_students.dart
  state/app_state.dart
  state/app_scope.dart
  screens/home_screen.dart
  screens/duel_screen.dart
  screens/result_screen.dart
  screens/practice_screen.dart
  widgets/hero_drawer.dart
  widgets/classmate_tile.dart
  widgets/challenge_sheet.dart
  widgets/points_bar.dart
assets/themes/futebol.json
assets/themes/musica.json
assets/themes/games.json
test/theme_pack_test.dart
test/questions_test.dart
test/app_state_test.dart
test/duel_engine_test.dart
test/home_test.dart
```

---

### Task 1: Modelo ThemePack + pack Futebol + loader

**Files:**
- Create: `lib/models/theme_pack.dart`
- Create: `assets/themes/futebol.json`
- Create: `lib/data/theme_packs.dart`
- Modify: `pubspec.yaml` (sección `flutter:`)
- Create: `test/theme_pack_test.dart`
- Modify: `.gitignore` (agregar `.superpowers/`)

**Interfaces:**
- Consumes: nada.
- Produces: `ThemeColors`, `ThemePack.fromJson(Map<String, dynamic>)`, `ThemePack.word(String) → String`, `ThemePack.text(String) → String`, `ThemePack.promptFor(String id, String fallback) → String`, `bool get isDark`; `Future<Map<String, ThemePack>> loadThemePacks(AssetBundle bundle)`; `const kThemeIds`.

- [ ] **Step 1: Inicializar git**

```bash
git init
printf '\n.superpowers/\n' >> .gitignore
git add -A && git commit -m "chore: init flutter scaffold"
```

- [ ] **Step 2: Escribir el test que falla**

`test/theme_pack_test.dart`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studdy_game/models/theme_pack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('futebol.json vira ThemePack completo', () async {
    final raw = await rootBundle.loadString('assets/themes/futebol.json');
    final pack = ThemePack.fromJson(jsonDecodeMap(raw));

    expect(pack.id, 'futebol');
    expect(pack.appTitle, 'Studdy FC');
    expect(pack.colors.primary, const Color(0xFF0B6E3A));
    expect(pack.word('challenge'), 'RETAR');
    expect(pack.text('duelWin'), isNotEmpty);
    expect(pack.isDark, isFalse);
  });

  test('promptFor cai no fallback quando o pack não tem o enunciado', () {
    final pack = ThemePack.fromJson({
      'id': 'x', 'name': 'X', 'appTitle': 'X', 'tagline': '',
      'fontFamily': 'sans', 'uppercaseLabels': false, 'radius': 12.0,
      'colors': {
        'bg': '#FFFFFF', 'surface': '#FFFFFF', 'surfaceAlt': '#EEEEEE',
        'primary': '#000000', 'accent': '#FF0000',
        'textPrimary': '#111111', 'textSecondary': '#666666',
      },
      'icons': <String, String>{},
      'words': <String, String>{},
      'copy': <String, String>{},
      'prompts': <String, String>{},
    });
    expect(pack.promptFor('m1', 'Quanto é 3 + 2?'), 'Quanto é 3 + 2?');
  });
}
```

`jsonDecodeMap` es un helper local al final del archivo: `Map<String, dynamic> jsonDecodeMap(String s) => jsonDecode(s) as Map<String, dynamic>;` (importar `dart:convert` en el test).

- [ ] **Step 3: Verificar que falla**

Run: `flutter test test/theme_pack_test.dart`
Expected: FAIL — `Error: Couldn't resolve the package 'studdy_game'` o `theme_pack.dart` no existe.

- [ ] **Step 4: Implementar el modelo**

`lib/models/theme_pack.dart` — `ThemeColors` con los 7 colores y un `factory ThemeColors.fromJson` que usa `_hex(String)` (`Color(int.parse(v.substring(1), radix: 16) | 0xFF000000)`). `ThemePack` con campos `id, name, appTitle, tagline, fontFamily, uppercaseLabels, radius, colors, gradient (List<Color>?), icons, words, copy, prompts (todos Map<String,String>)`; `isDark` = `colors.bg.computeLuminance() < 0.4`; `gradient` null si la clave falta; los mapas por defecto vacíos.

- [ ] **Step 5: Crear el pack Futebol**

`assets/themes/futebol.json` con: `id: futebol`, `name: Futebol`, `appTitle: Studdy FC`, `tagline: Aprenda em campo`, `fontFamily: sans`, `uppercaseLabels: true`, `radius: 14`, colores del Global Constraints, `gradient: null`, `icons: {duel: ⚽, practice: 🏃, points: ⚽, streak: 🔥, hero: 🦸, challenge: ⚔️}`, `words: {classmates: RIVAIS, challenge: RETAR, points: PONTOS, streak: PARTIDAS, practice: TREINAR, level: NÍVEL, subject: MATÉRIA}`, `copy: {duelWin: "Você venceu o duelo!", duelLose: "Perdeu por pouco. Tenta de novo?", duelTie: "Empate! Ninguém cedeu.", practiceCorrect: "Boa! Mais uma?", practiceWrong: "Quase. Vamos revisar?", practiceDone: "Treino concluído!", drawerTitle: "Seu herói", resultTitle: "Fim do duelo"}`, `prompts: {}` (se completan en la tarea 3).

- [ ] **Step 6: Habilitar assets y escribir el loader**

`pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/themes/
```

`lib/data/theme_packs.dart`: `const List<String> kThemeIds = ['futebol', 'musica', 'games'];` y `Future<Map<String, ThemePack>> loadThemePacks(AssetBundle bundle)` que hace `bundle.loadString('assets/themes/$id.json')`, `jsonDecode` y `ThemePack.fromJson`, devolviendo un mapa por id.

- [ ] **Step 7: Verificar que pasa**

Run: `flutter test test/theme_pack_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 8: Commit**

```bash
git add pubspec.yaml lib/models/theme_pack.dart lib/data/theme_packs.dart assets/themes/futebol.json test/theme_pack_test.dart .gitignore
git commit -m "feat: theme pack model and futebol pack"
```

---

### Task 2: Packs Música y Games

**Files:**
- Create: `assets/themes/musica.json`
- Create: `assets/themes/games.json`
- Modify: `test/theme_pack_test.dart`

**Interfaces:**
- Consumes: `loadThemePacks`, `ThemePack`.
- Produces: los tres packs disponibles por id; `musica.colors.bg` es oscuro (`isDark == true`).

- [ ] **Step 1: Escribir el test que falla**

Agregar a `test/theme_pack_test.dart`:

```dart
test('os três packs carregam dos assets', () async {
  final packs = await loadThemePacks(rootBundle);
  expect(packs.keys, containsAll(['futebol', 'musica', 'games']));
  expect(packs['musica']!.isDark, isTrue);
  expect(packs['games']!.fontFamily, 'mono');
  expect(packs['games']!.appTitle, 'STUDDY.EXE');
});
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/theme_pack_test.dart`
Expected: FAIL — no existe `assets/themes/musica.json` / `games.json`.

- [ ] **Step 3: Crear los dos packs**

`musica.json`: `appTitle: Studdy FM`, `tagline: Aprenda no ritmo`, `fontFamily: sans`, `uppercaseLabels: false`, `radius: 20`, colores `bg #170F2B`, `surface #2B1B4D`, `surfaceAlt #3A2A63`, `primary #8F5BFF`, `accent #FF4FD8`, `textPrimary #F2ECFF`, `textSecondary #9D8FC4`; `gradient: [#2B1B4D, #170F2B]`; iconos `duel: 🎧, practice: 🎹, points: 🎵, streak: 🔥, hero: 🦸, challenge: ⚡`; `words: {classmates: PLAYLIST, challenge: DESAFIAR, points: PONTOS, streak: FAIXAS, practice: ENSAIAR, level: NÍVEL, subject: MATÉRIA}`; `copy` equivalente con `practiceDone: "Show concluído!"`, `resultTitle: "Fim da apresentação"`.

`games.json`: `appTitle: STUDDY.EXE`, `tagline: Suba de nível estudando`, `fontFamily: mono`, `uppercaseLabels: true`, `radius: 8`, colores `bg #0F1117`, `surface #151A25`, `surfaceAlt #1F2A3A`, `primary #00E5A0`, `accent #4FE3FF`, `textPrimary #D7FFEF`, `textSecondary #57708A`; `gradient: null`; iconos `duel: 🎮, practice: 👾, points: ✨, streak: 🔥, hero: 🕹️, challenge: ⚔️`; `words: {classmates: JOGADORES, challenge: RETAR, points: XP, streak: COMBO, practice: TREINAR, level: NÍVEL, subject: MATÉRIA}`; `copy` con `practiceDone: "Fase concluída!"`, `resultTitle: "Fim da partida"`.

Los tres `prompts` quedan `{}` hasta la tarea 3.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/theme_pack_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add assets/themes test/theme_pack_test.dart
git commit -m "feat: musica and games theme packs"
```

---

### Task 3: Banco de preguntas + enunciados temáticos

**Files:**
- Create: `lib/models/question.dart`
- Create: `lib/data/questions.dart`
- Create: `test/questions_test.dart`
- Modify: `assets/themes/{futebol,musica,games}.json` (campo `prompts`)

**Interfaces:**
- Consumes: `ThemePack`.
- Produces: `enum Subject { matematica, historia, ciencias }`, `Subject.label` (`Matemática`, `História`, `Ciências`), `class Question { String id; Subject subject; int difficulty; String basePrompt; List<String> options; String answer; String promptFor(ThemePack pack); }`, `const List<Question> kQuestions` (18), `List<Question> questionsFor(Subject subject)`.

- [ ] **Step 1: Escribir el test que falla**

`test/questions_test.dart`:

```dart
void main() {
  test('todo pack tem enunciado para as 18 perguntas', () async {
    final packs = await loadThemePacks(rootBundle);
    for (final pack in packs.values) {
      for (final q in kQuestions) {
        expect(pack.promptFor(q.id, ''), isNotEmpty,
            reason: '${pack.id} sem enunciado para ${q.id}');
      }
    }
  });

  test('os números do enunciado base aparecem em todos os temas', () async {
    final packs = await loadThemePacks(rootBundle);
    for (final q in kQuestions) {
      final numbers = RegExp(r'\d+').allMatches(q.basePrompt).map((m) => m[0]!);
      for (final pack in packs.values) {
        for (final n in numbers) {
          expect(pack.prompts[q.id], contains(n),
              reason: '${q.id} em ${pack.id} perdeu o número $n');
        }
      }
    }
  });

  test('cada matéria tem 6 perguntas com 4 opções e resposta entre elas', () {
    for (final s in Subject.values) {
      final qs = questionsFor(s);
      expect(qs.length, 6);
      for (final q in qs) {
        expect(q.options.length, 4);
        expect(q.options, contains(q.answer));
      }
    }
  });
}
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/questions_test.dart`
Expected: FAIL — `question.dart` no existe.

- [ ] **Step 3: Implementar el modelo y el banco base**

`lib/models/question.dart` con el enum, la extensión `SubjectX` y `Question` (`promptFor` delega en `pack.promptFor(id, basePrompt)`).

`lib/data/questions.dart` con estas 18 preguntas (id, materia, dificultad 1-3, enunciado base, opciones, respuesta):

| id | mat | dif | basePrompt | opciones | respuesta |
|---|---|---|---|---|---|
| m1 | mate | 1 | Quanto é 3 + 2? | 4, 5, 6, 7 | 5 |
| m2 | mate | 1 | Quanto é 14 - 6? | 6, 7, 8, 9 | 8 |
| m3 | mate | 2 | Quanto é 7 × 6? | 36, 40, 42, 48 | 42 |
| m4 | mate | 2 | Quanto é 48 ÷ 6? | 6, 7, 8, 9 | 8 |
| m5 | mate | 3 | Quanto é 3/4 de 20? | 10, 12, 15, 18 | 15 |
| m6 | mate | 3 | Quanto é 15% de 200? | 15, 25, 30, 45 | 30 |
| h1 | hist | 1 | Em que ano o Brasil proclamou sua independência? | 1500, 1822, 1888, 1988 | 1822 |
| h2 | hist | 1 | Quem foi o primeiro imperador do Brasil? | Dom Pedro I, Dom Pedro II, Getúlio Vargas, Tiradentes | Dom Pedro I |
| h3 | hist | 2 | Qual foi o primeiro produto explorado no Brasil colonial? | Café, Pau-brasil, Cana-de-açúcar, Ouro | Pau-brasil |
| h4 | hist | 2 | O que a Lei Áurea, de 1888, aboliu? | A escravidão, A monarquia, O voto feminino, A censura | A escravidão |
| h5 | hist | 3 | Qual movimento pediu eleições diretas em 1984? | Diretas Já, Tenentismo, Integralismo, Abolicionismo | Diretas Já |
| h6 | hist | 3 | Em que ano começou a ditadura militar no Brasil? | 1930, 1945, 1964, 1985 | 1964 |
| c1 | cien | 1 | Qual é a menor unidade viva dos seres vivos? | Célula, Átomo, Órgão, Tecido | Célula |
| c2 | cien | 1 | Qual gás as plantas absorvem na fotossíntese? | Oxigênio, Gás carbônico, Nitrogênio, Hidrogênio | Gás carbônico |
| c3 | cien | 2 | Qual órgão bombeia o sangue pelo corpo? | Pulmão, Fígado, Coração, Rim | Coração |
| c4 | cien | 2 | Qual é o planeta mais próximo do Sol? | Vênus, Marte, Mercúrio, Terra | Mercúrio |
| c5 | cien | 3 | Qual é a principal função das mitocôndrias? | Produzir energia, Armazenar água, Filtrar o sangue, Transportar oxigênio | Produzir energia |
| c6 | cien | 3 | Qual é a fórmula química da água? | CO₂, H₂O, O₂, NaCl | H₂O |

`questionsFor(Subject s)` devuelve `kQuestions.where((q) => q.subject == s).toList()`.

- [ ] **Step 4: Escribir los 18 enunciados por tema (54 textos)**

Regla: mismo número, misma respuesta, misma dificultad; cambia la historia. Matemática reescribe la situación; Historia y Ciencias conservan el contenido factual y cambian solo la frase de encuadre. Todos los números en dígitos.

Ejemplos que fijan el tono (Futebol / Música / Games):

- `m1` — "O time marcou 3 gols no primeiro tempo e 2 no segundo. Quantos gols no total?" / "A banda tocou 3 músicas no primeiro show e 2 no segundo. Quantas no total?" / "Você coletou 3 moedas na fase 1 e 2 na fase 2. Quantas ao todo?"
- `m3` — "Foram 7 partidas com 6 gols cada. Quantos gols no campeonato?" / "Foram 7 shows com 6 faixas cada. Quantas faixas no total?" / "Foram 7 fases com 6 moedas cada. Quantas moedas?"
- `h1` — "No vestiário, o técnico perguntou: em que ano o Brasil proclamou sua independência?" / "Na rádio, o locutor perguntou: em que ano...?" / "No tutorial, o NPC perguntou: em que ano...?"
- `c1` — "O médico do time explicou qual é a menor unidade viva dos seres vivos. Qual é?" / "Na letra da música, qual é a menor unidade viva...?" / "No loading screen: qual é a menor unidade viva...?"

- [ ] **Step 5: Completar `prompts` en los tres JSON**

Cada JSON debe tener las 18 claves (`m1`…`c6`) con su texto.

- [ ] **Step 6: Verificar que pasa**

Run: `flutter test test/questions_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 7: Commit**

```bash
git add lib/models/question.dart lib/data/questions.dart test/questions_test.dart assets/themes
git commit -m "feat: question bank with per-theme prompts"
```

---

### Task 4: AppState, AppScope y tema visual

**Files:**
- Create: `lib/models/student.dart`
- Create: `lib/data/mock_students.dart`
- Create: `lib/state/app_state.dart`
- Create: `lib/state/app_scope.dart`
- Create: `lib/theme/app_theme.dart`
- Create: `test/app_state_test.dart`

**Interfaces:**
- Consumes: `ThemePack`, `Subject`.
- Produces: `Student` (`id, name, emoji, Color color, Subject favoriteSubject, int points, int level, int streak`) con `copyWith`; `AppState` (`packages`, `theme`, `themeId`, `hero`, `classmates`, `selectTheme(String)`, `updateHero({String? name, String? emoji, Color? color})`, `addPoints(int)`, `bumpStreak()`, `int get heroLevel`, `int get rank`); `AppScope` con `static AppState of(BuildContext)`; `ThemeData buildAppTheme(ThemePack)`.

- [ ] **Step 1: Escribir el test que falla**

`test/app_state_test.dart`:

```dart
void main() {
  late AppState state;
  setUp(() {
    state = AppState(
      packs: {'futebol': _pack('futebol', 0xFFF4FBF0), 'games': _pack('games', 0xFF0F1117)},
      initialThemeId: 'futebol',
    );
  });

  test('herói começa com 320 pontos, nível 2 e sequência 4', () {
    expect(state.hero.points, 320);
    expect(state.heroLevel, 2);
    expect(state.hero.streak, 4);
  });

  test('trocar de tema notifica e mantém pontos', () {
    var notified = 0;
    state.addListener(() => notified++);
    state.addPoints(100);
    state.selectTheme('games');
    expect(state.themeId, 'games');
    expect(state.hero.points, 420);
    expect(notified, 2);
  });

  test('edições do herói persistem na sessão', () {
    state.updateHero(name: 'Bia', emoji: '🦊', color: const Color(0xFF00AAFF));
    expect(state.hero.name, 'Bia');
    expect(state.hero.emoji, '🦊');
  });

  test('sequência sobe uma vez por atividade concluída', () {
    state.bumpStreak();
    expect(state.hero.streak, 5);
  });

  test('rank conta quantos colegas têm mais pontos', () {
    expect(state.rank, greaterThan(1));
  });
}
```

Helper `_pack(id, bg)` al final: construye un `ThemePack.fromJson` mínimo con `bg` dado.

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/app_state_test.dart`
Expected: FAIL — `app_state.dart` no existe.

- [ ] **Step 3: Implementar Student, mock y AppState**

`mock_students.dart`: herói `h0` "Você" 🦸 320 pts sequência 4 + seis colegas con puntos entre 1.240 y 2.010, niveles 8-15, emoji y color propios (Ana Ruiz, Diego Paz, Luz Mora, Iker Sosa, Nina Alves, Theo Lima). El herói se crea con `heroPoints: 320` y es fácil de reiniciar.

`AppState` guarda `hero` como `Student` y lo reemplaza con `copyWith`; `addPoints` suma a `hero.points`; `bumpStreak` suma a `hero.streak`; `selectTheme` valida que el id exista antes de cambiar; `rank = classmates.where((c) => c.points > hero.points).length + 1`; `heroLevel = hero.points ~/ 250 + 1`.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/app_state_test.dart`
Expected: PASS (5 tests).

- [ ] **Step 5: Implementar tema y scope**

`buildAppTheme(pack)`: `ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: pack.colors.primary, brightness: pack.isDark ? Brightness.dark : Brightness.light).copyWith(primary: pack.colors.primary, secondary: pack.colors.accent, surface: pack.colors.surface, onSurface: pack.colors.textPrimary), scaffoldBackgroundColor: pack.gradient != null ? Colors.transparent : pack.colors.bg, fontFamily: pack.fontFamily == 'mono' ? 'monospace' : null, appBarTheme: ..., textButtonTheme: ...)`.

`AppScope extends InheritedNotifier<AppState>` con `static AppState of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;`.

- [ ] **Step 6: Commit**

```bash
git add lib/models/student.dart lib/data/mock_students.dart lib/state lib/theme test/app_state_test.dart
git commit -m "feat: app state, hero and theme derivation"
```

---

### Task 5: App + Home con abas y barra de puntos

**Files:**
- Modify: `lib/main.dart`
- Create: `lib/app.dart`
- Create: `lib/screens/home_screen.dart`
- Create: `lib/widgets/points_bar.dart`
- Create: `test/home_test.dart`

**Interfaces:**
- Consumes: `loadThemePacks`, `AppState`, `AppScope`, `buildAppTheme`.
- Produces: `StuddyApp({required Map<String, ThemePack> packs, String initialThemeId = 'futebol'})`; `HomeScreen` con `DefaultTabController(length: 2)` y pestañas `Duelos` / `Praticar`; `PointsBar` que muestra `theme.word('points')`, `hero.points`, `heroLevel` y `theme.word('streak')`.

- [ ] **Step 1: Escribir el test que falla**

`test/home_test.dart`:

```dart
testWidgets('home mostra abas, pontos e o título do tema', (tester) async {
  final packs = await loadThemePacks(rootBundle);
  await tester.pumpWidget(StuddyApp(packs: packs));
  await tester.pumpAndSettle();

  expect(find.text('Studdy FC'), findsOneWidget);
  expect(find.text('Duelos'), findsOneWidget);
  expect(find.text('Praticar'), findsOneWidget);
  expect(find.text('320'), findsWidgets);
});
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/home_test.dart`
Expected: FAIL — `StuddyApp` no existe.

- [ ] **Step 3: Implementar app, home y barra**

`main.dart`: `WidgetsFlutterBinding.ensureInitialized()`, `loadThemePacks(rootBundle)`, `runApp(StuddyApp(packs: packs))`.

`app.dart`: `StatefulWidget` que crea el `AppState` una vez, lo envuelve en `AppScope` y reconstruye `MaterialApp` con `ListenableBuilder` cuando cambia el tema. `home: const HomeScreen()`, `debugShowCheckedModeBanner: false`.

`home_screen.dart`: `Scaffold(drawer: const HeroDrawer(), appBar: AppBar(title: Text(theme.appTitle), leading: avatar que abre el drawer, actions: [PointsBar()]), body: Column[TabBar(tabs Duelos/Praticar), Expanded(TabBarView[lista de colegas, PracticeScreen()])])`. La lista de colegas se implementa en la tarea 6; aquí puede ser un `ListView` con `ClassmateTile` de la tarea 6 — si esa tarea aún no existe, usar un placeholder `Center(Text(theme.word('classmates')))` y reemplazarlo en la tarea 6.

Contenedor raíz con `gradient` cuando `theme.gradient != null` (usar `DecoratedBox` detrás del `Scaffold` con `backgroundColor: Colors.transparent`).

`points_bar.dart`: chips con puntos, nivel y sequência, usando `theme.word(...)` y `theme.icons[...]`.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/home_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart lib/app.dart lib/screens/home_screen.dart lib/widgets/points_bar.dart test/home_test.dart
git commit -m "feat: app shell and home with tabs"
```

---

### Task 6: Drawer del herói + cambio de tema + lista de colegas

**Files:**
- Create: `lib/widgets/hero_drawer.dart`
- Create: `lib/widgets/classmate_tile.dart`
- Modify: `lib/screens/home_screen.dart`
- Modify: `test/home_test.dart`

**Interfaces:**
- Consumes: `AppScope.of`, `AppState.updateHero`, `AppState.selectTheme`, `ThemePack`.
- Produces: `HeroDrawer` (edit nombre con `TextField`, 8 emojis, 6 colores, 3 botones de tema) y `ClassmateTile({required Student student, required VoidCallback onChallenge})`.

- [ ] **Step 1: Escribir el test que falla**

Agregar a `test/home_test.dart`:

```dart
testWidgets('trocar para Games muda o título do app sem perder pontos', (tester) async {
  final packs = await loadThemePacks(rootBundle);
  await tester.pumpWidget(StuddyApp(packs: packs));
  await tester.pumpAndSettle();

  await tester.tap(find.byTooltip('Abrir menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Games'));
  await tester.pumpAndSettle();
  await tester.tapAt(const Offset(700, 400)); // cierra el drawer
  await tester.pumpAndSettle();

  expect(find.text('STUDDY.EXE'), findsOneWidget);
  expect(find.text('320'), findsWidgets);
});
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/home_test.dart`
Expected: FAIL — no hay drawer ni botón "Games".

- [ ] **Step 3: Implementar drawer y tile**

`HeroDrawer`: `Drawer` con cabecera (avatar grande, nombre, nivel, rank), `TextField` de nombre con `onSubmitted`/`onChanged` → `updateHero(name:)`, `Wrap` de 8 emojis y 6 colores, y una fila de 3 `ChoiceChip` con el nombre de cada pack (`Abrir menu` como `tooltip` del botón del AppBar).

`ClassmateTile`: `Card`/`ListTile` con avatar circular, nombre, `subject.label` + puntos, y `FilledButton` con `theme.word('challenge')`. Nombre y materia con `maxLines: 1, overflow: TextOverflow.ellipsis`; el botón con `padding` compacto.

En `home_screen.dart`, reemplazar el placeholder por `ListView.separated` de `state.classmates` ordenados por puntos.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/home_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/widgets lib/screens/home_screen.dart test/home_test.dart
git commit -m "feat: hero drawer, theme switch and classmate list"
```

---

### Task 7: Motor de duelo

**Files:**
- Create: `lib/models/duel_engine.dart`
- Create: `test/duel_engine_test.dart`

**Interfaces:**
- Consumes: `Question`.
- Produces: `const kQuestionsPerDuel = 5`, `const kSecondsPerQuestion = 15`, `int pointsForAnswer({required bool correct, required int elapsedMs})`, `int opponentScore(Random)`, `class DuelEngine` (`DuelEngine({required List<Question> questions, required int opponentScore})`, `Question get current`, `bool get finished`, `bool answer(String option, int elapsedMs)`, `DuelResult get result`), `class DuelResult { int score, opponentScore, correct, total; bool get won; bool get tied; }`.

- [ ] **Step 1: Escribir el test que falla**

```dart
test('acerto rápido vale 120 e acerto lento 100', () {
  expect(pointsForAnswer(correct: true, elapsedMs: 4999), 120);
  expect(pointsForAnswer(correct: true, elapsedMs: 5001), 100);
  expect(pointsForAnswer(correct: false, elapsedMs: 1000), 0);
});

test('tempo esgotado fecha a pergunta como errada', () {
  final engine = DuelEngine(questions: _five(), opponentScore: 300);
  expect(engine.answer('', 15000), isFalse);
  expect(engine.correct, 0);
  expect(engine.index, 1);
});

test('placar do oponente fica entre 180 e 600', () {
  final r = Random(7);
  for (var i = 0; i < 200; i++) {
    final s = opponentScore(r);
    expect(s, inInclusiveRange(180, 600));
  }
});

test('responder as 5 encerra o duelo e calcula o resultado', () {
  final engine = DuelEngine(questions: _five(), opponentScore: 400);
  for (var i = 0; i < 5; i++) {
    engine.answer(engine.current.answer, 6000);
  }
  expect(engine.finished, isTrue);
  expect(engine.result.correct, 5);
  expect(engine.result.score, 500);
  expect(engine.result.won, isTrue);
});
```

`_five()` devuelve cinco `Question` de prueba con respuesta `'5'`.

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/duel_engine_test.dart`
Expected: FAIL — `duel_engine.dart` no existe.

- [ ] **Step 3: Implementar el motor**

`pointsForAnswer`: `correct ? (elapsedMs <= 5000 ? 120 : 100) : 0`. `opponentScore`: `180 + r.nextInt(421)`. `answer` suma puntos, incrementa `correct` si acertó y avanza `index`; devuelve `wasCorrect`. `result` devuelve `DuelResult(score, opponentScore, correct, questions.length)`. `won` = `score > opponentScore`; `tied` = iguales.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/duel_engine_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/models/duel_engine.dart test/duel_engine_test.dart
git commit -m "feat: duel engine and scoring"
```

---

### Task 8: Pantallas de duelo y resultado

**Files:**
- Create: `lib/screens/duel_screen.dart`
- Create: `lib/screens/result_screen.dart`
- Create: `lib/widgets/challenge_sheet.dart`
- Modify: `lib/screens/home_screen.dart` (conectar el botón de desafío)
- Modify: `test/home_test.dart`

**Interfaces:**
- Consumes: `DuelEngine`, `opponentScore`, `AppScope.of`, `AppState.addPoints`, `AppState.bumpStreak`, `Question.promptFor`.
- Produces: `ChallengeSheet.show(BuildContext, Student)` que devuelve `Future<Subject?>`; `DuelScreen({required Student rival, required Subject subject})`; `ResultScreen({required DuelResult result, required Student rival})`.

- [ ] **Step 1: Escribir el test que falla**

```dart
testWidgets('desafiar abre a folha com as três matérias', (tester) async {
  final packs = await loadThemePacks(rootBundle);
  await tester.pumpWidget(StuddyApp(packs: packs));
  await tester.pumpAndSettle();

  await tester.tap(find.text('RETAR').first);
  await tester.pumpAndSettle();

  expect(find.text('Matemática'), findsOneWidget);
  expect(find.text('História'), findsOneWidget);
  expect(find.text('Ciências'), findsOneWidget);
});
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/home_test.dart`
Expected: FAIL — no existe la hoja de desafío.

- [ ] **Step 3: Implementar la hoja de desafío**

`ChallengeSheet.show`: `showModalBottomSheet<Subject>` con el nombre del rival, las tres materias como botones grandes y un texto "Rival desafiado! Escolha a matéria". Cada materia devuelve `Navigator.pop(subject)`.

- [ ] **Step 4: Implementar el duelo**

`DuelScreen` es `StatefulWidget`: crea `DuelEngine` con 5 preguntas de la materia (`questionsFor(subject).take(kQuestionsPerDuel)`), `opponentScore(Random())` y un `Timer.periodic(Duration(seconds: 1))` que descuenta de 15. `dispose` cancela el timer y el timer también se cancela al terminar. Cada respuesta: `elapsedMs = (15 - secondsLeft) * 1000`, llama `engine.answer(option, elapsedMs)`, muestra feedback 600 ms con `SnackBar` o color en la opción y avanza; si `finished`, cancela el timer, `state.addPoints(result.score)`, `state.bumpStreak()` y `Navigator.pushReplacement` a `ResultScreen`. Al llegar a 0 sin respuesta: `engine.answer('', 15000)`.

UI: `AppBar` con nombre del rival y `LinearProgressIndicator` de tiempo, texto de progreso "Pergunta 1 de 5", el `promptFor(pack)`, y 4 opciones `OutlinedButton`/`FilledButton` de ancho completo. Bloquear doble tap con un flag `_answering`.

`ResultScreen`: placar grande `420 — 380`, nombre del rival, acertos `4/5`, puntos ganados, mensaje `theme.text(won ? 'duelWin' : tied ? 'duelTie' : 'duelLose')` y botón "Voltar aos duelos" que hace `Navigator.pop`.

- [ ] **Step 5: Verificar que pasa**

Run: `flutter test test/home_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/screens lib/widgets/challenge_sheet.dart lib/screens/home_screen.dart test/home_test.dart
git commit -m "feat: duel flow and result screen"
```

---

### Task 9: Práctica solo

**Files:**
- Create: `lib/screens/practice_screen.dart`
- Modify: `lib/screens/home_screen.dart` (usar la pestaña real)
- Modify: `test/home_test.dart`

**Interfaces:**
- Consumes: `questionsFor`, `ThemePack.promptFor`, `AppState.addPoints`, `AppState.bumpStreak`.
- Produces: `PracticeScreen` (estado interno: índice, aciertos, puntos).

- [ ] **Step 1: Escribir el test que falla**

```dart
testWidgets('praticar mostra o botão de começar', (tester) async {
  final packs = await loadThemePacks(rootBundle);
  await tester.pumpWidget(StuddyApp(packs: packs));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Praticar'));
  await tester.pumpAndSettle();

  expect(find.textContaining('TREINAR'), findsWidgets);
});
```

- [ ] **Step 2: Verificar que falla**

Run: `flutter test test/home_test.dart`
Expected: FAIL — la pestaña muestra el placeholder.

- [ ] **Step 3: Implementar la práctica**

`PracticeScreen`: estado inicial con tarjeta de inicio (icono `practice`, título del pack, "5 perguntas sem pressa"), botón que arranca el quiz. Durante el quiz: enunciado `promptFor`, 4 opciones, feedback de 600 ms, +50 por acierto (`practicePoints`), sin timer. Al terminar: aciertos, puntos, mensaje `practiceDone` y "Jogar de novo" que resetea el estado. Sumar puntos y `bumpStreak()` una sola vez al terminar.

- [ ] **Step 4: Verificar que pasa**

Run: `flutter test test/home_test.dart`
Expected: PASS (4 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/screens/practice_screen.dart lib/screens/home_screen.dart test/home_test.dart
git commit -m "feat: solo practice tab"
```

---

### Task 10: README y verificación final

**Files:**
- Create: `README.md` (reemplaza el actual)
- Modify: `.gitignore` si hace falta

**Interfaces:**
- Consumes: todo.
- Produces: documento de presentación en portugués.

- [ ] **Step 1: Escribir el README en portugués**

Secciones, en este orden:

1. **Studdy Game** — qué es, en dos frases.
2. **O problema** — estudio postergado, retorno lejano, material genérico, soledad.
3. **A proposta** — recompensa inmediata + pressão social + identidade; el argumento de que personalizar la historia no cambia la ecuación.
4. **Os três temas** — Futebol / Música / Games, con qué cambia en cada uno (cor, vocabulário, enunciado).
5. **Como funciona** — duelos (5 perguntas, 15 s, 100+20, rival simulado), prática solo (+50), herói, sequência, ranking.
6. **Como rodar** — `flutter pub get`, `flutter run` con un dispositivo Android; aclarar que el estado no persiste.
7. **Arquitetura** — packs de tema como JSON, `AppState`, motor puro; "adicionar um tema é adicionar um arquivo".
8. **O que o time pedagógico destrava** — revisão e progressão curricular, banco de itens validado, métricas de aprendizagem, adequação por faixa etária, acessibilidade, e como medir se a personalização realmente melhora o desempenho.

- [ ] **Step 2: Verificar todo el proyecto**

```bash
flutter analyze
flutter test
flutter build apk --debug
```
Expected: sin issues, todos los tests en verde, APK generado en `build/app/outputs/flutter-apk/app-debug.apk`.

- [ ] **Step 3: Commit final**

```bash
git add README.md
git commit -m "docs: README with problem, proposal and pedagogical roadmap"
```

---

## Self-Review

- Cobertura del spec: home+abas (5), drawer/herói/tema (6), lista+desafío (6, 8), duelo (7, 8), resultado (8), prática (9), temas (1-3), README (10), pt-BR (transversal), sin dependencias (transversal).
- Contrato de equidad: test en tarea 3 compara números del enunciado base contra los tres packs.
- Fallback de enunciado: tarea 1 lo prueba y tarea 3 garantiza que no se use.
- Timer y doble tap: cubiertos por implementación explícita en tarea 8 y por Review Focus.
- Tipos: `ThemePack.promptFor(id, fallback)` se usa igual en tareas 1 y 3; `DuelResult` definido en 7 y consumido en 8; `AppScope.of` definido en 4 y usado en 5-9.
