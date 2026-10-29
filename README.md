# Studdy Game

Um app de estudos gamificado para estudantes de até 20 anos: duelos de perguntas com os colegas e prática solo que rende pontos, com a interface vestindo o universo que o aluno já gosta — futebol, música ou games.

Esta é uma demo funcional, sem backend: todos os dados são fictícios e vivem na memória do app.

## O problema

Estudar é fácil de adiar. O retorno chega longe, o esforço é solitário e o material é genérico: o mesmo enunciado para todo mundo, sem relação com o que o aluno tem na cabeça fora da escola.

Três alavancas conhecidas atacam isso:

1. **Recompensa imediata** — pontos, níveis e sequência de dias dão retorno na hora.
2. **Pressão social leve** — duelar com um colega cria um motivo concreto para voltar amanhã.
3. **Identidade** — o conteúdo fala do universo do estudante sem trair o currículo.

A terceira é a mais delicada, e é o coração deste MVP.

## A proposta

Personalizar **sem** mudar a dificuldade.

Dois alunos com temas diferentes resolvem a mesma equação; muda só a história que a embala:

> **Futebol** — "O time marcou 3 gols no primeiro tempo e 2 no segundo. Quantos gols no total?"
> **Música** — "A banda tocou 3 músicas no primeiro show e 2 no segundo. Quantas no total?"
> **Games** — "Você coletou 3 moedas na fase 1 e 2 na fase 2. Quantas ao todo?"

Os números, as opções e a resposta correta são idênticos. Isso mantém a comparação entre alunos justa — condição para que a personalização seja defendida como ferramenta pedagógica, e não como um jogo diferente para cada um.

## Os três temas

| | Futebol | Música | Games |
|---|---|---|---|
| Nome no app | Studdy FC | Studdy FM | STUDDY.EXE |
| Paleta | verde de campo + lima | violeta + rosa neon | quase preto + verde |
| Tipografia | sans, rótulos em caixa alta | sans, arredondada | monoespaçada |
| Vocabulário | rivais, partidas, retar | playlist, faixas, ensaiar | jogadores, XP, combo |
| Tom dos textos | técnico e direto | palco e show | arcade e nível |

O tema troca a pele, o vocabulário, os textos de resultado **e** os enunciados das perguntas. Tudo isso vive num único arquivo JSON por tema.

## Como funciona

**Duelos** (aba principal)
- A lista mostra os colegas com matéria favorita e pontos.
- Toque em "Retar" e escolha a matéria: Matemática, História ou Ciências.
- São 5 perguntas, 15 segundos cada, +100 por acerto e +20 se responder em menos de 5 segundos.
- O rival é simulado: o placar dele é sorteado entre 180 e 600 e só aparece no fim.
- O resultado mostra placar, acertos e pontos ganhos.

**Praticar** (aba solo)
- 5 perguntas sem cronômetro, +50 por acerto.
- Serve para ganhar pontos sem a pressão do duelo.

**Herói** (drawer, no avatar do canto superior esquerdo)
- Editar nome, escolher entre 8 avatares e 6 cores.
- Trocar o tema na hora, sem reiniciar.
- Ver nível, posição no ranking e sequência.

**Pontuação**
- Nível = pontos ÷ 250 + 1.
- A sequência sobe 1 a cada duelo ou prática concluída.
- O ranking compara o herói com os colegas pelos pontos acumulados.

## Como rodar

```bash
flutter pub get
flutter run
```

Requer um dispositivo ou emulador Android. O app é retrato e não tem backend: fechar e abrir reinicia tudo (herói com 320 pontos, sequência 4, tema Futebol).

Testes:

```bash
flutter test
```

## Arquitetura

```
lib/
  models/      theme_pack, student, question, duel_engine (puro, sem widgets)
  data/        packs carregados dos assets, banco de 18 perguntas, elenco fictício
  state/       AppState (ChangeNotifier) + AppScope (InheritedNotifier)
  screens/     home, duelo, resultado, prática
  widgets/     drawer do herói, lista de colegas, folha de desafio, barra de pontos
  theme/       tradução do pack para ThemeData
assets/themes/ futebol.json · musica.json · games.json
```

Sem pacotes externos: só `dart:convert` e o próprio Flutter. Decisões que sustentam a demo:

- **Um tema = um arquivo.** Paleta, tipografia, ícones, vocabulário, textos e os 18 enunciados ficam no JSON. Um tema novo não toca em código de tela.
- **Perguntas separadas da narrativa.** O banco guarda número, opções e resposta; o pack guarda a história. Um pack sem enunciado cai no texto neutro em vez de quebrar.
- **Motor de duelo puro.** Pontuação, avanço e placar são testáveis sem widget nem timer.

## O que o time pedagógico destrava

O MVP prova a mecânica; o valor educacional depende de quem entende de aprendizagem.

- **Progressão curricular** — alinhar as 18 perguntas a habilidades e anos escolares, com dificuldade calibrada por série.
- **Banco de itens validado** — revisão de enunciados e distratores, e um processo para escrever os três contextos sem perder rigor matemático.
- **Métricas de aprendizagem** — medir erro por habilidade, tempo de resposta e retenção, não só pontos. É o que separa engajamento de aprendizado.
- **Adequação por faixa etária** — dos 10 aos 20 anos, o tom e o tipo de recompensa mudam; hoje há um único registro para todo mundo.
- **Equidade e acessibilidade** — garantir que a versão temática não introduza vocabulário que dificulte a leitura do problema, e cobrir leitores de tela e contraste.
- **Experimento controlado** — comparar turmas com e sem personalização para provar que a história temática melhora o desempenho, e não só o tempo de tela.

Com esse time ao lado, o próximo passo deixa de ser "mais temas" e passa a ser "aprendizado mensurável".
