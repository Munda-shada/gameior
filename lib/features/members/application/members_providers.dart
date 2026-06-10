import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/features/members/data/members_repository.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/features/members/domain/member_stats.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/models/enums.dart';

part 'members_providers.g.dart';

@riverpod
class GroupMembers extends _$GroupMembers {
  @override
  Future<List<GroupMember>> build(String groupId) async {
    return ref.watch(membersRepositoryProvider).fetchMembers(groupId);
  }

  Future<void> updateRole({required String userId, required MemberRole role}) async {
    await ref.read(membersRepositoryProvider).updateRole(
      groupId: groupId,
      userId: userId,
      role: role,
    );
    ref.invalidateSelf();
    ref.invalidate(groupContextProvider(groupId));
  }

  Future<void> removeMember({required String userId}) async {
    await ref.read(membersRepositoryProvider).removeMember(
      groupId: groupId,
      userId: userId,
    );
    ref.invalidateSelf();
    ref.invalidate(groupContextProvider(groupId));
  }

  Future<void> transferOwnership({required String oldHostId, required String newHostId}) async {
    await ref.read(membersRepositoryProvider).transferOwnership(
      groupId: groupId,
      oldHostId: oldHostId,
      newHostId: newHostId,
    );
    ref.invalidateSelf();
    ref.invalidate(groupContextProvider(groupId));
  }
}

@riverpod
class GroupJoinRequests extends _$GroupJoinRequests {
  @override
  Future<List<GroupMember>> build(String groupId) async {
    return ref.watch(membersRepositoryProvider).fetchJoinRequests(groupId);
  }

  Future<void> approve({required String userId}) async {
    await ref.read(membersRepositoryProvider).approveJoinRequest(
      groupId: groupId,
      userId: userId,
    );
    ref.invalidateSelf();
    ref.invalidate(groupMembersProvider(groupId));
    ref.invalidate(groupContextProvider(groupId));
  }

  Future<void> reject({required String userId}) async {
    await ref.read(membersRepositoryProvider).rejectJoinRequest(
      groupId: groupId,
      userId: userId,
    );
    ref.invalidateSelf();
    ref.invalidate(groupContextProvider(groupId));
  }
}

@riverpod
Future<MemberStats> memberStats(MemberStatsRef ref, {required String groupId, required String userId}) async {
  return ref.watch(membersRepositoryProvider).fetchMemberStats(
    groupId: groupId,
    userId: userId,
  );
}
