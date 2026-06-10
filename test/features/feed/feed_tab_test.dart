import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gameior/features/feed/presentation/feed_tab.dart';
import 'package:gameior/features/feed/application/feed_providers.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

import 'package:gameior/features/profile/domain/profile.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}
class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}
class MockUser extends Mock implements supabase.User {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');
  });

  group('FeedTab Widget Test', () {
    testWidgets('renders greeting header and empty feed state when there are no games, dues, or announcements', (WidgetTester tester) async {
      final mockProfile = Profile(
        id: 'user-123',
        displayName: 'Alice',
        emoji: '🏸',
        isProfileComplete: true,
        createdAt: DateTime.parse('2026-06-10T12:00:00Z'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockClient),
            currentUserProvider.overrideWith((ref) => Future.value(mockProfile)),
            feedDuesSummaryProvider.overrideWith((ref) => const FeedDuesSummary(
                  totalPaise: 0,
                  groupCount: 0,
                  groupBreakdown: [],
                )),
            feedUpcomingGamesProvider.overrideWith((ref) => Future.value([])),
            feedAnnouncementsProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: FeedTab(),
            ),
          ),
        ),
      );

      // Let the initial loading finish
      await tester.pump();

      // Verify greeting display name is rendered
      expect(find.text('Alice'), findsOneWidget);

      // Verify empty feed state message is rendered
      expect(find.text('Your court is empty'), findsOneWidget);
    });
  });
}
