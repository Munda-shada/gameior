import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/models/enums.dart';

class StatusBadge extends StatelessWidget {
  final DueStatus status;
  const StatusBadge({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade600;
    String label = 'UNPAID';

    switch (status) {
      case DueStatus.unpaid:
        bg = AppColors.destructiveMuted;
        fg = AppColors.destructive;
        label = 'UNPAID';
        break;
      case DueStatus.pendingVerification:
        bg = AppColors.waitlistMuted;
        fg = AppColors.waitlist;
        label = 'PENDING VERIFICATION';
        break;
      case DueStatus.paid:
        bg = AppColors.primaryMuted;
        fg = AppColors.primaryDark;
        label = 'PAID';
        break;
      case DueStatus.rejected:
        bg = AppColors.destructiveMuted;
        fg = AppColors.destructive;
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
