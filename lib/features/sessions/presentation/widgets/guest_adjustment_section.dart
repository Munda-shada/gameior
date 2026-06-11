import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ADJUST SLOTS'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              CheckboxListTile.adaptive(
                title: Text('I am playing', style: theme.textTheme.headlineSmall),
                value: userIsPlaying,
                activeColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: onUserIsPlayingChanged,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Extra Guests', style: theme.textTheme.headlineSmall),
                      Text('Add friends to play along', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: theme.colorScheme.onSurfaceVariant),
                        onPressed: onDecrementGuests,
                      ),
                      Text('$guestCount', style: theme.textTheme.headlineMedium),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
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
                  style: (theme.textTheme.bodySmall ?? const TextStyle()).copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
