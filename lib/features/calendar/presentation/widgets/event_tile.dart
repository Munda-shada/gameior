import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class GameEventTile extends StatelessWidget {
  final Map<String, dynamic> game;
  final String? currentUserId;

  const GameEventTile({
    required this.game,
    required this.currentUserId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rsvps = game['rsvps'] as List<dynamic>? ?? [];
    final myRsvp = rsvps.whereType<Map<String, dynamic>>().firstWhere(
          (r) => r['user_id'] == currentUserId,
          orElse: () => <String, dynamic>{},
        );

    Color dotColor = theme.colorScheme.outline;
    final status = myRsvp['status'];
    if (myRsvp.isNotEmpty) {
      if (status == 'yes' || myRsvp['user_is_playing'] == true) {
        dotColor = theme.colorScheme.primary;
      } else if (status == 'waitlist') {
        dotColor = theme.colorScheme.tertiary;
      }
    }

    final waitlistPos = myRsvp['waitlist_position'];
    final rsvpLocked = game['rsvp_locked'] == true;
    final scheduledAt = game['scheduled_at'] != null 
        ? DateTime.parse(game['scheduled_at'] as String).toLocal() 
        : null;
    final timeString = scheduledAt != null 
        ? DateFormat('MMM d, yyyy • h:mm a').format(scheduledAt) 
        : 'TBD';

    final group = game['groups'] as Map<String, dynamic>? ?? {};
    final groupName = group['name'] ?? 'Unknown Group';
    final sportRaw = group['sport']?.toString() ?? 'sport';
    final sportName = sportRaw.isNotEmpty ? '${sportRaw[0].toUpperCase()}${sportRaw.substring(1)}' : 'Sport';

    final groupId = game['group_id'];
    final gameId = game['id'];
    
    final title = game['title']?.toString() ?? '';
    final displayTitle = title.isNotEmpty ? title : '$sportName Session';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          if (groupId != null && gameId != null) {
            context.push('/group/$groupId/game/$gameId');
          }
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 6, color: dotColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (rsvpLocked)
                            Padding(
                              padding: const EdgeInsets.only(left: AppSpacing.xs),
                              child: Icon(Icons.lock, size: 16, color: theme.colorScheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        timeString,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Icon(Icons.group, size: 16, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              groupName,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (status == 'waitlist' && waitlistPos != null)
                            Container(
                              margin: const EdgeInsets.only(left: AppSpacing.sm),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Waitlist #$waitlistPos',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
