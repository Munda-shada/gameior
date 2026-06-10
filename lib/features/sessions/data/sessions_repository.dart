import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/shared/models/enums.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>((ref) {
  return SessionsRepository(ref.watch(supabaseClientProvider));
});

class SessionsRepository {
  final SupabaseClient _client;
  SessionsRepository(this._client);

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

    // 1. Upsert RSVP status
    await _client.from('rsvps').upsert({
      'game_id': gameId,
      'user_id': userId,
      'status': rsvpStatus.name,
      'guest_count': guestCount,
      'user_is_playing': userIsPlaying,
      'responded_at': DateTime.now().toUtc().toIso8601String(),
    });

    // 2. Upsert Payment Due with UTR and pending_verification
    if (dueId != null && dueId.isNotEmpty) {
      await _client.from('payment_dues').update({
        'utr_reference': utr,
        'status': 'pending_verification',
        'submitted_at': DateTime.now().toUtc().toIso8601String(),
        'amount_paise': amountPaise,
      }).eq('id', dueId);
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
    final userId = _client.auth.currentUser!.id;
    
    try {
      // 1. Attempt calling Edge Function
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
    } catch (e) {
      // 2. Fallback: Client-Side Transaction Mock
      try {
        // Step 1: Fetch game details
        final game = await _client.from('games').select().eq('id', gameId).single();
        final maxCapacity = (game['max_capacity'] as num).toInt();
        final paymentModel = game['payment_model'] as String;
        final costPaise = (game['cost_paise'] as num).toInt();
        final paymentOwnerId = game['payment_owner_id'] as String;
        final groupId = game['group_id'] as String;

        if (game['status'] != 'upcoming') throw Exception('Session is not upcoming');
        if (game['rsvp_locked'] == true) throw Exception('RSVPs are locked');
        if (game['rsvp_deadline'] != null) {
          final deadline = DateTime.parse(game['rsvp_deadline'] as String);
          if (DateTime.now().toUtc().isAfter(deadline)) throw Exception('RSVP deadline has passed');
        }

        // Step 2: Fetch all RSVPs for this game
        final allRsvps = await _client.from('rsvps').select().eq('game_id', gameId);
        
        Map<String, dynamic>? existingRsvp;
        for (var r in allRsvps) {
          if (r['user_id'] == userId) {
            existingRsvp = r;
            break;
          }
        }
        final String? oldStatus = existingRsvp?['status'] as String?;

        // Step 3: Calculate confirmed slots excluding caller
        var confirmedExcludingCaller = 0;
        for (var r in allRsvps) {
          if (r['user_id'] == userId) continue;
          final rStatus = r['status'] as String;
          if (rStatus == 'yes' || rStatus == 'guest') {
            final isPlaying = r['user_is_playing'] as bool? ?? true;
            final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
            confirmedExcludingCaller += (isPlaying ? 1 : 0) + guests;
          }
        }

        // Step 4: Calculate new slots occupied by caller
        final newSlots = (status == RsvpStatus.yes || status == RsvpStatus.guest)
            ? ((userIsPlaying ? 1 : 0) + guestCount)
            : 0;

        String finalStatus = status.name;
        int? waitlistPosition;

        // Step 5: Capacity / Waitlist check
        if (status == RsvpStatus.yes || status == RsvpStatus.guest) {
          final available = maxCapacity - confirmedExcludingCaller;
          if (newSlots > available) {
            finalStatus = 'waitlist';
            
            // Get waitlist count
            final waitlistCount = allRsvps.where((r) => r['status'] == 'waitlist').length;
            waitlistPosition = waitlistCount + 1;
          }
        }

        // Step 6: Upsert the RSVP
        final rsvpData = {
          'game_id': gameId,
          'user_id': userId,
          'status': finalStatus,
          'guest_count': guestCount,
          'user_is_playing': userIsPlaying,
          'waitlist_position': waitlistPosition,
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        };

        if (existingRsvp != null) {
          await _client.from('rsvps').update(rsvpData).eq('game_id', gameId).eq('user_id', userId);
        } else {
          await _client.from('rsvps').insert(rsvpData);
        }

        // Step 7: Handle prepaid dues
        if (paymentModel == 'prepaid') {
          if (finalStatus == 'yes' || finalStatus == 'guest') {
            final totalCost = costPaise * newSlots;
            await _client.from('payment_dues').upsert({
              'game_id': gameId,
              'group_id': groupId,
              'player_id': userId,
              'payment_owner_id': paymentOwnerId,
              'amount_paise': totalCost,
              'status': 'unpaid',
            });
          } else if (finalStatus == 'no' || finalStatus == 'maybe' || finalStatus == 'unanswered' || finalStatus == 'waitlist') {
            await _client
                .from('payment_dues')
                .delete()
                .eq('game_id', gameId)
                .eq('player_id', userId)
                .eq('status', 'unpaid');
          }
        }

        // Step 8: Waitlist promotion if caller was confirmed but is now leaving
        final wasConfirmed = oldStatus == 'yes' || oldStatus == 'guest';
        final isLeaving = finalStatus == 'no' || finalStatus == 'maybe' || finalStatus == 'unanswered' || finalStatus == 'waitlist';

        if (wasConfirmed && isLeaving) {
          final oldSlots = ((existingRsvp?['user_is_playing'] as bool? ?? true) ? 1 : 0) +
              ((existingRsvp?['guest_count'] as num?)?.toInt() ?? 0);
          
          await _promoteFromWaitlist(gameId, oldSlots, paymentModel, costPaise, paymentOwnerId, groupId);
        }

        return {
          'status': finalStatus,
          'waitlist_position': waitlistPosition,
          'message': finalStatus == 'waitlist' ? 'Added to waitlist.' : 'RSVP updated.'
        };
      } catch (err) {
        return {'error': 'rsvp_failed', 'message': err.toString()};
      }
    }
  }

