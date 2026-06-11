import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/models/enums.dart';

class StatusBadge extends StatelessWidget {
  final DueStatus status;
  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color bg = theme.colorScheme.surfaceContainerHighest;
    Color fg = theme.colorScheme.onSurfaceVariant;
    String label = 'UNPAID';

    switch (status) {
      case DueStatus.unpaid:
        bg = theme.colorScheme.error.withValues(alpha: 0.1);
        fg = theme.colorScheme.error;
        label = 'UNPAID';
        break;
      case DueStatus.pendingVerification:
        bg = theme.colorScheme.tertiary.withValues(alpha: 0.1);
        fg = theme.colorScheme.tertiary;
        label = 'PENDING VERIFICATION';
        break;
      case DueStatus.paid:
        bg = theme.colorScheme.primary.withValues(alpha: 0.1);
        fg = theme.colorScheme.primary;
        label = 'PAID';
        break;
      case DueStatus.rejected:
        bg = theme.colorScheme.error.withValues(alpha: 0.1);
        fg = theme.colorScheme.error;
        label = 'REJECTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
