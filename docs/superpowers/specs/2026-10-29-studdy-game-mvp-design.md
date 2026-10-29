# Studdy Game — MVP de gamificação educacional

Data: 2026-10-29
Estado: propuesta para aprovação

## Intenção

Uma demo de app Flutter, de uma única sessão e sem backend, que mostre a ideia central: **um estudante de até 20 anos estuda mais porque o conteúdo chega com a cara do que ele gosta**, e porque competir com os colegas gera um motivo para voltar amanhã.

É uma peça de apresentação para um processo seletivo de uma empresa de educação. O que se avalia é a clareza da ideia, não a robustez da engenharia.

## O problema

Estudar é adiável: o retorno é distante, o esforço é solitário e o material é genérico. A gamificação ataca isso por três frentes:

1. **Recompensa imediata** — pontos, XP, sequência de dias.
2. **Pressão social leve** — duelos com colegas, ranking da turma.
3. **Identidade** — o conteúdo fala do universo do estudante (futebol, música, games) sem trair o currículo.

O ponto delicado, e a razão deste design, é o terceiro: personalizar **sem** mudar a dificuldade. Dois alunos com temas diferentes resolvem a mesma equação; muda só a história que a embala.

## Objetivos

- Uma tela principal com AppBar + drawer, duas abas (Duelos e Praticar).
- Drawer para editar o herói (nome, avatar, cor) e trocar o tema na hora.
- Lista de colegas com desafio por matéria.
- Duelo jogável: 5 perguntas, 15 s cada, resultado contra um oponente simulado.
- Prática solo que gera pontos.
- Três temas completos: Futebol, Música, Games.
- Toda a interface em **português (pt-BR)**.
- README explicando o problema, a proposta e a evolução com o time pedagógico.

## Não objetivos

- Backend, contas, sincronização entre dispositivos.
- Duelo realmente assíncrono entre dois celulares.
- Catálogo extenso de perguntas, editor de conteúdo, painel do professor.
- Acessibilidade completa, internacionalização além do pt-BR, testes de integração.

## Anti-objetivos

Falha se: a personalização mudar a resposta correta ou a dificuldade; o tema for só troca de cor sem mudar a linguagem; a demo depender de internet; o app travar no palco.

## Restrições

- Flutter/Dart já instalados; projeto vazio.
- Sem pacotes externos: só `dart:convert` e `ChangeNotifier`. Nada de `google_fonts` (exige rede) nem `shared_preferences`.
- Estado em memória: reiniciar o app volta ao estado inicial. Decisão consciente para manter zero dependências.
- Sem imagens externas: ícones por emoji e cores/gradientes.

## Enfoques considerados

1. **Tudo hardcoded** — três temas como classes Dart, `setState`. Mais rápido, mas adicionar um tema exige mexer em vários arquivos e a história de "personalização escalável" se perde.
2. **Packs de tema como dados (escolhido)** — cada tema é um JSON em `assets/themes/` com paleta, tipografia, vocabulário e gabaritos de enunciado. A app lê o pack e monta tudo. Adicionar "anime" é adicionar um arquivo.
3. **Arquitetura de produção** — Riverpod, go_router, freezed, repositórios. Peso e dependências que o público não vê.

Escolhido o **2** por contar a história do produto diretamente na arquitetura, sem custo de dependências.

## Arquitetura

```
lib/
  main.dart                  # runApp + AppState
  app.dart                   # MaterialApp, ThemeData derivado do pack
  models/
    theme_pack.dart          # ThemePack: cores, tipografia, textos, ícones
    student.dart             # herói e colegas
    question.dart            # pergunta com prompts por tema
    duel.dart                # DuelState, DuelResult
  data/
    theme_packs.dart         # carrega assets/themes/*.json -> Map<String, ThemePack>
    mock_students.dart       # herói + 6 colegas
    questions.dart           # banco base de perguntas (sem enunciados)
  state/
    app_state.dart           # ChangeNotifier: herói, tema, pontos, streak, histórico
  screens/
    home_screen.dart         # scaffold, AppBar, abas, lista
    practice_screen.dart     # quiz solo
    duel_screen.dart         # quiz do duelo com timer
    result_screen.dart       # placar final
  widgets/
    hero_drawer.dart
    classmate_tile.dart
    challenge_sheet.dart
    points_bar.dart
assets/themes/{futebol,musica,games}.json
```

Navegação: `Navigator` puro. Duelo e resultado entram em tela cheia, sem a barra de abas.

## Modelo de dados

`ThemePack`
```dart
{ id, name, appTitle, tagline,        // "Studdy FC", "Studdy FM", "STUDDY.EXE"
  colors: {bg, surface, surfaceAlt, primary, accent, textPrimary, textSecondary},
  gradient: [..] | null,              // usado no tema Música
  fontFamily: "sans" | "mono",
  uppercaseLabels: bool,
  radius: double,
  icons: {duel, practice, points, streak, hero, challenge},
  words: {classmates, challenge, points, streak, practice, level, subject},
  copy: {duelWin, duelLose, duelTie, practiceCorrect, practiceWrong,
         practiceDone, drawerTitle, resultTitle},   // todo o texto do tema
  prompts: {questionId: "enunciado na linguagem do tema"}
}
```

