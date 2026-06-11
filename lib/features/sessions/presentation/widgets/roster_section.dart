import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class RosterSection extends StatelessWidget {
  final int confirmedCount;
  final int capacity;
  final List<dynamic> confirmedPlayers;

  const RosterSection({
    required this.confirmedCount,
    required this.capacity,
    required this.confirmedPlayers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'PLAYERS CONFIRMED ($confirmedCount / $capacity)'),
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
              if (confirmedPlayers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text('No players confirmed yet.', style: AppTextStyles.bodyMedium),
                  ),
                )
              else
                ...confirmedPlayers.map((r) {
                  final prof = r['profiles'] as Map<String, dynamic>? ?? {};
                  final name = prof['display_name'] as String? ?? 'Player';
                  final emoji = prof['emoji'] as String? ?? '🏸';
                  final guestCount = (r['guest_count'] as num?)?.toInt() ?? 0;
                  final isPlaying = r['user_is_playing'] as bool? ?? true;

                  final String guestLabel = guestCount > 0
                      ? ' + $guestCount guest${guestCount > 1 ? 's' : ''}'
                      : '';
                  final String playingLabel = isPlaying ? '' : ' (guest only)';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '$name$guestLabel$playingLabel',
                            style: AppTextStyles.bodyLarge,
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
