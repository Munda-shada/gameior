import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/features/notifications/data/notifications_repository.dart';
import 'package:gameior/features/notifications/domain/notification_model.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'notifications_providers.g.dart';

@riverpod
class Notifications extends _$Notifications {
  @override
  Future<List<AppNotification>> build() async {
    final client = ref.watch(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return [];
    return ref.watch(notificationsRepositoryProvider).fetchNotifications(userId);
  }

  Future<void> markRead(String notificationId) async {
    await ref.read(notificationsRepositoryProvider).markAsRead(notificationId);
    ref.invalidateSelf();
    ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllRead() async {
    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;
    await ref.read(notificationsRepositoryProvider).markAllAsRead(userId);
    ref.invalidateSelf();
    ref.invalidate(unreadNotificationCountProvider);
  }
}

@riverpod
Stream<int> unreadNotificationCount(UnreadNotificationCountRef ref) {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) return Stream.value(0);

  Future<int> fetchCount() async {
    final response = await client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .isFilter('read_at', null);
    return (response as List).length;
  }

  final controller = StreamController<int>();

  // Initial load
  fetchCount().then((count) {
    if (!controller.isClosed) {
      controller.add(count);
    }
  }).catchError((e) {
    if (!controller.isClosed) {
      controller.add(0);
    }
  });

  // Supabase realtime channel listener
  final channel = client
      .channel('notifications_count_channel')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: userId,
        ),
        callback: (payload) async {
          try {
            final count = await fetchCount();
            if (!controller.isClosed) {
              controller.add(count);
            }
          } catch (e) {
            print('Error updating unread count on change: $e');
          }
        },
      );

  channel.subscribe();

  ref.onDispose(() {
    channel.unsubscribe();
    controller.close();
  });

  return controller.stream;
}
