// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rsvp.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Rsvp _$RsvpFromJson(Map<String, dynamic> json) => _Rsvp(
  id: json['id'] as String,
  gameId: json['game_id'] as String,
  userId: json['user_id'] as String,
  status: $enumDecode(_$RsvpStatusEnumMap, json['status']),
  guestCount: (json['guest_count'] as num).toInt(),
  userIsPlaying: json['user_is_playing'] as bool,
  waitlistPosition: (json['waitlist_position'] as num?)?.toInt(),
  respondedAt: json['responded_at'] == null
      ? null
      : DateTime.parse(json['responded_at'] as String),
);

Map<String, dynamic> _$RsvpToJson(_Rsvp instance) => <String, dynamic>{
  'id': instance.id,
  'game_id': instance.gameId,
  'user_id': instance.userId,
  'status': _$RsvpStatusEnumMap[instance.status]!,
  'guest_count': instance.guestCount,
  'user_is_playing': instance.userIsPlaying,
  'waitlist_position': instance.waitlistPosition,
  'responded_at': instance.respondedAt?.toIso8601String(),
};

const _$RsvpStatusEnumMap = {
  RsvpStatus.unanswered: 'unanswered',
  RsvpStatus.yes: 'yes',
  RsvpStatus.no: 'no',
  RsvpStatus.maybe: 'maybe',
  RsvpStatus.guest: 'guest',
  RsvpStatus.waitlist: 'waitlist',
};
