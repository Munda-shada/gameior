import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gameior/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum GroupTab {
  home,
  sessions,
  members,
  payments,
  settings,
}

final fcmServiceProvider = Provider<FcmService>((ref) {
  return FcmService(ref);
});

void handleNotificationTap(RemoteMessage message, Ref ref) {
  final data = message.data;
  final router = ref.read(appRouterProvider);

  switch (data['type']) {
    case 'game_reminder':
    case 'waitlist_promotion':
      router.push('/group/${data['group_id']}/game/${data['game_id']}');
    case 'payment_submitted':
    case 'payment_verified':
      router.push('/group/${data['group_id']}?tab=${GroupTab.payments.index}');
    case 'join_request':
      router.push('/group/${data['group_id']}?tab=${GroupTab.members.index}');
    case 'game_cancelled':
      router.push('/group/${data['group_id']}?tab=${GroupTab.sessions.index}');
    default:
      router.push('/home/feed');
  }
}

class FcmService {
  final Ref _ref;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  FcmService(this._ref);

  Future<void> init() async {
    // 1. Request Permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permissions');
    }

    // 2. Initialize Flutter Local Notifications for foreground notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        // Handle foreground notification click
      },
    );

    // 3. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        _showLocalNotification(notification);
      }
    });

    // 4. Handle background / terminated app open on notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleNotificationTap(message, _ref);
    });

    // Initial message tap if app was terminated and opened by notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage, _ref);
    }

    // 5. Setup Token Refresh Listener
    _messaging.onTokenRefresh.listen((token) async {
      await _syncTokenToSupabase(token);
    });

    // Sync token initially if user is logged in
    final currentUser = _ref.read(supabaseClientProvider).auth.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseCrashlytics.instance.setUserIdentifier(currentUser.id);
      } catch (e) {
        print("⚠️ Failed to set user identifier in Crashlytics: $e");
      }
      final token = await _messaging.getToken();
      if (token != null) {
        await _syncTokenToSupabase(token);
      }
    }

    // Listen to login/logout changes to sync token
    _ref.listen<AsyncValue<AuthState>>(authStateProvider, (previous, next) async {
      final user = next.valueOrNull?.session?.user;
      if (user != null) {
        try {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
        } catch (e) {
          print("⚠️ Failed to set user identifier in Crashlytics: $e");
        }
        final token = await _messaging.getToken();
        if (token != null) {
          await _syncTokenToSupabase(token);
        }
      }
    });
  }

  Future<void> _showLocalNotification(RemoteNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'gameior_channel',
      'Gameior Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  Future<void> _syncTokenToSupabase(String token) async {
    final client = _ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final deviceId = Platform.isAndroid ? 'android-device' : 'ios-device';
      final platform = Platform.isAndroid ? 'android' : 'ios';

      await client.from('notification_tokens').upsert({
        'user_id': user.id,
        'fcm_token': token,
        'device_id': deviceId,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      print('FCM token synced successfully to Supabase');
    } catch (e) {
      print('Error syncing FCM token: $e');
    }
  }
}