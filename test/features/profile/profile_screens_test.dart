import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/domain/profile.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/features/auth/data/auth_repository.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/features/profile/presentation/edit_profile_screen.dart';
import 'package:gameior/features/profile/presentation/delete_account_screen.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}
class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}
class MockUser extends Mock implements supabase.User {}
class MockProfileRepository extends Mock implements ProfileRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockMembersRepository extends Mock implements MembersRepository {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;
  late MockUser mockUser;
  late MockProfileRepository mockProfileRepo;
  late MockAuthRepository mockAuthRepo;
  late MockMembersRepository mockMembersRepo;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockUser = MockUser();
    mockProfileRepo = MockProfileRepository();
    mockAuthRepo = MockAuthRepository();
    mockMembersRepo = MockMembersRepository();

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('user-123');
  });

  group('EditProfileScreen Widget Tests', () {
    testWidgets('renders current profile data and allows change & save', (WidgetTester tester) async {
      final profile = Profile(
        id: 'user-123',
        displayName: 'John Doe',
        phone: '+919999999999',
        emoji: '⚽',
        isProfileComplete: true,
        createdAt: DateTime.now(),
      );

      when(() => mockProfileRepo.saveProfile(
        userId: 'user-123',
        displayName: 'John Smith',
        phone: '+918888888888',
        emoji: '🎾',
      )).thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            currentUserProvider.overrideWith((ref) => profile),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );

      await tester.pump(); // wait for post frame callback

      // Check fields pre-filled
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('9999999999'), findsOneWidget);
      expect(find.text('⚽'), findsOneWidget);

      // Tap emoji to change
      await tester.tap(find.text('⚽'));
      await tester.pumpAndSettle();

      // Check if emoji sheet opened
      expect(find.text('Choose Your Emoji'), findsOneWidget);
      
      // Tap on '🎾' emoji
      await tester.tap(find.text('🎾'));
      await tester.pumpAndSettle();

      // Verify emoji updated on screen
      expect(find.text('🎾'), findsOneWidget);

      // Find fields by type TextFormField
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(2));

      // Change display name and phone number
      await tester.enterText(fields.at(0), 'John Smith');
      await tester.enterText(fields.at(1), '8888888888');

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pump();

      verify(() => mockProfileRepo.saveProfile(
        userId: 'user-123',
        displayName: 'John Smith',
        phone: '+918888888888',
        emoji: '🎾',
      )).called(1);
    });
  });

  group('DeleteAccountScreen Widget Tests', () {
    testWidgets('disallows delete when hosting unresolved groups', (WidgetTester tester) async {
      final hostedGroups = [
        {
          'id': 'g-1',
          'name': 'Active Group',
          'co_hosts': [
            {'user_id': 'co-1', 'display_name': 'CoHost 1'}
          ]
        }
      ];

      when(() => mockProfileRepo.fetchHostedGroupsWithCoHosts('user-123'))
          .thenAnswer((_) async => hostedGroups);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            membersRepositoryProvider.overrideWithValue(mockMembersRepo),
          ],
          child: const MaterialApp(
            home: DeleteAccountScreen(),
          ),
        ),
      );

      await tester.pump(); // trigger future load
      await tester.pump(); // resolve future builders

      // Should show warning about hosted groups
      expect(find.textContaining('Active Group'), findsOneWidget);
      expect(find.text('Transfer Ownership'), findsOneWidget);

      // Permanent delete fields should not be present
      expect(find.text('I understand that my account will be permanently deleted.'), findsNothing);
    });

    testWidgets('allows delete when user has no hosted groups after verification', (WidgetTester tester) async {
      when(() => mockProfileRepo.fetchHostedGroupsWithCoHosts('user-123'))
          .thenAnswer((_) async => []);

      when(() => mockProfileRepo.deleteAccount()).thenAnswer((_) async => {});
      when(() => mockAuthRepo.signOut()).thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(mockSupabaseClient),
            profileRepositoryProvider.overrideWithValue(mockProfileRepo),
            authRepositoryProvider.overrideWithValue(mockAuthRepo),
            membersRepositoryProvider.overrideWithValue(mockMembersRepo),
          ],
          child: const MaterialApp(
            home: DeleteAccountScreen(),
          ),
        ),
      );

      await tester.pump(); // trigger future load
      await tester.pump(); // resolve future builders

      // Should show delete confirmation fields
      expect(find.textContaining('permanently lose your profile'), findsOneWidget);
      
      final checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      final deleteBtnFinder = find.widgetWithText(ElevatedButton, 'Delete Account');
      expect(deleteBtnFinder, findsOneWidget);

      // Initially, delete button should be disabled because checkbox is false and input is empty
      ElevatedButton buttonWidget = tester.widget<ElevatedButton>(deleteBtnFinder);
      expect(buttonWidget.onPressed, isNull);

      // Toggle checkbox
      await tester.tap(checkboxFinder);
      await tester.pumpAndSettle();

      buttonWidget = tester.widget<ElevatedButton>(deleteBtnFinder);
      expect(buttonWidget.onPressed, isNull); // still null because DELETE is not entered

      // Enter 'DELETE' into text field
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pumpAndSettle();

      buttonWidget = tester.widget<ElevatedButton>(deleteBtnFinder);
      expect(buttonWidget.onPressed, isNotNull); // enabled now!

      // Tap delete button
      await tester.tap(deleteBtnFinder);
      await tester.pump();

      verify(() => mockProfileRepo.deleteAccount()).called(1);
      verify(() => mockAuthRepo.signOut()).called(1);
    });
  });
}
