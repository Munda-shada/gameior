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
  notifGameReminders: json['notif_game_reminders'] as bool? ?? true,
  notifWaitlistPromotions: json['notif_waitlist_promotions'] as bool? ?? true,
  notifPaymentDues: json['notif_payment_dues'] as bool? ?? true,
  notifMatchdayLineups: json['notif_matchday_lineups'] as bool? ?? true,
  notifDeliveryMode: json['notif_delivery_mode'] as String? ?? 'immediate',
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'display_name': instance.displayName,
  'phone': instance.phone,
  'emoji': instance.emoji,
  'upi_id': instance.upiId,
  'is_profile_complete': instance.isProfileComplete,
  'created_at': instance.createdAt.toIso8601String(),
  'notif_game_reminders': instance.notifGameReminders,
  'notif_waitlist_promotions': instance.notifWaitlistPromotions,
  'notif_payment_dues': instance.notifPaymentDues,
  'notif_matchday_lineups': instance.notifMatchdayLineups,
  'notif_delivery_mode': instance.notifDeliveryMode,
};