  Future<void> _promoteFromWaitlist(
    String gameId,
    int slotsFreed,
    String paymentModel,
    int costPaise,
    String paymentOwnerId,
    String groupId,
  ) async {
    // 1. Fetch first N waitlisted RSVPs ordered by waitlist_position
    final waitlisted = await _client
        .from('rsvps')
        .select()
        .eq('game_id', gameId)
        .eq('status', 'waitlist')
        .order('waitlist_position', ascending: true)
        .limit(slotsFreed);

    final list = waitlisted as List;
    for (var r in list) {
      final wUserId = r['user_id'] as String;
      final isPlaying = r['user_is_playing'] as bool? ?? true;
      final guests = (r['guest_count'] as num?)?.toInt() ?? 0;
      final neededSlots = (isPlaying ? 1 : 0) + guests;

      // Update waitlisted player to YES
      await _client.from('rsvps').update({
        'status': 'yes',
        'waitlist_position': null,
        'responded_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('game_id', gameId).eq('user_id', wUserId);

      // Create pre-paid dues
      if (paymentModel == 'prepaid') {
        final totalCost = costPaise * neededSlots;
        await _client.from('payment_dues').upsert({
          'game_id': gameId,
          'group_id': groupId,
          'player_id': wUserId,
          'payment_owner_id': paymentOwnerId,
          'amount_paise': totalCost,
          'status': 'unpaid',
        });
      }
    }

    // 2. Reorder remaining waitlist positions
    final remaining = await _client
        .from('rsvps')
        .select()
        .eq('game_id', gameId)
        .eq('status', 'waitlist')
        .order('waitlist_position', ascending: true);

    final remList = remaining as List;
    for (int i = 0; i < remList.length; i++) {
      final item = remList[i];
      await _client
          .from('rsvps')
          .update({'waitlist_position': i + 1})
          .eq('game_id', gameId)
          .eq('user_id', item['user_id'] as String);
    }
  }

  Future<Map<String, dynamic>> completeGame({
    required String gameId,
    required int totalCostPaise,
    required bool chargeAllRsvped,
    required List<String> attendedPlayerIds,
  }) async {
    final callerId = _client.auth.currentUser!.id;
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
    } catch (e) {
      try {
        final game = await _client.from('games').select().eq('id', gameId).single();
        final groupId = game['group_id'] as String;
        final paymentOwnerId = game['payment_owner_id'] as String;
        final paymentModel = game['payment_model'] as String;
        final currentStatus = game['status'] as String;

        if (paymentOwnerId != callerId) {
          throw Exception('Only the game creator can complete this game.');
        }
        if (currentStatus != 'upcoming') {
          throw Exception('Game is not upcoming');
        }
        if (paymentModel != 'postpaid') {
          throw Exception('Game is not postpaid');
        }

        List<String> chargedPlayerIds;
        if (chargeAllRsvped) {
          final rsvps = await _client
              .from('rsvps')
              .select('user_id')
              .eq('game_id', gameId)
              .inFilter('status', ['yes', 'guest']);
          chargedPlayerIds = (rsvps as List)
              .map((r) => r['user_id'] as String)
              .toList();
        } else {
          chargedPlayerIds = attendedPlayerIds;
        }

        if (chargedPlayerIds.isEmpty) {
          throw Exception('No players selected to be charged.');
        }

        final playerCount = chargedPlayerIds.length;
        final perHeadPaise = (totalCostPaise / playerCount).ceil();

        await _client.from('game_completion').insert({
          'game_id': gameId,
          'completed_by': callerId,
          'total_cost_paise': totalCostPaise,
          'charge_all_rsvped': chargeAllRsvped,
          'attended_player_ids': attendedPlayerIds,
          'per_head_paise': perHeadPaise,
        });

        for (final playerId in chargedPlayerIds) {
          await _client.from('payment_dues').upsert({
            'game_id': gameId,
            'group_id': groupId,
            'player_id': playerId,
            'payment_owner_id': paymentOwnerId,
            'amount_paise': perHeadPaise,
            'status': 'unpaid',
          });
        }

        await _client.from('games').update({
          'status': 'completed',
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('id', gameId);

        return {
          'game_status': 'completed',
          'player_count': playerCount,
          'per_head_paise': perHeadPaise,
          'total_cost_paise': totalCostPaise,
          'dues_created': playerCount,
        };
      } catch (err) {
        return {'error': 'completion_failed', 'message': err.toString()};
      }
    }
  }

  Future<Map<String, dynamic>> updateGameCompletion({
    required String gameId,
    required int totalCostPaise,
    required bool chargeAllRsvped,
    required List<String> attendedPlayerIds,
  }) async {
    final callerId = _client.auth.currentUser!.id;
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
    } catch (e) {
      try {
        final game = await _client.from('games').select().eq('id', gameId).single();
        final groupId = game['group_id'] as String;
        final paymentOwnerId = game['payment_owner_id'] as String;
        final paymentModel = game['payment_model'] as String;
        final currentStatus = game['status'] as String;

        if (paymentOwnerId != callerId) {
          throw Exception('Only the game creator can edit completion details.');
        }
        if (currentStatus != 'completed') {
          throw Exception('Game is not completed');
        }
        if (paymentModel != 'postpaid') {
          throw Exception('Game is not postpaid');
        }

        final duesResponse = await _client
            .from('payment_dues')
            .select('status, player_id')
            .eq('game_id', gameId);
        
        final allDues = duesResponse as List;
        final unsettledCount = allDues.where((d) => d['status'] != 'paid').length;
        if (unsettledCount == 0 && allDues.isNotEmpty) {
          throw Exception('This game\'s completion is locked because all dues have been settled.');
        }

        List<String> chargedPlayerIds;
        if (chargeAllRsvped) {
          final rsvps = await _client
              .from('rsvps')
              .select('user_id')
              .eq('game_id', gameId)
              .inFilter('status', ['yes', 'guest']);
          chargedPlayerIds = (rsvps as List)
              .map((r) => r['user_id'] as String)
              .toList();
        } else {
          chargedPlayerIds = attendedPlayerIds;
        }

        if (chargedPlayerIds.isEmpty) {
          throw Exception('No players selected to be charged.');
        }

        final playerCount = chargedPlayerIds.length;
        final perHeadPaise = (totalCostPaise / playerCount).ceil();

        await _client.from('game_completion').update({
          'total_cost_paise': totalCostPaise,
          'charge_all_rsvped': chargeAllRsvped,
          'attended_player_ids': attendedPlayerIds,
          'per_head_paise': perHeadPaise,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }).eq('game_id', gameId);

        await _client
            .from('payment_dues')
            .update({
              'amount_paise': perHeadPaise,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('game_id', gameId)
            .eq('status', 'unpaid');

        final existingPlayerIds = allDues.map((d) => d['player_id'] as String?).whereType<String>().toSet();
        int duesAddedCount = 0;
        for (final playerId in chargedPlayerIds) {
          if (!existingPlayerIds.contains(playerId)) {
            await _client.from('payment_dues').upsert({
              'game_id': gameId,
              'group_id': groupId,
              'player_id': playerId,
              'payment_owner_id': paymentOwnerId,
              'amount_paise': perHeadPaise,
              'status': 'unpaid',
            });
            duesAddedCount++;
          }
        }

        int duesRemovedCount = 0;
        final listToDelete = allDues
            .where((d) => d['status'] == 'unpaid' && !chargedPlayerIds.contains(d['player_id']))
            .toList();
        for (final item in listToDelete) {
          final pid = item['player_id'] as String;
          await _client
              .from('payment_dues')
              .delete()
              .eq('game_id', gameId)
              .eq('player_id', pid)
              .eq('status', 'unpaid');
          duesRemovedCount++;
        }

        final duesUpdatedCount = allDues.where((d) => d['status'] == 'unpaid' && chargedPlayerIds.contains(d['player_id'])).length;

        return {
          'updated': true,
          'per_head_paise': perHeadPaise,
          'dues_updated': duesUpdatedCount,
          'dues_added': duesAddedCount,
          'dues_removed': duesRemovedCount,
        };
      } catch (err) {
        return {'error': 'update_failed', 'message': err.toString()};
      }
    }
  }
}
