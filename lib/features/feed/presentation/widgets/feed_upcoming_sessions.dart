import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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
    final theme = Theme.of(context);
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
    RsvpBadgeConfig badgeConfig = rsvpBadge(myStatus, myWaitlistPos, theme);

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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
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
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isLocked || deadlinePassed)
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Date + venue row
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (venue.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            venue,
                            style: theme.textTheme.bodySmall,
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
                      // Cost chip + Payment model row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              costLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              paymentModel.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // RSVP status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeConfig.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                            color: badgeConfig.color.withValues(alpha: 0.4),
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
                              style: theme.textTheme.labelSmall?.copyWith(
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

RsvpBadgeConfig rsvpBadge(String status, int? waitlistPos, ThemeData theme) {
  switch (status) {
    case 'yes':
    case 'guest':
      return RsvpBadgeConfig(
        label: 'Confirmed',
        color: theme.colorScheme.primary,
        icon: Icons.check_circle_outline,
      );
    case 'waitlist':
      final pos = waitlistPos != null ? ' #$waitlistPos' : '';
      return RsvpBadgeConfig(
        label: 'Waitlist$pos',
        color: theme.colorScheme.tertiary,
        icon: Icons.hourglass_top_outlined,
      );
    case 'maybe':
      return RsvpBadgeConfig(
        label: 'Maybe',
        color: theme.colorScheme.tertiary,
        icon: Icons.help_outline,
      );
    case 'no':
      return RsvpBadgeConfig(
        label: 'Not Going',
        color: theme.colorScheme.outline,
        icon: Icons.cancel_outlined,
      );
    default:
      return RsvpBadgeConfig(
        label: "Not RSVP'd yet",
        color: theme.colorScheme.onSurfaceVariant,
        icon: Icons.radio_button_unchecked,
      );
  }
}
