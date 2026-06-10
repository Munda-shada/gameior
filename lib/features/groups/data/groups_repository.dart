import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/features/groups/application/create_group_provider.dart';

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  return GroupsRepository(ref.watch(supabaseClientProvider));
});

class GroupsRepository {
  GroupsRepository(this._client);
  final SupabaseClient _client;

  Future<List<GroupSummary>> fetchMyGroups() async {
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
        .eq('user_id', _client.auth.currentUser!.id)
        .not('status', 'in', '(removed,left)');

    final list = response as List;
    return list.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final groupData = itemMap['groups'] as Map<String, dynamic>;
      final memberCountList = groupData['group_members'] as List?;
      final memberCount = (memberCountList != null && memberCountList.isNotEmpty)
          ? (memberCountList.first['count'] as num).toInt()
          : 0;

      final flatJson = {
        'id':                      groupData['id'],
        'name':                    groupData['name'],
        'sport':                   groupData['sport'],
        'myRole':                  itemMap['role'],
        'myStatus':                itemMap['status'],
        'memberCount':             memberCount,
        'pendingDuesPaise':        0, // Connected in Sprint 4
        'pendingFromPlayersPaise': 0, // Connected in Sprint 4
        'hasUpcomingSessions':     false,
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
    } catch (e) {
      // Fallback: Generate code locally and insert directly to database
      final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
      // Use standard random generator
      final rand = DateTime.now().microsecondsSinceEpoch;
      var code = '';
      for (var i = 0; i < 6; i++) {
        final charIndex = (rand ~/ (i + 1) * 31) % chars.length;
        code += chars[charIndex];
      }
      try {
        await _client.from('group_invites').insert({
          'group_id':   groupId,
          'code':       code,
          'created_by': _client.auth.currentUser!.id,
        });
      } catch (dbErr) {
        // Log error and proceed so group creation isn't blocked
        print('Error generating invite code fallback: $dbErr');
      }
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
    } catch (e) {
      // Fallback: direct DB query (subject to RLS constraints)
      try {
        final invite = await _client
            .from('group_invites')
            .select('group_id')
            .eq('code', inviteCode.toUpperCase().trim())
            .single();

        final groupId = invite['group_id'] as String;

        // Check if user is already a member
        final existing = await _client
            .from('group_members')
            .select('status')
            .eq('group_id', groupId)
            .eq('user_id', _client.auth.currentUser!.id)
            .maybeSingle();

        if (existing != null) {
          final status = existing['status'] as String;
          if (status == 'active' || status == 'pending_approval') {
            return {'error': 'already_member', 'message': "You're already in this group."};
          }
        }

        // Insert as pending (only allowed status by RLS insert policy)
        await _client.from('group_members').upsert({
          'group_id': groupId,
          'user_id': _client.auth.currentUser!.id,
          'role':     'player',
          'status':   'pending_approval',
        });

        return {
          'status': 'pending_approval',
          'message': 'Request sent. Waiting for host approval.'
        };
      } catch (err) {
        return {'error': 'invalid_invite_code', 'message': 'This invite code is invalid.'};
      }
    }
  }
}