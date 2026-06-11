import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/sessions/widgets/rsvp_buttons.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class RsvpSection extends StatelessWidget {
  final RsvpStatus myStatus;
  final bool isRsvpClosed;
  final bool isRsvpUpdating;
  final ValueChanged<RsvpStatus> onRsvpChanged;
  final String? deadlineStr;

  const RsvpSection({
    required this.myStatus,
    required this.isRsvpClosed,
    required this.isRsvpUpdating,
    required this.onRsvpChanged,
    required this.deadlineStr,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'YOUR RSVP'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              RsvpButtons(
                currentStatus: myStatus,
                isLocked: isRsvpUpdating || isRsvpClosed,
                isLoading: isRsvpUpdating,
                onChanged: onRsvpChanged,
              ),
              if (deadlineStr != null && !isRsvpClosed) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'RSVP Deadline: $deadlineStr',
                  style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                    color: theme.colorScheme.error,
                    fontStyle: FontStyle.italic,
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
