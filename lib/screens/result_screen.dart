import 'package:flutter/material.dart';

import '../models/duel_engine.dart';
import '../models/theme_pack.dart';
import '../models/student.dart';
import '../state/app_scope.dart';

/// Pantalla final del duelo.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result, required this.rival});

  final DuelResult result;
  final Student rival;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;
    final message = result.won
        ? theme.text('duelWin')
        : result.tied
            ? theme.text('duelTie')
            : theme.text('duelLose');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(theme.text('resultTitle')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Spacer(),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: theme.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ScoreBlock(
                    label: 'Você',
                    value: result.score,
                    color: theme.colors.primary,
                    theme: theme,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '×',
                      style: TextStyle(
                        fontSize: 22,
                        color: theme.colors.textSecondary,
                      ),
                    ),
                  ),
                  _ScoreBlock(
                    label: rival.name,
                    value: result.opponentScore,
                    color: theme.colors.textSecondary,
                    theme: theme,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                '${result.correct}/${result.total} acertos · +${result.score} pts',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colors.textSecondary,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Voltar aos duelos'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final int value;
  final Color color;
  final ThemePack theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: theme.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
