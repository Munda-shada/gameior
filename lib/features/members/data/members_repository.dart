import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/members/domain/member_stats.dart';
import 'package:gameior/shared/models/enums.dart';

final membersRepositoryProvider = Provider<MembersRepository>((ref) {
  return MembersRepository(ref.watch(supabaseClientProvider));
});

class MembersRepository {
  final SupabaseClient _client;
  MembersRepository(this._client);

  /// Fetch active group members
  Future<List<GroupMember>> fetchMembers(String groupId) async {
    final response = await _client
        .from('group_members')
        .select('*, profiles:user_id (display_name, emoji, phone)')
        .eq('group_id', groupId)
        .eq('status', 'active');

    final list = (response as List)
        .map((json) => GroupMember.fromJson(json as Map<String, dynamic>))
        .toList();

    // Sort locally: Host (0) -> Co-Host (1) -> Player (2), then alphabetical display_name
    list.sort((a, b) {
      final roleCompare = a.role.index.compareTo(b.role.index);
      if (roleCompare != 0) return roleCompare;
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return list;
  }

  /// Fetch pending approval requests
  Future<List<GroupMember>> fetchJoinRequests(String groupId) async {
    final response = await _client
        .from('group_members')
        .select('*, profiles:user_id (display_name, emoji, phone)')
        .eq('group_id', groupId)
        .eq('status', 'pending_approval')
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => GroupMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Check if a user has any unpaid or pending verification dues in a group
  Future<bool> hasUnpaidDues({
    required String groupId,
    required String userId,
  }) async {
    final response = await _client
        .from('payment_dues')
        .select('id')
        .eq('group_id', groupId)
        .eq('player_id', userId)
        .neq('status', 'paid')
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  /// Check if the group has any outstanding unpaid dues from anyone
  Future<bool> hasGroupUnpaidDues({required String groupId}) async {
    final response = await _client
        .from('payment_dues')
        .select('id')
        .eq('group_id', groupId)
        .neq('status', 'paid')
        .limit(1)
        .maybeSingle();

    return response != null;
  }

  /// Approve a pending join request
  Future<void> approveJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    await _client.from('group_members').update({
      'status': 'active',
      'joined_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', userId);
  }

  /// Reject a pending join request
  Future<void> rejectJoinRequest({
    required String groupId,
    required String userId,
  }) async {
    // RLS admin write policy allows updating the status to 'removed'
    await _client.from('group_members').update({
      'status': 'removed',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', userId);
  }

  /// Promote/demote member role
  Future<void> updateRole({
    required String groupId,
    required String userId,
    required MemberRole role,
  }) async {
    await _client.from('group_members').update({
      'role': role.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', userId);
  }

  /// Remove a member from the group
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _client.from('group_members').update({
      'status': 'removed',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', userId);
  }

  /// Transfer ownership of group from old Host to new Host
  Future<void> transferOwnership({
    required String groupId,
    required String oldHostId,
    required String newHostId,
  }) async {
    // 1. Promote new host to host role in members table
    await _client.from('group_members').update({
      'role': 'host',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', newHostId);

    // 2. Set new host_id in groups table
    await _client.from('groups').update({
      'host_id': newHostId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', groupId);

    // 3. Demote old host to co_host in members table
    await _client.from('group_members').update({
      'role': 'co_host',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('group_id', groupId).eq('user_id', oldHostId);
  }

  Future<MemberStats> fetchMemberStats({
    required String groupId,
    required String userId,
  }) async {
    // 1. Fetch joinedAt date from group_members
    final memberData = await _client
        .from('group_members')
        .select('joined_at')
        .eq('group_id', groupId)
        .eq('user_id', userId)
        .maybeSingle();
    
    final joinedAt = memberData?['joined_at'] != null 
        ? DateTime.parse(memberData!['joined_at'] as String)
        : null;

    // 2. Fetch all completed postpaid games in the group
    final completedGamesResponse = await _client
        .from('games')
        .select('id, scheduled_at')
        .eq('group_id', groupId)
        .eq('status', 'completed');
    
    final completedGamesList = completedGamesResponse as List;
    final totalCompletedGamesCount = completedGamesList.length;

    // 3. Fetch count of these games where this user attended
    int gamesPlayedCount = 0;
    if (totalCompletedGamesCount > 0) {
      final gameIds = completedGamesList.map((g) => g['id'] as String).toList();
      final rsvpResponse = await _client
          .from('rsvps')
          .select('id')
          .eq('user_id', userId)
          .inFilter('game_id', gameIds)
          .inFilter('status', ['yes', 'guest']);
      
      gamesPlayedCount = (rsvpResponse as List).length;
    }

    // 4. Calculate attendance percentage
    final attendancePct = totalCompletedGamesCount > 0 
        ? (gamesPlayedCount / totalCompletedGamesCount) * 100.0
        : 0.0;

    // 5. Group by month to calculate MonthlyParticipation
    final Map<String, int> monthlyCounts = {};
    if (gamesPlayedCount > 0) {
      final gameIds = completedGamesList.map((g) => g['id'] as String).toList();
      final attendedRsvps = await _client
          .from('rsvps')
          .select('game_id')
          .eq('user_id', userId)
          .inFilter('game_id', gameIds)
          .inFilter('status', ['yes', 'guest']);
      
      final attendedGameIds = (attendedRsvps as List).map((r) => r['game_id'] as String).toSet();
      
      for (var game in completedGamesList) {
        final gId = game['id'] as String;
        if (attendedGameIds.contains(gId)) {
          final scheduledAtStr = game['scheduled_at'] as String;
          final date = DateTime.parse(scheduledAtStr).toLocal();
          final key = '${date.year}-${date.month}';
          monthlyCounts[key] = (monthlyCounts[key] ?? 0) + 1;
        }
      }
    }

    final monthlyData = monthlyCounts.entries.map((e) {
      final parts = e.key.split('-');
      return MonthlyParticipation(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        gamesPlayed: e.value,
      );
    }).toList()
      ..sort((a, b) {
        final yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;
        return a.month.compareTo(b.month);
      });

    return MemberStats(
      userId: userId,
      groupId: groupId,
      gamesPlayed: gamesPlayedCount,
      attendancePct: attendancePct,
      joinedAt: joinedAt,
      monthlyData: monthlyData,
    );
  }
}
