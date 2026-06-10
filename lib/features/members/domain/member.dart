// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'member.freezed.dart';
part 'member.g.dart';

@freezed
abstract class GroupMember with _$GroupMember {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GroupMember({
    required String id,
    required String groupId,
    required String userId,
    required MemberRole role,
    required MembershipStatus status,
    DateTime? joinedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Nested profiles join payload
    Map<String, dynamic>? profiles,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) =>
      _$GroupMemberFromJson(json);
}

extension GroupMemberGetters on GroupMember {
  String get displayName {
    if (profiles != null) {
      return profiles!['display_name'] as String? ?? 'Player';
    }
    return 'Player';
  }

  String get emoji {
    if (profiles != null) {
      return profiles!['emoji'] as String? ?? '🏸';
    }
    return '🏸';
  }

  String get phone {
    if (profiles != null) {
      return profiles!['phone'] as String? ?? 'No contact';
    }
    return 'No contact';
  }
}
