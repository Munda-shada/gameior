import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/exceptions/app_exception.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/features/groups/application/create_group_provider.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(ref.watch(supabaseClientProvider));
});

class GroupsRepository {
  GroupsRepository(this._client);
  final SupabaseClient _client;

  Future<List<GroupSummary>> fetchMyGroups() async {
    final myUserId = _client.auth.currentUser!.id;

    // Join group_members → groups → payment_dues summary
    // Return all groups where caller is a member (any status)
    final response = await _client
        .from('group_members')
        .select('''
          role, status, joined_at,
          groups (
            id, name, sport, host_id,
            group_members (count)
          )
        ''')
        .eq('user_id', myUserId)
        .not('status', 'in', '(removed,left)');

    // Fetch all unpaid dues relevant to me (either I owe or I am the owner)
    final allMyDues = await _client
        .from('payment_dues')
        .select('group_id, amount_paise, player_id, payment_owner_id')
        .neq('status', 'paid');

    // Fetch groups that have upcoming games to accurately categorize groups
    final upcomingGamesResponse = await _client
        .from('games')
        .select('group_id')
        .eq('status', 'upcoming');

    final upcomingGroupIds = (upcomingGamesResponse as List)
        .map((row) => row['group_id'] as String)
        .toSet();

    final myDuesByGroup = <String, int>{};
    final adminDuesByGroup = <String, int>{};

    for (final row in (allMyDues as List)) {
      final groupId = row['group_id'] as String;
      final amount = (row['amount_paise'] as num?)?.toInt() ?? 0;

      if (row['player_id'] == myUserId) {
        myDuesByGroup[groupId] = (myDuesByGroup[groupId] ?? 0) + amount;
      }
      if (row['payment_owner_id'] == myUserId && row['player_id'] != myUserId) {
        adminDuesByGroup[groupId] = (adminDuesByGroup[groupId] ?? 0) + amount;
      }
    }

    final list = response as List;
    return list.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final groupData = itemMap['groups'] as Map<String, dynamic>;
      final groupId = groupData['id'] as String;
      final memberCountList = groupData['group_members'] as List?;
      final memberCount = (memberCountList != null && memberCountList.isNotEmpty)
          ? (memberCountList.first['count'] as num).toInt()
          : 0;

      final flatJson = {
        'id':                      groupId,
        'name':                    groupData['name'],
        'sport':                   groupData['sport'],
        'my_role':                 itemMap['role'],
        'my_status':               itemMap['status'],
        'member_count':            memberCount,
        'pending_dues_paise':      myDuesByGroup[groupId] ?? 0,
        'pending_from_players_paise': adminDuesByGroup[groupId] ?? 0,
        'has_upcoming_sessions':   upcomingGroupIds.contains(groupId),
      };

      return GroupSummary.fromJson(flatJson);
    }).toList();
  }

  Future<String> createGroup(CreateGroupFormState form) async {
    // 1. INSERT into groups
    final group = await _client.from('groups').insert({
      'name':                  form.name.trim(),
      'sport':                 form.sport!.name,
      'description':           form.description.trim(),
      'host_id':               _client.auth.currentUser!.id,
      'default_venue':         form.defaultVenue.trim(),
      'max_capacity':          form.maxCapacity,
      'payment_model':         form.paymentModel.name,
      'default_cost_paise':    form.defaultCostPaise,
      'default_upi_id':        form.defaultUpiId.trim(),
      'club_rules':            form.clubRules.trim(),
      'allow_member_invites':  form.allowMemberInvites,
      'auto_approve_joins':    !form.requireApproval,
      'allow_guests':          form.allowGuests,
    }).select().single();

    final groupId = group['id'] as String;

    // 2. INSERT creator as host member
    await _client.from('group_members').insert({
      'group_id':  groupId,
      'user_id':   _client.auth.currentUser!.id,
      'role':      'host',
      'status':    'active',
      'joined_at': DateTime.now().toIso8601String(),
    });

    // 3. Generate initial invite code via Edge Function
    try {
      await _client.functions.invoke('regenerate_invite_code',
          body: {'group_id': groupId});
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }

    return groupId;
  }

  Future<Map<String, dynamic>> joinGroup(String inviteCode) async {
    try {
      final response = await _client.functions.invoke(
        'join_group',
        body: {'invite_code': inviteCode.toUpperCase().trim()},
      );
      return response.data as Map<String, dynamic>;
    } on FunctionException catch (e) {
      throw AppException.fromEdgeFunction(e);
    }
  }
}