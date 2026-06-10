import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/notifications/application/notifications_providers.dart';
import 'package:gameior/features/notifications/data/notifications_repository.dart';
import 'package:gameior/features/notifications/domain/notification_model.dart';

class MockNotificationsRepository extends Mock implements NotificationsRepository {}
class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}
class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}
class MockUser extends Mock implements supabase.User {}

void main() {
  late MockNotificationsRepository mockRepo;
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late ProviderContainer container;

  final sampleNotifications = [
    AppNotification(
      id: 'n1',
      userId: 'user-123',
      title: 'Waitlist Promotion',
      body: 'You got promoted!',
      payload: const {'type': 'waitlist_promotion'},
      createdAt: DateTime.now(),
    ),
    AppNotification(
      id: 'n2',
      userId: 'user-123',
      title: 'Payment Due',
      body: 'You owe money!',
      payload: const {'type': 'dues_reminder'},
      readAt: DateTime.now(),
      createdAt: DateTime.now(),
    ),
  ];

  setUp(() {
    mockRepo = MockNotificationsRepository();
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');

    container = ProviderContainer(
      overrides: [
        notificationsRepositoryProvider.overrideWithValue(mockRepo),
        supabaseClientProvider.overrideWithValue(mockClient),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Notifications Notifier', () {
    test('fetches notifications successfully', () async {
      when(() => mockRepo.fetchNotifications('user-123'))
          .thenAnswer((_) async => sampleNotifications);

      final result = await container.read(notificationsProvider.future);
      expect(result, sampleNotifications);
      verify(() => mockRepo.fetchNotifications('user-123')).called(1);
    });

    test('markRead calls repository', () async {
      when(() => mockRepo.fetchNotifications('user-123'))
          .thenAnswer((_) async => sampleNotifications);
      when(() => mockRepo.markAsRead('n1')).thenAnswer((_) async {});

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.markRead('n1');

      verify(() => mockRepo.markAsRead('n1')).called(1);
    });

    test('markAllRead calls repository', () async {
      when(() => mockRepo.fetchNotifications('user-123'))
          .thenAnswer((_) async => sampleNotifications);
      when(() => mockRepo.markAllAsRead('user-123')).thenAnswer((_) async {});

      final notifier = container.read(notificationsProvider.notifier);
      await notifier.markAllRead();

      verify(() => mockRepo.markAllAsRead('user-123')).called(1);
    });
  });
}
