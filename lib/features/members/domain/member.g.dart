// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) => _GroupMember(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  userId: json['user_id'] as String,
  role: $enumDecode(_$MemberRoleEnumMap, json['role']),
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  profiles: json['profiles'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$GroupMemberToJson(_GroupMember instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'user_id': instance.userId,
      'role': _$MemberRoleEnumMap[instance.role]!,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'profiles': instance.profiles,
    };

const _$MemberRoleEnumMap = {
  MemberRole.host: 'host',
  MemberRole.coHost: 'co_host',
  MemberRole.player: 'player',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pendingApproval: 'pending_approval',
  MembershipStatus.active: 'active',
  MembershipStatus.removed: 'removed',
  MembershipStatus.left: 'left',
};
