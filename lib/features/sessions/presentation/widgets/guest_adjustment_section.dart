import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class GuestAdjustmentSection extends StatelessWidget {
  final bool userIsPlaying;
  final ValueChanged<bool?> onUserIsPlayingChanged;
  final int guestCount;
  final VoidCallback onDecrementGuests;
  final VoidCallback onIncrementGuests;
  final bool exceedsSpots;

  const GuestAdjustmentSection({
    required this.userIsPlaying,
    required this.onUserIsPlayingChanged,
    required this.guestCount,
    required this.onDecrementGuests,
    required this.onIncrementGuests,
    required this.exceedsSpots,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ADJUST SLOTS'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              CheckboxListTile.adaptive(
                title: const Text('I am playing', style: AppTextStyles.headlineSmall),
                value: userIsPlaying,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: onUserIsPlayingChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Extra Guests', style: AppTextStyles.headlineSmall),
                      Text('Add friends to play along', style: AppTextStyles.bodySmall),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                        onPressed: onDecrementGuests,
                      ),
                      Text('$guestCount', style: AppTextStyles.headlineMedium),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: onIncrementGuests,
                      ),
                    ],
                  ),
                ],
              ),
              if (exceedsSpots) ...[
                const SizedBox(height: AppSpacing.base),
                Text(
                  'Warning: Session is full. Submitting payment will request slot verification from the organizer.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.destructive, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
