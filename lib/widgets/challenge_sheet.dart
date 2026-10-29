import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/student.dart';
import '../state/app_scope.dart';

/// Hoja inferior para elegir la materia del desafío.
class ChallengeSheet extends StatelessWidget {
  const ChallengeSheet({super.key, required this.rival});

  final Student rival;

  static Future<Subject?> show(BuildContext context, Student rival) {
    return showModalBottomSheet<Subject>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ChallengeSheet(rival: rival),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.radius * 1.4),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Desafiar ${rival.name}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rival desafiado! Escolha a matéria.',
            style: TextStyle(
              fontSize: 13,
              color: theme.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          for (final subject in Subject.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(subject),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  side: BorderSide(color: theme.colors.surfaceAlt),
                ),
                child: Text(
                  subject.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
