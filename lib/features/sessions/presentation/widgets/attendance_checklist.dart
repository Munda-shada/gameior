import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class AttendanceChecklist extends StatelessWidget {
  final bool chargeAllRsvped;
  final List<dynamic> eligiblePlayers;
  final Set<String> attendedPlayerIds;
  final bool allDuesSettled;
  final Function(String, bool) onAttendanceChanged;
  final VoidCallback onSelectAll;
  final VoidCallback onClearAll;

  const AttendanceChecklist({
    required this.chargeAllRsvped,
    required this.eligiblePlayers,
    required this.attendedPlayerIds,
    required this.allDuesSettled,
    required this.onAttendanceChanged,
    required this.onSelectAll,
    required this.onClearAll,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: chargeAllRsvped
              ? 'ATTENDANCE LIST (ALL RSVPS CHARGED)'
              : 'ATTENDANCE SHEET (ONLY CHECKED CHARGED)',
        ),
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
              if (eligiblePlayers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
                    child: Text('No players confirmed (YES/Guest) for this session.', style: AppTextStyles.bodyMedium),
                  ),
                )
              else ...[
                if (!allDuesSettled)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${attendedPlayerIds.length} of ${eligiblePlayers.length} attended',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                              onPressed: onSelectAll,
                              child: const Text('Select All', style: TextStyle(fontSize: 12)),
                            ),
                            const VerticalDivider(width: 8, thickness: 1, indent: 4, endIndent: 4),
                            TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
                              onPressed: onClearAll,
                              child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const Divider(),
                ...eligiblePlayers.map((r) {
                  final profile = r['profiles'] as Map<String, dynamic>? ?? {};
                  final name = profile['display_name'] as String? ?? 'Player';
                  final emoji = profile['emoji'] as String? ?? '🏸';
                  final userId = r['user_id'] as String;

                  final isAttending = attendedPlayerIds.contains(userId);

                  return CheckboxListTile.adaptive(
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    enabled: !allDuesSettled,
                    title: Row(
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: isAttending ? FontWeight.bold : FontWeight.normal,
                              color: isAttending ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    value: isAttending,
                    onChanged: (val) {
                      if (val != null) {
                        onAttendanceChanged(userId, val);
                      }
                    },
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
