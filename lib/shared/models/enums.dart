import 'package:json_annotation/json_annotation.dart';

enum SportType {
  @JsonValue('badminton') badminton,
  @JsonValue('football') football,
  @JsonValue('cricket') cricket,
  @JsonValue('basketball') basketball,
  @JsonValue('tennis') tennis,
  @JsonValue('volleyball') volleyball,
  @JsonValue('pickleball') pickleball,
  @JsonValue('other') other,
}

enum MemberRole {
  @JsonValue('host') host,
  @JsonValue('co_host') coHost,
  @JsonValue('player') player,
}

enum MembershipStatus {
  @JsonValue('pending_approval') pendingApproval,
  @JsonValue('active') active,
  @JsonValue('removed') removed,
  @JsonValue('left') left,
}

enum RsvpStatus {
  @JsonValue('unanswered') unanswered,
  @JsonValue('yes') yes,
  @JsonValue('no') no,
  @JsonValue('maybe') maybe,
  @JsonValue('guest') guest,
  @JsonValue('waitlist') waitlist,
}

enum PaymentModel {
  @JsonValue('prepaid') prepaid,
  @JsonValue('postpaid') postpaid,
}

enum GameStatus {
  @JsonValue('upcoming') upcoming,
  @JsonValue('completed') completed,
  @JsonValue('cancelled') cancelled,
}

enum DueStatus {
  @JsonValue('unpaid') unpaid,
  @JsonValue('pending_verification') pendingVerification,
  @JsonValue('paid') paid,
  @JsonValue('rejected') rejected,
}

enum SkillLevel {
  @JsonValue('all') all,
  @JsonValue('beginner') beginner,
  @JsonValue('intermediate') intermediate,
  @JsonValue('advanced') advanced,
}

enum NotificationDelivery {
  @JsonValue('immediate') immediate,
  @JsonValue('daily_digest') dailyDigest,
  @JsonValue('quiet_hours') quietHours,
}

enum AuditAction {
  @JsonValue('member_joined') memberJoined,
  @JsonValue('member_left') memberLeft,
  @JsonValue('member_removed') memberRemoved,
  @JsonValue('role_promoted') rolePromoted,
  @JsonValue('role_demoted') roleDemoted,
  @JsonValue('ownership_transferred') ownershipTransferred,
  @JsonValue('join_request_accepted') joinRequestAccepted,
  @JsonValue('join_request_rejected') joinRequestRejected,
}