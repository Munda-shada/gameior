import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/features/sessions/data/sessions_repository.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

part 'rsvp_notifier.freezed.dart';
part 'rsvp_notifier.g.dart';

@freezed
abstract class RsvpState with _$RsvpState {
  const factory RsvpState({
    required RsvpStatus status,
    int? waitlistPosition,
    required int guestCount,
    @Default(true) bool userIsPlaying,
    @Default(false) bool isUpdating,
    String? error,
  }) = _RsvpState;
}

@riverpod
class MyRsvpNotifier extends _$MyRsvpNotifier {
  @override
  Future<RsvpState> build(String gameId) async {
    final repo = ref.watch(sessionsRepositoryProvider);
    final userId = repo.currentUserId;
    if (userId == null) {
      return const RsvpState(
        status: RsvpStatus.unanswered,
        guestCount: 0,
      );
    }
    
    // Fetch this user's current RSVP
    final response = await repo.fetchRsvp(gameId, userId);

    if (response == null) {
      return const RsvpState(
        status: RsvpStatus.unanswered,
        guestCount: 0,
      );
    }

    final statusStr = response['status'] as String?;
    final waitlistPos = response['waitlist_position'] as int?;
    final guestCount = response['guest_count'] as int? ?? 0;
    final userIsPlaying = response['user_is_playing'] as bool? ?? true;

    final status = RsvpStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => RsvpStatus.unanswered,
    );

    return RsvpState(
      status: status,
      waitlistPosition: waitlistPos,
      guestCount: guestCount,
      userIsPlaying: userIsPlaying,
    );
  }

  Future<void> updateRsvp({
    required RsvpStatus status,
    int guestCount = 0,
    bool userIsPlaying = true,
  }) async {
    // 1. Store the previous state to support rollbacks on failure
    final previousState = state.valueOrNull;
    if (previousState == null) return;

    // 2. Optimistic Update
    state = AsyncData(previousState.copyWith(
      status: status,
      guestCount: guestCount,
      userIsPlaying: userIsPlaying,
      isUpdating: true,
      error: null,
    ));

    try {
      final repo = ref.read(sessionsRepositoryProvider);
      final result = await repo.submitRsvp(
        gameId: gameId,
        status: status,
        guestCount: guestCount,
        userIsPlaying: userIsPlaying,
      );

      final finalStatusStr = result['status'] as String?;
      final waitlistPos = result['waitlist_position'] as int?;

      final finalStatus = RsvpStatus.values.firstWhere(
        (e) => e.name == finalStatusStr,
        orElse: () => status,
      );

      state = AsyncData(RsvpState(
        status: finalStatus,
        waitlistPosition: waitlistPos,
        guestCount: guestCount,
        userIsPlaying: userIsPlaying,
        isUpdating: false,
      ));
    } catch (e) {
      // 3. Rollback State on Exception
      state = AsyncData(previousState.copyWith(
        isUpdating: false,
        error: e.toString(),
      ));
      rethrow;
    }
  }
}
