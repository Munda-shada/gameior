import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class WaitlistSection extends StatelessWidget {
  final List<dynamic> waitlistedPlayers;

  const WaitlistSection({required this.waitlistedPlayers, super.key});

  @override
  Widget build(BuildContext context) {
    if (waitlistedPlayers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'WAITLIST (${waitlistedPlayers.length})'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...waitlistedPlayers.asMap().entries.map((entry) {
                final idx = entry.key;
                final r = entry.value;
                final prof = r['profiles'] as Map<String, dynamic>? ?? {};
                final name = prof['display_name'] as String? ?? 'Player';
                final emoji = prof['emoji'] as String? ?? '🏸';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(name, style: AppTextStyles.bodyLarge),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.waitlistMuted,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          'W${idx + 1}',
                          style: AppTextStyles.labelSmall.copyWith(color: AppColors.waitlist, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
