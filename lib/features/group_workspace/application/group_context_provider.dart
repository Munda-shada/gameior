import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/groups/domain/group.dart';
import 'package:gameior/shared/models/enums.dart';

part 'group_context_provider.freezed.dart';
part 'group_context_provider.g.dart';

@freezed
abstract class GroupContext with _$GroupContext {
  const factory GroupContext({
    required Group group,
    required MemberRole myRole,
    required MembershipStatus myStatus,
    required String inviteCode,
    required bool notificationsEnabled,
  }) = _GroupContext;
}

MemberRole _parseRole(String role) {
  switch (role) {
    case 'host':
      return MemberRole.host;
    case 'co_host':
      return MemberRole.coHost;
    default:
      return MemberRole.player;
  }
}

MembershipStatus _parseStatus(String status) {
  switch (status) {
    case 'pending_approval':
      return MembershipStatus.pendingApproval;
    case 'active':
      return MembershipStatus.active;
    case 'removed':
      return MembershipStatus.removed;
    default:
      return MembershipStatus.left;
  }
}

@riverpod
Future<GroupContext> groupContext(GroupContextRef ref, String groupId) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id;
  if (userId == null) throw Exception('User not authenticated');

  // 1. Fetch group details
  final groupRes = await client
      .from('groups')
      .select()
      .eq('id', groupId)
      .single();
  final group = Group.fromJson(groupRes);

  // 2. Fetch caller's membership status and role
  final memberRes = await client
      .from('group_members')
      .select('role, status, notifications_enabled')
      .eq('group_id', groupId)
      .eq('user_id', userId)
      .single();
  
  final myRole = _parseRole(memberRes['role'] as String);
  final myStatus = _parseStatus(memberRes['status'] as String);
  final notificationsEnabled = memberRes['notifications_enabled'] as bool? ?? true;

  // 3. Fetch group invite code
  var inviteCode = '';
  try {
    final inviteRes = await client
        .from('group_invites')
        .select('code')
        .eq('group_id', groupId)
        .maybeSingle();
    if (inviteRes != null) {
      inviteCode = inviteRes['code'] as String;
    }
  } catch (e) {
    // Fail silently if invite code not found
  }

  return GroupContext(
    group: group,
    myRole: myRole,
    myStatus: myStatus,
    inviteCode: inviteCode,
    notificationsEnabled: notificationsEnabled,
  );
}

final groupWorkspaceTabProvider = StateProvider.family<int, String>((ref, groupId) {
  return 0;
});

