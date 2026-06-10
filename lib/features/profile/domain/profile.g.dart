// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  displayName: json['display_name'] as String,
  phone: json['phone'] as String?,
  emoji: json['emoji'] as String,
  upiId: json['upi_id'] as String?,
  isProfileComplete: json['is_profile_complete'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'phone': instance.phone,
  'emoji': instance.emoji,
  'upi_id': instance.upiId,
  'is_profile_complete': instance.isProfileComplete,
  'created_at': instance.createdAt.toIso8601String(),
};
