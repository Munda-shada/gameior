import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'audit_log.freezed.dart';
part 'audit_log.g.dart';

@freezed
abstract class AuditLog with _$AuditLog {
  const factory AuditLog({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'actor_id') String? actorId,
    @JsonKey(name: 'target_id') String? targetId,
    required AuditAction action,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    Map<String, dynamic>? actor,
    Map<String, dynamic>? target,
  }) = _AuditLog;

  factory AuditLog.fromJson(Map<String, dynamic> json) => _$AuditLogFromJson(json);
}

extension AuditLogX on AuditLog {
  String get actorDisplayName => actor?['display_name'] as String? ?? 'Deleted User';
  String get targetDisplayName => target?['display_name'] as String? ?? 'Deleted User';
}
