import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/core/exceptions/app_exception.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository(ref.watch(supabaseClientProvider));
});

class SessionsRepository {
  final SupabaseClient _client;
  SessionsRepository(this._client);

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<Map<String, dynamic>> fetchGame(String gameId) async {
    final response = await _client
        .from('games')
        .select('''
          *,
          groups (id, name, default_upi_id),
          game_cost_items (*),
          rsvps (*, profiles:user_id (id, display_name, emoji)),
          payment_dues (*),
          game_completion (*)
        ''')
        .eq('id', gameId)
        .single();
    return response;
  }

  Future<void> lockRsvp(String gameId, bool isLocked) async {
    await _client.from('games').update({'rsvp_locked': isLocked}).eq('id', gameId);
  }

  Future<void> cancelGame(String gameId) async {
    await _client.from('games').update({'status': 'cancelled'}).eq('id', gameId);
  }

  Future<void> completeGameDirect(String gameId) async {
    await _client.from('games').update({'status': 'completed'}).eq('id', gameId);
  }

  Future<Map<String, dynamic>?> fetchRsvp(String gameId, String userId) async {
    final response = await _client
        .from('rsvps')
        .select('status, waitlist_position, guest_count, user_is_playing')
        .eq('game_id', gameId)
        .eq('user_id', userId)
        .maybeSingle();
    return response;
  }

  Future<void> submitPayment({
    required String gameId,
    required String? dueId,
    required String utr,
    required RsvpStatus rsvpStatus,
    int guestCount = 0,
    bool userIsPlaying = true,
    required int amountPaise,
    required String paymentOwnerId,
    required String groupId,
  }) async {
    final userId = _client.auth.currentUser!.id;

    // 1. Submit RSVP via Edge Function (atomic capacity check & database transaction)
    final rsvpResult = await submitRsvp(
      gameId: gameId,
      status: rsvpStatus,
      guestCount: guestCount,
      userIsPlaying: userIsPlaying,
    );

    final finalStatus = rsvpResult['status'] as String?;
    if (finalStatus == 'waitlist') {
      // If the player got waitlisted, they don't have an unpaid due to submit a UTR for.
      return;
    }

    // 2. Upsert Payment Due with UTR and pending_verification
    String? activeDueId = dueId;
    if (activeDueId == null || activeDueId.isEmpty) {
      final dues = await _client
          .from('payment_dues')
          .select('id')
          .eq('game_id', gameId)
          .eq('player_id', userId)
          .eq('status', 'unpaid')
          .maybeSingle();
      activeDueId = dues?['id'] as String?;
    }

    if (activeDueId != null && activeDueId.isNotEmpty) {
      await _client.from('payment_dues').update({
        'utr_reference': utr,
        'status': 'pending_verification',
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
        'amount_paise': amountPaise,
      }).eq('id', activeDueId);
    } else {
      await _client.from('payment_dues').upsert({
        'game_id': gameId,
        'group_id': groupId,
        'player_id': userId,
        'payment_owner_id': paymentOwnerId,
        'amount_paise': amountPaise,
        'utr_reference': utr,
        'status': 'pending_verification',
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<Map<String, dynamic>> submitRsvp({
    required String gameId,
    required RsvpStatus status,
    int guestCount = 0,
    bool userIsPlaying = true,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'rsvp_update',
        body: {
          'game_id': gameId,
          'status': status.name,
          'guest_count': guestCount,
          'user_is_playing': userIsPlaying,
        },
      );
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }
  }

  Future<Map<String, dynamic>> completeGame({
    required String gameId,
    required int totalCostPaise,
    required bool chargeAllRsvped,
    required List<String> attendedPlayerIds,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'complete_game',
        body: {
          'game_id': gameId,
          'total_cost_paise': totalCostPaise,
          'charge_all_rsvped': chargeAllRsvped,
          'attended_player_ids': attendedPlayerIds,
        },
      );
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }
  }

  Future<Map<String, dynamic>> updateGameCompletion({
    required String gameId,
    required int totalCostPaise,
    required bool chargeAllRsvped,
    required List<String> attendedPlayerIds,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'update_game_completion',
        body: {
          'game_id': gameId,
          'total_cost_paise': totalCostPaise,
          'charge_all_rsvped': chargeAllRsvped,
          'attended_player_ids': attendedPlayerIds,
        },
      );
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }
  }
}
