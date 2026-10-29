import 'package:flutter/material.dart';

import '../models/question.dart';
import '../models/student.dart';
import '../state/app_scope.dart';

class ClassmateTile extends StatelessWidget {
  const ClassmateTile({
    super.key,
    required this.student,
    required this.onChallenge,
  });

  final Student student;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).theme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: student.color.withValues(alpha: 0.18),
              child: Text(student.emoji, style: const TextStyle(fontSize: 19)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${student.favoriteSubject.label} · ${student.points} ${theme.word('points')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: onChallenge,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              child: Text(theme.word('challenge')),
            ),
          ],
        ),
      ),
    );
  }
}
