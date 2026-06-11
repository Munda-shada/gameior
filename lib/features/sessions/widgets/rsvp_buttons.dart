import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/core/theme/app_colors.dart';

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
    final theme = Theme.of(context);

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    if (isLocked) {
      final statusLabel = currentStatus != null && currentStatus != RsvpStatus.unanswered
          ? currentStatus!.name.toUpperCase()
          : 'CLOSED';
      final statusColor = currentStatus != null && currentStatus != RsvpStatus.unanswered
          ? currentStatus!.color(context)
          : theme.colorScheme.onSurfaceVariant;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 18, color: statusColor),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'RSVP is locked: $statusLabel',
              style: theme.textTheme.labelLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
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
            _buildButton(context, RsvpStatus.yes, 'YES', btnWidth, theme),
            _buildButton(context, RsvpStatus.no, 'NO', btnWidth, theme),
            _buildButton(context, RsvpStatus.maybe, 'MAYBE', btnWidth, theme),
            _buildButton(context, RsvpStatus.guest, 'GUEST', btnWidth, theme),
          ],
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    RsvpStatus status,
    String label,
    double width,
    ThemeData theme,
  ) {
    final isSelected = currentStatus == status;
    final statusColor = status.color(context);

    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? statusColor : theme.colorScheme.surface,
          foregroundColor: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: isSelected ? statusColor : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
        ),
        onPressed: () => onChanged(status),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}