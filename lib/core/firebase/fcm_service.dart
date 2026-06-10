import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gameior/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



enum GroupTab {
  home,
  sessions,
  members,
  payments,
  settings,
}

void handleNotificationTap(RemoteMessage message, Ref ref) {
  final data = message.data;
  final router = ref.read(appRouterProvider);

  switch (data['type']) {
    case 'game_reminder':
    case 'waitlist_promotion':
      router.push('/group/${data['group_id']}/game/${data['game_id']}');
    case 'payment_submitted':
    case 'payment_verified':
      router.push('/group/${data['group_id']}',
        extra: {'initialTab': GroupTab.payments.index});
    case 'join_request':
      router.push('/group/${data['group_id']}',
        extra: {'initialTab': GroupTab.members.index});
    default:
      router.push('/home/feed');
  }
}