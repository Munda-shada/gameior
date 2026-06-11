import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class GameSessionCard extends StatelessWidget {
  final String groupId;
  final Map<String, dynamic> game;
  final String? userId;

  const GameSessionCard({
    required this.groupId,
    required this.game,
    required this.userId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameId = game['id'] as String;
    final title = game['title'] as String? ?? 'Match Session';
    final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
    final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(scheduledAt);
    final venue = game['venue'] as String? ?? 'Venue';
    final capacity = (game['max_capacity'] as num?)?.toInt() ?? 20;
    final costPaise = (game['cost_paise'] as num?)?.toInt() ?? 0;
    final paymentModel = game['payment_model'] as String? ?? 'prepaid';
    final status = game['status'] as String? ?? 'upcoming';

    final rsvps = game['rsvps'] as List? ?? [];
    final dues = game['payment_dues'] as List? ?? [];

    // Calculate confirmed slots
    final confirmedCount = rsvps.fold<int>(0, (sum, r) {
      final rStatus = r['status'] as String? ?? 'unanswered';
      if (rStatus == 'yes' || rStatus == 'guest') {
        final isPlaying = r['user_is_playing'] as bool? ?? true;
        final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
        return sum + (isPlaying ? 1 : 0) + guests;
      }
      return sum;
    });

    // Find current user's RSVP status
    String myRsvpStatusLabel = '';
    Color myRsvpColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
    final myRsvp = rsvps.firstWhere((r) => r['user_id'] == userId, orElse: () => null);
    if (myRsvp != null) {
      final rStatus = myRsvp['status'] as String? ?? 'unanswered';
      if (rStatus == 'yes') {
        myRsvpStatusLabel = 'Playing ✓';
        myRsvpColor = theme.colorScheme.primary;
      } else if (rStatus == 'no') {
        myRsvpStatusLabel = 'Not attending';
        myRsvpColor = theme.colorScheme.error;
      } else if (rStatus == 'maybe') {
        myRsvpStatusLabel = 'Maybe';
        myRsvpColor = theme.colorScheme.tertiary;
      } else if (rStatus == 'waitlist') {
        final pos = myRsvp['waitlist_position'] != null ? '#${myRsvp['waitlist_position']}' : '';
        myRsvpStatusLabel = 'Waitlist $pos';
        myRsvpColor = theme.colorScheme.tertiary;
      } else if (rStatus == 'guest') {
        myRsvpStatusLabel = 'Guest Added';
        myRsvpColor = theme.colorScheme.primary;
      }
    }

    final String costLabel = paymentModel == 'prepaid'
        ? '₹${(costPaise / 100).toStringAsFixed(0)}'
        : 'Post-paid (Split)';

    final Color statusColor = status == 'upcoming'
        ? theme.colorScheme.primary
        : (status == 'completed' ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5));

    // Left border accent logic: red if unpaid, green if prepaid, blue if postpaid
    final myDue = dues.firstWhere((d) => d['player_id'] == userId, orElse: () => null);
    final isUnpaid = myDue != null && myDue['status'] != 'paid';
    final Color accentColor = isUnpaid
        ? theme.colorScheme.error
        : (paymentModel == 'prepaid' ? Colors.green : Colors.blue);

    // Unpaid badge: count payment_dues where status == 'pending_verification'
    final pendingDuesCount = dues.where((d) => d['status'] == 'pending_verification').length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4.0,
                color: accentColor,
              ),
              Expanded(
                child: InkWell(
                  onTap: () => context.push('/group/$groupId/game/$gameId'),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.base),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: theme.textTheme.headlineMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (pendingDuesCount > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text(
                                      '$pendingDuesCount Pending',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onErrorContainer,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          formattedTime,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                venue,
                                style: theme.textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '$confirmedCount / $capacity players',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.payments_outlined, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  costLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (myRsvpStatusLabel.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: myRsvpColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.full),
                                  border: Border.all(color: myRsvpColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  myRsvpStatusLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: myRsvpColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Unanswered',
                                style: (theme.textTheme.labelSmall ?? const TextStyle()).copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
