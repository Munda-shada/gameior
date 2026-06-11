import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/capacity_progress_bar.dart';

class UpcomingSessionTile extends StatelessWidget {
  final Map<String, dynamic> game;
  final String? userId;

  const UpcomingSessionTile({
    required this.game,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gameId = game['id'] as String;
    final groupId = game['group_id'] as String;
    final title = game['title'] as String? ?? 'Match Session';
    final venue = game['venue'] as String? ?? '';
    final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
    final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
    final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
    final paymentModel = game['payment_model'] as String? ?? 'prepaid';
    final isLocked = game['rsvp_locked'] as bool? ?? false;
    final rsvpDeadline = game['rsvp_deadline'] != null
        ? DateTime.parse(game['rsvp_deadline'] as String)
        : null;
    final deadlinePassed =
        rsvpDeadline != null && DateTime.now().toUtc().isAfter(rsvpDeadline);

    final groupInfo = game['groups'] as Map<String, dynamic>? ?? {};
    final groupName = groupInfo['name'] as String? ?? '';

    final rsvps = game['rsvps'] as List? ?? [];

    // Calculate confirmed count
    final confirmedCount = rsvps.fold<int>(0, (sum, r) {
      final s = r['status'] as String? ?? '';
      if (s == 'yes' || s == 'guest') {
        final isPlaying = r['user_is_playing'] as bool? ?? true;
        final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
        return sum + (isPlaying ? 1 : 0) + guests;
      }
      return sum;
    });

    // Find my RSVP
    final myRsvp = rsvps.firstWhere(
      (r) => r['user_id'] == userId,
      orElse: () => null,
    );
    final myStatus = myRsvp != null ? myRsvp['status'] as String? ?? 'unanswered' : 'unanswered';
    final myWaitlistPos = myRsvp != null ? myRsvp['waitlist_position'] as int? : null;

    // Format time
    final now = DateTime.now();
    final isToday = scheduledAt.day == now.day &&
        scheduledAt.month == now.month &&
        scheduledAt.year == now.year;
    final isTomorrow = scheduledAt.day == now.add(const Duration(days: 1)).day &&
        scheduledAt.month == now.add(const Duration(days: 1)).month &&
        scheduledAt.year == now.add(const Duration(days: 1)).year;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today, ${DateFormat('h:mm a').format(scheduledAt)}';
    } else if (isTomorrow) {
      dateLabel = 'Tomorrow, ${DateFormat('h:mm a').format(scheduledAt)}';
    } else {
      dateLabel = DateFormat('EEE d MMM, h:mm a').format(scheduledAt);
    }

    // RSVP badge config
    RsvpBadgeConfig badgeConfig = rsvpBadge(myStatus, myWaitlistPos);

    // Cost label
    final costLabel = paymentModel == 'prepaid' && costPaise > 0
        ? '₹${(costPaise / 100).toStringAsFixed(0)}'
        : paymentModel == 'postpaid'
            ? 'Split after'
            : 'Free';

    return GestureDetector(
      onTap: () => context.push('/group/$groupId/game/$gameId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            // Top: colored status strip
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: badgeConfig.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group name + lock icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          groupName.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      if (isLocked || deadlinePassed)
                        const Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: AppColors.textDisabled,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    title,
                    style: AppTextStyles.headlineSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Date + venue row
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(dateLabel,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  if (venue.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue,
                            style: AppTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  // Capacity bar
                  CapacityProgressBar(
                    confirmed: confirmedCount,
                    capacity: capacity,
                    showLabel: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Bottom row: cost + RSVP badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Cost chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          costLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      // RSVP status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeConfig.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: badgeConfig.color.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              badgeConfig.icon,
                              size: 11,
                              color: badgeConfig.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              badgeConfig.label,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: badgeConfig.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RsvpBadgeConfig {
  final String label;
  final Color color;
  final IconData icon;
  const RsvpBadgeConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}

RsvpBadgeConfig rsvpBadge(String status, int? waitlistPos) {
  switch (status) {
    case 'yes':
    case 'guest':
      return RsvpBadgeConfig(
        label: 'Confirmed',
        color: AppColors.primary,
        icon: Icons.check_circle_outline,
      );
    case 'waitlist':
      final pos = waitlistPos != null ? ' #$waitlistPos' : '';
      return RsvpBadgeConfig(
        label: 'Waitlist$pos',
        color: AppColors.waitlist,
        icon: Icons.hourglass_top_outlined,
      );
    case 'maybe':
      return RsvpBadgeConfig(
        label: 'Maybe',
        color: AppColors.waitlist,
        icon: Icons.help_outline,
      );
    case 'no':
      return RsvpBadgeConfig(
        label: 'Not Going',
        color: AppColors.textDisabled,
        icon: Icons.cancel_outlined,
      );
    default:
      return RsvpBadgeConfig(
        label: "Not RSVP'd yet",
        color: AppColors.unanswered,
        icon: Icons.radio_button_unchecked,
      );
  }
}
