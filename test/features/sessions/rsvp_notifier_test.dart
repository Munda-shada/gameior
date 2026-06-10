import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gameior/features/sessions/application/rsvp_notifier.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/models/enums.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late MockSessionsRepository mockRepo;
  late ProviderContainer container;
  const gameId = 'game-123';
  const userId = 'user-456';

  setUp(() {
    mockRepo = MockSessionsRepository();
    
    // Default mock behavior
    when(() => mockRepo.currentUserId).thenReturn(userId);
    
    container = ProviderContainer(
      overrides: [
        sessionsRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('MyRsvpNotifier', () {
    test('initializes with unanswered when no RSVP is found in DB', () async {
      when(() => mockRepo.fetchRsvp(gameId, userId))
          .thenAnswer((_) async => null);

      // Listen to provider
      final subscription = container.listen(
        myRsvpNotifierProvider(gameId),
        (previous, next) {},
      );

      // Expect loading state initially
      expect(container.read(myRsvpNotifierProvider(gameId)), const AsyncLoading<RsvpState>());

      // Wait for future
      final state = await container.read(myRsvpNotifierProvider(gameId).future);

      expect(state.status, RsvpStatus.unanswered);
      expect(state.guestCount, 0);
      expect(state.userIsPlaying, true);
      expect(state.isUpdating, false);
      expect(state.error, null);

      subscription.close();
    });

    test('initializes with correct state when RSVP is found in DB', () async {
      when(() => mockRepo.fetchRsvp(gameId, userId)).thenAnswer((_) async => {
            'status': 'yes',
            'waitlist_position': null,
            'guest_count': 2,
            'user_is_playing': true,
          });

      final subscription = container.listen(
        myRsvpNotifierProvider(gameId),
        (previous, next) {},
      );

      final state = await container.read(myRsvpNotifierProvider(gameId).future);

      expect(state.status, RsvpStatus.yes);
      expect(state.guestCount, 2);
      expect(state.userIsPlaying, true);
      expect(state.waitlistPosition, null);

      subscription.close();
    });

    test('updateRsvp performs optimistic update and resolves to final state on success', () async {
      // Setup initial state
      when(() => mockRepo.fetchRsvp(gameId, userId)).thenAnswer((_) async => {
            'status': 'unanswered',
            'waitlist_position': null,
            'guest_count': 0,
            'user_is_playing': true,
          });

      final notifier = container.read(myRsvpNotifierProvider(gameId).notifier);
      await container.read(myRsvpNotifierProvider(gameId).future); // Wait for build

      // Mock repository submitRsvp response
      when(() => mockRepo.submitRsvp(
            gameId: gameId,
            status: RsvpStatus.yes,
            guestCount: 1,
            userIsPlaying: true,
          )).thenAnswer((_) async => {
            'status': 'yes',
            'waitlist_position': null,
          });

      // Verify that after calling updateRsvp, the state transitions
      final future = notifier.updateRsvp(
        status: RsvpStatus.yes,
        guestCount: 1,
        userIsPlaying: true,
      );

      // Check optimistic state immediately
      final optimisticState = container.read(myRsvpNotifierProvider(gameId)).value;
      expect(optimisticState?.status, RsvpStatus.yes);
      expect(optimisticState?.guestCount, 1);
      expect(optimisticState?.isUpdating, true);

      await future;

      // Check final state
      final finalState = container.read(myRsvpNotifierProvider(gameId)).value;
      expect(finalState?.status, RsvpStatus.yes);
      expect(finalState?.guestCount, 1);
      expect(finalState?.isUpdating, false);
      expect(finalState?.error, null);
    });

    test('updateRsvp performs optimistic update and rolls back to previous state on failure', () async {
      // Setup initial state
      when(() => mockRepo.fetchRsvp(gameId, userId)).thenAnswer((_) async => {
            'status': 'yes',
            'waitlist_position': null,
            'guest_count': 0,
            'user_is_playing': true,
          });

      final notifier = container.read(myRsvpNotifierProvider(gameId).notifier);
      await container.read(myRsvpNotifierProvider(gameId).future); // Wait for build

      // Mock repository submitRsvp to throw an error
      when(() => mockRepo.submitRsvp(
            gameId: gameId,
            status: RsvpStatus.no,
            guestCount: 0,
            userIsPlaying: true,
          )).thenThrow(Exception('Network timeout'));

      // Verify that calling updateRsvp throws and rolls back
      try {
        await notifier.updateRsvp(
          status: RsvpStatus.no,
          guestCount: 0,
          userIsPlaying: true,
        );
        fail('Expected exception');
      } catch (e) {
        expect(e.toString(), contains('Network timeout'));
      }

      // Check that state rolled back to yes
      final rolledBackState = container.read(myRsvpNotifierProvider(gameId)).value;
      expect(rolledBackState?.status, RsvpStatus.yes);
      expect(rolledBackState?.guestCount, 0);
      expect(rolledBackState?.isUpdating, false);
      expect(rolledBackState?.error, contains('Network timeout'));
    });
  });
}
