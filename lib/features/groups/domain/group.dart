import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
abstract class Group with _$Group {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Group({
    required String id,
    required String name,
    String? description,
    required SportType sport,
    required String hostId,
    String? defaultVenue,
    int? maxCapacity,
    required PaymentModel paymentModel,
    required int defaultCostPaise,
    String? defaultUpiId,
    String? clubRules,
    required bool allowMemberInvites,
    required bool autoApproveJoins,
    required bool allowGuests,
    required bool showCostBreakdown,
    required bool autoApprovePayments,
    required DateTime createdAt,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
abstract class GroupSummary with _$GroupSummary {
  // Lightweight model for group cards (no full settings)
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory GroupSummary({
    required String id,
    required String name,
    required SportType sport,
    required MemberRole myRole,
    required MembershipStatus myStatus,
    required int memberCount,
    required int pendingDuesPaise,       // player view
    required int pendingFromPlayersPaise, // admin view
    required bool hasUpcomingSessions,
  }) = _GroupSummary;

  factory GroupSummary.fromJson(Map<String, dynamic> json) =>
      _$GroupSummaryFromJson(json);
}