import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

class GuestDialog extends StatefulWidget {
  final int maxGuests;
  final int remainingSpots;
  const GuestDialog({required this.maxGuests, required this.remainingSpots, super.key});

  @override
  State<GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends State<GuestDialog> {
  bool _userIsPlaying = true;
  int _guestCount = 1;

  @override
  Widget build(BuildContext context) {
    final neededSlots = (_userIsPlaying ? 1 : 0) + _guestCount;
    final exceedsSpots = neededSlots > widget.remainingSpots;

    return AlertDialog(
      title: const Text('Add Guests RSVP'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile.adaptive(
            title: const Text('I am also playing myself', style: AppTextStyles.headlineSmall),
            value: _userIsPlaying,
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              if (val != null) setState(() => _userIsPlaying = val);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('Extra Guests Count:', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _guestCount > 0 ? () => setState(() => _guestCount--) : null,
              ),
              Text('$_guestCount', style: AppTextStyles.displayMedium),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _guestCount < widget.maxGuests ? () => setState(() => _guestCount++) : null,
              ),
            ],
          ),
          if (exceedsSpots) ...[
            const SizedBox(height: AppSpacing.base),
            Text(
              'Warning: Exceeds remaining confirmed spots (${widget.remainingSpots}). If you proceed, you may be waitlisted.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.destructive, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          onPressed: () {
            Navigator.of(context).pop({
              'guestCount': _guestCount,
              'userIsPlaying': _userIsPlaying,
            });
          },
          child: const Text('Confirm RSVP'),
        ),
      ],
    );
  }
}
