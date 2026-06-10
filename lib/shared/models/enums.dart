import 'package:json_annotation/json_annotation.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum SportType {
  badminton,
  football,
  cricket,
  basketball,
  tennis,
  volleyball,
  pickleball,
  other,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum MemberRole {
  host,
  coHost,
  player,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum MembershipStatus {
  pendingApproval,
  active,
  removed,
  left,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum RsvpStatus {
  unanswered,
  yes,
  no,
  maybe,
  guest,
  waitlist,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum PaymentModel {
  prepaid,
  postpaid,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum GameStatus {
  upcoming,
  completed,
  cancelled,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum DueStatus {
  unpaid,
  pendingVerification,
  paid,
  rejected,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum SkillLevel {
  all,
  beginner,
  intermediate,
  advanced,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum NotificationDelivery {
  immediate,
  dailyDigest,
  quietHours,
}

@JsonEnum(fieldRename: FieldRename.snake)
enum AuditAction {
  memberJoined,
  memberLeft,
  memberRemoved,
  rolePromoted,
  roleDemoted,
  ownershipTransferred,
  joinRequestAccepted,
  joinRequestRejected,
}