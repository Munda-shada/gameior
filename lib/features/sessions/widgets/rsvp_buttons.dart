import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/models/enums.dart';

class RsvpButtons extends StatelessWidget {
  const RsvpButtons({
    super.key,
    required this.currentStatus,
    required this.onChanged,
    this.isLocked = false,
    this.isLoading = false,
  });

  final RsvpStatus? currentStatus;
  final ValueChanged<RsvpStatus> onChanged;
  final bool isLocked;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      );
    }

    if (isLocked) {
      final statusLabel = currentStatus != null && currentStatus != RsvpStatus.unanswered
          ? currentStatus!.name.toUpperCase()
          : 'CLOSED';
      final statusColor = currentStatus != null && currentStatus != RsvpStatus.unanswered
          ? currentStatus!.color
          : AppColors.textDisabled;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 18, color: statusColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'RSVP is locked: $statusLabel',
              style: AppTextStyles.labelLarge.copyWith(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double btnWidth = (constraints.maxWidth - (AppSpacing.xs * 6)) / 4;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButton(RsvpStatus.yes, 'YES', btnWidth),
            _buildButton(RsvpStatus.no, 'NO', btnWidth),
            _buildButton(RsvpStatus.maybe, 'MAYBE', btnWidth),
            _buildButton(RsvpStatus.guest, 'GUEST', btnWidth),
          ],
        );
      },
    );
  }

  Widget _buildButton(RsvpStatus status, String label, double width) {
    final isSelected = currentStatus == status;
    final statusColor = status.color;
    final statusMuted = status.mutedColor;

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? statusColor : AppColors.surface,
          foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: isSelected ? statusColor : AppColors.border,
              width: 1.5,
            ),
          ),
        ),
        onPressed: () => onChanged(status),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}