`Question` (banco base, sem enunciado)
```dart
{ id, subject, difficulty, answer, options[4] }
```

O enunciado vive **no pack do tema**, ligado pelo `id`. Os três packs usam **os mesmos números e a mesma resposta** para cada pergunta: é o contrato que garante equidade entre temas. Adicionar um tema é adicionar um JSON com paleta, vocabulário, textos e os enunciados das 18 perguntas base.

`Student` — id, nome, pontos, nível, sequência, emoji, cor, matéria favorita.
`DuelResult` — perguntas, acertos, pontos, tempo, placar do oponente, vencedor.

## Regras de jogo

**Duelo** (Duelos → tocar um colega → escolher matéria)
- 5 perguntas, 15 s cada, sem voltar.
- +100 por acerto, +20 de bônus se responder em menos de 5 s (máximo 600).
- Placar do oponente: `180 + aleatório(0–420)`, sorteado no início e revelado só no final. Não usa o total acumulado do colega: esse total é ranking, não força de duelo. Assim o app vence, empata e perde de forma plausível em qualquer demo.
- Resultado: placar, acertos, pontos ganhos, "Você venceu / Perdeu por pouco / Empatou".
- Pontos do duelo somam ao total do herói; cada duelo concluído soma 1 na sequência.

**Praticar** (aba solo)
- 5 perguntas, sem timer, +50 por acerto.
- Mensagem de reforço e botão "Jogar de novo".
- Cada prática concluída soma 1 na sequência.

**Sequência** — número exibido no AppBar e no drawer. Começa em 4 (herói semeado com 320 pts para a lista não abrir vazia) e sobe 1 por duelo ou prática concluída. O substantivo vem do tema: "dias", "partidas", "faixas".

**Herói (drawer)**
- Editar nome, escolher entre 8 avatares e 6 cores.
- Trocar tema: Futebol, Música, Games — aplica na hora, sem reiniciar.
- Mostrar pontos, nível (`pontos ~/ 250 + 1`) e sequência.

## Temas

| | Futebol | Música | Games |
|---|---|---|---|
| Fundo | `#F4FBF0` | gradiente `#2B1B4D → #170F2B` | `#0F1117` |
| Superfície | `#FFFFFF` | `rgba(255,255,255,.07)` | `#151A25` |
| Primária | `#0B6E3A` | `#8F5BFF` | `#00E5A0` |
| Destaque | `#C6F432` | `#FF4FD8` | `#4FE3FF` |
| Texto | `#10261A` | `#F2ECFF` | `#D7FFEF` |
| Tipografia | sans, labels em caixa alta | sans arredondada | monoespaçada |
| Vocabulário | rivais, partidas, retar | playlist, faixas | jogadores, XP, nível |

Gabarito de enunciado (mesma conta, três histórias):

> **Matemática — soma**
> - Futebol: "O time marcou {a} gols no primeiro tempo e {b} no segundo. Quantos gols no total?"
> - Música: "A banda tocou {a} músicas no primeiro show e {b} no segundo. Quantas no total?"
> - Games: "Você coletou {a} moedas na fase 1 e {b} na fase 2. Quantas ao todo?"

O mesmo vale para subtração, multiplicação, divisão, frações e porcentagem.

**Matérias do MVP:** Matemática (foco), História e Ciências, com 6 perguntas por matéria (2 fáceis, 2 médias, 2 difíceis). Cada uma com os três enunciados.

## Interface

**Home** — AppBar com avatar (abre o drawer), pontos e sequência; abas Duelos / Praticar; lista de colegas com nome, matéria, pontos e botão de desafio; card do herói no topo.

**Drawer** — avatar grande, nome editável, seletor de avatar e cor, seletor de tema com prévia de cor, resumo de progresso.

**Desafio** — bottom sheet com as três matérias e aviso de que o oponente foi desafiado.

**Duelo** — barra de tempo, pergunta, 4 opções, feedback imediato por 600 ms, progresso 1/5.

**Resultado** — placar grande, desglose, pontos ganhos, CTA "Voltar aos duelos".

## README

Em português, com: o problema, para quem é, por que funciona, como rodar no Android, os três temas, as regras, a arquitetura e uma seção final sobre o que o time pedagógico destravaria (revisão de conteúdo, progressão curricular, métricas de aprendizagem, adequação por faixa etária).

## Decisões do construtor

- **pt-BR** (e não pt-PT): mercado maior e o vocabulário dos temas é natural nesse registro.
- Persistência em memória; a demo reinicia limpa.
- Emojis no lugar de ícones vetoriais e de imagens.
- Sem `shared_preferences` para não introduzir dependência.
- **Plataforma:** só Android. A demo acontece num celular físico, em retrato; o layout é desenhado para essa tela e não precisa se adaptar a desktop ou web.
- **Tipografia:** só fontes do sistema (`sans` e `mono`), com peso, caixa alta e espaçamento para diferenciar os temas. Nenhum `.ttf` empacotado.
- **Todo texto visível é do pack**, não só as sete palavras do vocabulário: título do app, cabeçalhos e mensagens de resultado mudam com o tema.
- **Enunciados vivem no pack**, não no banco de perguntas. É o que sustenta a promessa de "um tema novo = um arquivo novo".
- O total de pontos dos colegas é ranking (posição na turma), não a força deles no duelo.
