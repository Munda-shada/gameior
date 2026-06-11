import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/domain/profile.dart';
import 'package:gameior/core/exceptions/app_exception.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
});

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  Future<Profile?> fetchProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Profile.fromJson(response);
  }

  Future<void> saveProfile({
    required String userId,
    required String displayName,
    required String? phone,
    required String emoji,
  }) async {
    await _client.from('profiles').upsert({
      'id':                  userId,
      'display_name':        displayName,
      'phone':               phone,
      'emoji':               emoji,
      'is_profile_complete': true,
      'updated_at':          DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateNotificationPreferences({
    required String userId,
    required bool notifGameReminders,
    required bool notifWaitlistPromotions,
    required bool notifPaymentDues,
    required bool notifMatchdayLineups,
    required String notifDeliveryMode,
  }) async {
    await _client.from('profiles').update({
      'notif_game_reminders': notifGameReminders,
      'notif_waitlist_promotions': notifWaitlistPromotions,
      'notif_payment_dues': notifPaymentDues,
      'notif_matchday_lineups': notifMatchdayLineups,
      'notif_delivery_mode': notifDeliveryMode,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> deleteAccount() async {
    try {
      await _client.functions.invoke('delete_account');
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchHostedGroupsWithCoHosts(String userId) async {
    final groups = await _client
        .from('groups')
        .select('id, name')
        .eq('host_id', userId);

    final List<Map<String, dynamic>> results = [];
    for (final g in (groups as List)) {
      final coHostsResponse = await _client
          .from('group_members')
          .select('id, user_id, profiles:user_id(display_name)')
          .eq('group_id', g['id'])
          .eq('role', 'co_host')
          .eq('status', 'active');
      
      final coHosts = (coHostsResponse as List).map((row) {
        final profile = row['profiles'] as Map?;
        return {
          'user_id': row['user_id'] as String,
          'display_name': profile?['display_name'] as String? ?? 'Unknown',
        };
      }).toList();

      results.add({
        'id': g['id'] as String,
        'name': g['name'] as String,
        'co_hosts': coHosts,
      });
    }
    return results;
  }

  Future<void> updateUpiId({
    required String userId,
    required String? upiId,
  }) async {
    await _client.from('profiles').update({
      'upi_id': upiId,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<Map<String, dynamic>> fetchGlobalUserStats(String userId) async {
    // 1. Fetch user's active memberships to get group IDs
    final memberships = await _client
        .from('group_members')
        .select('group_id')
        .eq('user_id', userId)
        .eq('status', 'active');
    
    final groupIds = (memberships as List).map((m) => m['group_id'] as String).toList();
    if (groupIds.isEmpty) {
      return {
        'gamesPlayed': 0,
        'attendancePct': 0.0,
        'groupsCount': 0,
        'upcomingGames': 0,
      };
    }

    // 2. Fetch completed games count in those groups
    final completedGames = await _client
        .from('games')
        .select('id')
        .inFilter('group_id', groupIds)
        .eq('status', 'completed');
    
    final totalCompletedGames = (completedGames as List).length;

    // 3. Fetch count of RSVPs where user attended completed games
    int playedCount = 0;
    if (totalCompletedGames > 0) {
      final rsvpsResponse = await _client
          .from('rsvps')
          .select('game_id, games(status)')
          .eq('user_id', userId)
          .inFilter('status', ['yes', 'guest']);
      
      playedCount = (rsvpsResponse as List).where((r) {
        final game = r['games'] as Map?;
        return game != null && game['status'] == 'completed';
      }).length;
    }

    final attendancePct = totalCompletedGames > 0
        ? (playedCount / totalCompletedGames) * 100.0
        : 0.0;

    // 4. Fetch count of upcoming games where user RSVP'd yes or maybe
    final upcomingRsvps = await _client
        .from('rsvps')
        .select('game_id, games(status)')
        .eq('user_id', userId)
        .inFilter('status', ['yes', 'maybe']);
    
    final upcomingCount = (upcomingRsvps as List).where((r) {
      final game = r['games'] as Map?;
      return game != null && game['status'] == 'upcoming';
    }).length;

    return {
      'gamesPlayed': playedCount,
      'attendancePct': attendancePct,
      'groupsCount': groupIds.length,
      'upcomingGames': upcomingCount,
    };
  }
}