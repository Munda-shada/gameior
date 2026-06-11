import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

class AnnouncementCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const AnnouncementCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    final message = item['message'] as String? ?? '';
    final groupInfo = item['groups'] as Map<String, dynamic>? ?? {};
    final groupName = groupInfo['name'] as String? ?? 'Group';
    final profile = item['profiles'] as Map<String, dynamic>? ?? {};
    final senderName = profile['display_name'] as String? ?? 'Organizer';
    final emoji = profile['emoji'] as String? ?? '📣';
    final createdAt = DateTime.parse(item['created_at'] as String).toLocal();
    final linkedGameId = item['linked_game_id'] as String?;
    final groupId = item['group_id'] as String?;

    // Relative time
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    String timeLabel;
    if (diff.inMinutes < 60) {
      timeLabel = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeLabel = '${diff.inHours}h ago';
    } else {
      timeLabel = DateFormat('d MMM').format(createdAt);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: emoji + name + group + time
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senderName, style: AppTextStyles.labelLarge),
                    Text(
                      '$groupName · $timeLabel',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Message
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          // Deep link to game if present
          if (linkedGameId != null && groupId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => context.push('/group/$groupId/game/$linkedGameId'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sports_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'View Game Session →',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
