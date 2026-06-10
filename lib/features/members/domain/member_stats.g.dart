// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberStats _$MemberStatsFromJson(Map<String, dynamic> json) => _MemberStats(
  userId: json['user_id'] as String,
  groupId: json['group_id'] as String,
  gamesPlayed: (json['games_played'] as num).toInt(),
  attendancePct: (json['attendance_pct'] as num).toDouble(),
  joinedAt: json['joined_at'] == null
      ? null
      : DateTime.parse(json['joined_at'] as String),
  monthlyData: (json['monthly_data'] as List<dynamic>)
      .map((e) => MonthlyParticipation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$MemberStatsToJson(_MemberStats instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'group_id': instance.groupId,
      'games_played': instance.gamesPlayed,
      'attendance_pct': instance.attendancePct,
      'joined_at': instance.joinedAt?.toIso8601String(),
      'monthly_data': instance.monthlyData,
    };

_MonthlyParticipation _$MonthlyParticipationFromJson(
  Map<String, dynamic> json,
) => _MonthlyParticipation(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  gamesPlayed: (json['games_played'] as num).toInt(),
);

Map<String, dynamic> _$MonthlyParticipationToJson(
  _MonthlyParticipation instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'games_played': instance.gamesPlayed,
};
