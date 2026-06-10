import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
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
        default:
          context.push('/group/$groupId');
      }
    } else {
      context.push('/home/feed');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
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
            child: Text('Error loading notifications: $err', style: const TextStyle(color: AppColors.destructive)),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: AppSpacing.base),
                  Text('No notifications yet', style: AppTextStyles.bodyLarge),
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
                      tileColor: isUnread ? AppColors.primaryMuted.withOpacity(0.15) : null,
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isUnread ? AppColors.primary.withOpacity(0.1) : AppColors.border.withOpacity(0.3),
                        ),
                        child: Icon(
                          isUnread ? Icons.notifications_active : Icons.notifications_none,
                          color: isUnread ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      title: Text(
                        item.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                          color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            item.body,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formattedTime,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                      trailing: isUnread
                          ? Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
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
