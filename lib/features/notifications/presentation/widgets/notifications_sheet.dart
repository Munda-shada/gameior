import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/notifications/application/notifications_providers.dart';
import 'package:gameior/features/notifications/domain/notification_model.dart';
import 'package:gameior/core/firebase/fcm_service.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  void _handleNotificationClick(BuildContext context, WidgetRef ref, AppNotification notification) {
    // 1. Mark as read
    if (notification.readAt == null) {
      ref.read(notificationsProvider.notifier).markRead(notification.id);
    }

    // 2. Dismiss sheet
    Navigator.pop(context);

    // 3. Deep link routing
    final payload = notification.payload;
    final type = payload['type']?.toString();
    final groupId = payload['group_id']?.toString();
    final gameId = payload['game_id']?.toString();

    if (groupId != null && groupId.isNotEmpty) {
      switch (type) {
        case 'game_reminder':
        case 'waitlist_promotion':
        case 'game_created':
          if (gameId != null && gameId.isNotEmpty) {
            context.push('/group/$groupId/game/$gameId');
          } else {
            context.push('/group/$groupId');
          }
        case 'payment_submitted':
        case 'payment_approved':
        case 'payment_rejected':
        case 'dues_generated':
        case 'dues_reminder':
          context.push('/group/$groupId?tab=${GroupTab.payments.index}');
        case 'join_request':
        case 'join_approved':
        case 'join_rejected':
          context.push('/group/$groupId?tab=${GroupTab.members.index}');
        case 'game_cancelled':
          context.push('/group/$groupId?tab=${GroupTab.sessions.index}');
        default:
          context.push('/group/$groupId');
      }
    } else {
      context.push('/home/feed');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: notificationsAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Text(
              'Error loading notifications: $err',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text(
                    'No notifications yet',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          final hasUnread = list.any((n) => n.readAt == null);

          return Column(
            children: [
              // Header actions
              if (hasUnread)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                      label: const Text('Mark all as read'),
                      onPressed: () {
                        ref.read(notificationsProvider.notifier).markAllRead();
                      },
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final isUnread = item.readAt == null;
                    final formattedTime = DateFormat('MMM d, h:mm a').format(item.createdAt.toLocal());

                    return ListTile(
                      onTap: () => _handleNotificationClick(context, ref, item),
                      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: 4),
                      tileColor: isUnread ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnread
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        child: Icon(
                          isUnread ? Icons.notifications_active : Icons.notifications_none,
                          color: isUnread ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          color: isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isUnread ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      trailing: isUnread
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
