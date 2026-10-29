import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/questions.dart';
import '../models/duel_engine.dart';
import '../models/question.dart';
import '../models/student.dart';
import '../state/app_scope.dart';
import 'result_screen.dart';

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key, required this.rival, required this.subject});

  final Student rival;
  final Subject subject;

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  late final DuelEngine _engine;
  Timer? _timer;
  int _secondsLeft = kSecondsPerQuestion;
  bool _answering = false;
  String? _chosen;

  @override
  void initState() {
    super.initState();
    _engine = DuelEngine(
      questions: questionsFor(widget.subject).take(kQuestionsPerDuel).toList(),
      opponentScore: opponentScore(Random()),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        _answer('');
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _answer(String option) async {
    if (_answering || _engine.finished) return;
    _answering = true;
    _timer?.cancel();

    final elapsed = (kSecondsPerQuestion - _secondsLeft) * 1000;
    _engine.answer(option, elapsed);
    setState(() => _chosen = option);

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    if (_engine.finished) {
      _finish();
    } else {
      setState(() {
        _secondsLeft = kSecondsPerQuestion;
        _chosen = null;
        _answering = false;
      });
      _startTimer();
    }
  }

  void _finish() {
    _timer?.cancel();
    final state = AppScope.of(context);
    final result = _engine.result;
    state.addPoints(result.score);
    state.bumpStreak();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(result: result, rival: widget.rival),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;

    if (_engine.finished) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.rival.name)),
        body: const SizedBox.shrink(),
      );
    }

    final question = _engine.current;
    final progress = _secondsLeft / kSecondsPerQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rival.name),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pergunta ${_engine.index + 1} de ${_engine.questions.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.textSecondary,
                    ),
                  ),
                  Text(
                    '$_secondsLeft s',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: progress < 0.3
                          ? theme.colors.accent
                          : theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colors.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress < 0.3 ? theme.colors.accent : theme.colors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: theme.colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = question.options[index];
                    return _OptionButton(
                      label: option,
                      state: _optionState(option, question),
                      onTap: _answering ? null : () => _answer(option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _OptionState _optionState(String option, Question question) {
    if (_chosen == null) return _OptionState.idle;
    if (option == question.answer) return _OptionState.correct;
    if (option == _chosen) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
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
    final Color? fill;

    switch (state) {
      case _OptionState.correct:
        border = const Color(0xFF34C759);
        fill = const Color(0xFF34C759).withValues(alpha: 0.15);
      case _OptionState.wrong:
        border = const Color(0xFFFF3B30);
        fill = const Color(0xFFFF3B30).withValues(alpha: 0.15);
      case _OptionState.dimmed:
        border = theme.colors.surfaceAlt;
        fill = null;
      case _OptionState.idle:
        border = theme.colors.surfaceAlt;
        fill = theme.colors.surface;
    }

    return Material(
      color: fill ?? theme.colors.surface,
      borderRadius: BorderRadius.circular(theme.radius * 0.8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radius * 0.8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
