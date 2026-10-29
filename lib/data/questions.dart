import '../models/question.dart';

const List<Question> kQuestions = [
  // Matemática
  Question(
    id: 'm1',
    subject: Subject.matematica,
    difficulty: 1,
    basePrompt: 'Quanto é 3 + 2?',
    options: ['4', '5', '6', '7'],
    answer: '5',
  ),
  Question(
    id: 'm2',
    subject: Subject.matematica,
    difficulty: 1,
    basePrompt: 'Quanto é 14 - 6?',
    options: ['6', '7', '8', '9'],
    answer: '8',
  ),
  Question(
    id: 'm3',
    subject: Subject.matematica,
    difficulty: 2,
    basePrompt: 'Quanto é 7 × 6?',
    options: ['36', '40', '42', '48'],
    answer: '42',
  ),
  Question(
    id: 'm4',
    subject: Subject.matematica,
    difficulty: 2,
    basePrompt: 'Quanto é 48 ÷ 6?',
    options: ['6', '7', '8', '9'],
    answer: '8',
  ),
  Question(
    id: 'm5',
    subject: Subject.matematica,
    difficulty: 3,
    basePrompt: 'Quanto é 3/4 de 20?',
    options: ['10', '12', '15', '18'],
    answer: '15',
  ),
  Question(
    id: 'm6',
    subject: Subject.matematica,
    difficulty: 3,
    basePrompt: 'Quanto é 15% de 200?',
    options: ['15', '25', '30', '45'],
    answer: '30',
  ),

  // História
  Question(
    id: 'h1',
    subject: Subject.historia,
    difficulty: 1,
    basePrompt: 'Em que ano o Brasil proclamou sua independência?',
    options: ['1500', '1822', '1888', '1988'],
    answer: '1822',
  ),
  Question(
    id: 'h2',
    subject: Subject.historia,
    difficulty: 1,
    basePrompt: 'Quem foi o primeiro imperador do Brasil?',
    options: ['Dom Pedro I', 'Dom Pedro II', 'Getúlio Vargas', 'Tiradentes'],
    answer: 'Dom Pedro I',
  ),
  Question(
    id: 'h3',
    subject: Subject.historia,
    difficulty: 2,
    basePrompt: 'Qual foi o primeiro produto explorado no Brasil colonial?',
    options: ['Café', 'Pau-brasil', 'Cana-de-açúcar', 'Ouro'],
    answer: 'Pau-brasil',
  ),
  Question(
    id: 'h4',
    subject: Subject.historia,
    difficulty: 2,
    basePrompt: 'O que a Lei Áurea, de 1888, aboliu?',
    options: ['A escravidão', 'A monarquia', 'O voto feminino', 'A censura'],
    answer: 'A escravidão',
  ),
  Question(
    id: 'h5',
    subject: Subject.historia,
    difficulty: 3,
    basePrompt: 'Qual movimento pediu eleições diretas em 1984?',
    options: ['Diretas Já', 'Tenentismo', 'Integralismo', 'Abolicionismo'],
    answer: 'Diretas Já',
  ),
  Question(
    id: 'h6',
    subject: Subject.historia,
    difficulty: 3,
    basePrompt: 'Em que ano começou a ditadura militar no Brasil?',
    options: ['1930', '1945', '1964', '1985'],
    answer: '1964',
  ),

  // Ciências
  Question(
    id: 'c1',
    subject: Subject.ciencias,
    difficulty: 1,
    basePrompt: 'Qual é a menor unidade viva dos seres vivos?',
    options: ['Célula', 'Átomo', 'Órgão', 'Tecido'],
    answer: 'Célula',
  ),
  Question(
    id: 'c2',
    subject: Subject.ciencias,
    difficulty: 1,
    basePrompt: 'Qual gás as plantas absorvem na fotossíntese?',
    options: ['Oxigênio', 'Gás carbônico', 'Nitrogênio', 'Hidrogênio'],
    answer: 'Gás carbônico',
  ),
  Question(
    id: 'c3',
    subject: Subject.ciencias,
    difficulty: 2,
    basePrompt: 'Qual órgão bombeia o sangue pelo corpo?',
    options: ['Pulmão', 'Fígado', 'Coração', 'Rim'],
    answer: 'Coração',
  ),
  Question(
    id: 'c4',
    subject: Subject.ciencias,
    difficulty: 2,
    basePrompt: 'Qual é o planeta mais próximo do Sol?',
    options: ['Vênus', 'Marte', 'Mercúrio', 'Terra'],
    answer: 'Mercúrio',
  ),
  Question(
    id: 'c5',
    subject: Subject.ciencias,
    difficulty: 3,
    basePrompt: 'Qual é a principal função das mitocôndrias?',
    options: [
      'Produzir energia',
      'Armazenar água',
      'Filtrar o sangue',
      'Transportar oxigênio',
    ],
    answer: 'Produzir energia',
  ),
  Question(
    id: 'c6',
    subject: Subject.ciencias,
    difficulty: 3,
    basePrompt: 'Qual é a fórmula química da água?',
    options: ['CO₂', 'H₂O', 'O₂', 'NaCl'],
    answer: 'H₂O',
  ),
];

List<Question> questionsFor(Subject subject) =>
    kQuestions.where((q) => q.subject == subject).toList();

/// Set fijo de la práctica solo: cinco materias mezcladas.
List<Question> practiceSet() {
  const ids = ['m1', 'h1', 'c1', 'm3', 'h3'];
  return [
    for (final id in ids) kQuestions.firstWhere((q) => q.id == id),
  ];
}
