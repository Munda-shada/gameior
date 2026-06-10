import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_stats.freezed.dart';
part 'member_stats.g.dart';

@freezed
abstract class MemberStats with _$MemberStats {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MemberStats({
    required String userId,
    required String groupId,
    required int gamesPlayed,
    required double attendancePct, // 0.0 to 100.0
    required DateTime? joinedAt,
    required List<MonthlyParticipation> monthlyData,
  }) = _MemberStats;

  factory MemberStats.fromJson(Map<String, dynamic> json) =>
      _$MemberStatsFromJson(json);
}

@freezed
abstract class MonthlyParticipation with _$MonthlyParticipation {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MonthlyParticipation({
    required int year,
    required int month,
    required int gamesPlayed,
  }) = _MonthlyParticipation;

  factory MonthlyParticipation.fromJson(Map<String, dynamic> json) =>
      _$MonthlyParticipationFromJson(json);
}
