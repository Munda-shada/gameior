// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLog _$AuditLogFromJson(Map<String, dynamic> json) => _AuditLog(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  actorId: json['actor_id'] as String?,
  targetId: json['target_id'] as String?,
  action: $enumDecode(_$AuditActionEnumMap, json['action']),
  metadata: json['metadata'] as Map<String, dynamic>?,
  createdAt: DateTime.parse(json['created_at'] as String),
  actor: json['actor'] as Map<String, dynamic>?,
  target: json['target'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$AuditLogToJson(_AuditLog instance) => <String, dynamic>{
  'id': instance.id,
  'group_id': instance.groupId,
  'actor_id': instance.actorId,
  'target_id': instance.targetId,
  'action': _$AuditActionEnumMap[instance.action]!,
  'metadata': instance.metadata,
  'created_at': instance.createdAt.toIso8601String(),
  'actor': instance.actor,
  'target': instance.target,
};

const _$AuditActionEnumMap = {
  AuditAction.memberJoined: 'member_joined',
  AuditAction.memberLeft: 'member_left',
  AuditAction.memberRemoved: 'member_removed',
  AuditAction.rolePromoted: 'role_promoted',
  AuditAction.roleDemoted: 'role_demoted',
  AuditAction.ownershipTransferred: 'ownership_transferred',
  AuditAction.joinRequestAccepted: 'join_request_accepted',
  AuditAction.joinRequestRejected: 'join_request_rejected',
};
