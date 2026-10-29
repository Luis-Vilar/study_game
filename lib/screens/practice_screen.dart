import 'package:flutter/material.dart';

import '../data/questions.dart';
import '../models/duel_engine.dart';
import '../models/question.dart';
import '../state/app_scope.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<Question> _questions = const [];
  int _index = 0;
  int _correct = 0;
  int _score = 0;
  bool _started = false;
  bool _done = false;
  bool _answering = false;
  String? _chosen;

  void _start() {
    setState(() {
      _questions = practiceSet();
      _index = 0;
      _correct = 0;
      _score = 0;
      _chosen = null;
      _started = true;
      _done = false;
      _answering = false;
    });
  }

  Future<void> _answer(String option) async {
    if (_answering || _done) return;
    _answering = true;
    final question = _questions[_index];
    final wasCorrect = option == question.answer;

    setState(() {
      _chosen = option;
      if (wasCorrect) {
        _correct++;
        _score += practicePoints(true);
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_index + 1 >= _questions.length) {
      final state = AppScope.of(context);
      state.addPoints(_score);
      state.bumpStreak();
      setState(() {
        _done = true;
        _answering = false;
      });
    } else {
      setState(() {
        _index++;
        _chosen = null;
        _answering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;

    if (!_started) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                theme.icons['practice'] ?? '📚',
                style: const TextStyle(fontSize: 44),
              ),
              const SizedBox(height: 12),
              Text(
                theme.word('practice'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '5 perguntas sem pressa, +50 pontos por acerto.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _start,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: const Text('Começar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_done) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                theme.text('practiceDone'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: theme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$_correct de ${_questions.length} acertos',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+$_score ${theme.word('points')}',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: theme.colors.primary,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _start,
                child: const Text('Jogar de novo'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_index];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Pergunta ${_index + 1} de ${_questions.length}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: theme.colors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colors.surface,
            borderRadius: BorderRadius.circular(theme.radius),
            border: Border.all(color: theme.colors.surfaceAlt),
          ),
          child: Text(
            question.promptFor(theme),
            style: TextStyle(
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: theme.colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (final option in question.options)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PracticeOption(
              label: option,
              state: _stateFor(option, question),
              onTap: _answering ? null : () => _answer(option),
            ),
          ),
        if (_chosen != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              theme.text(
                _chosen == question.answer
                    ? 'practiceCorrect'
                    : 'practiceWrong',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: theme.colors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }

  _OptionState _stateFor(String option, Question question) {
    if (_chosen == null) return _OptionState.idle;
    if (option == question.answer) return _OptionState.correct;
    if (option == _chosen) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _PracticeOption extends StatelessWidget {
  const _PracticeOption({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final Color border;
    final Color fill;

    switch (state) {
      case _OptionState.correct:
        border = const Color(0xFF34C759);
        fill = const Color(0xFF34C759).withValues(alpha: 0.15);
      case _OptionState.wrong:
        border = const Color(0xFFFF3B30);
        fill = const Color(0xFFFF3B30).withValues(alpha: 0.15);
      case _OptionState.dimmed:
        border = theme.colors.surfaceAlt;
        fill = theme.colors.surface;
      case _OptionState.idle:
        border = theme.colors.surfaceAlt;
        fill = theme.colors.surface;
    }

    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(theme.radius * 0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius * 0.8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(theme.radius * 0.8),
            border: Border.all(color: border, width: 1.4),
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: state == _OptionState.dimmed
                  ? theme.colors.textSecondary
                  : theme.colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
