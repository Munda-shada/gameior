// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_due.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentDue _$PaymentDueFromJson(Map<String, dynamic> json) => _PaymentDue(
  id: json['id'] as String,
  gameId: json['game_id'] as String,
  groupId: json['group_id'] as String,
  playerId: json['player_id'] as String,
  paymentOwnerId: json['payment_owner_id'] as String,
  amountPaise: (json['amount_paise'] as num).toInt(),
  status: $enumDecode(_$DueStatusEnumMap, json['status']),
  utrReference: json['utr_reference'] as String?,
  submittedAt: json['submitted_at'] == null
      ? null
      : DateTime.parse(json['submitted_at'] as String),
  verifiedAt: json['verified_at'] == null
      ? null
      : DateTime.parse(json['verified_at'] as String),
  verifiedBy: json['verified_by'] as String?,
  rejectionCount: (json['rejection_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  profiles: json['profiles'] as Map<String, dynamic>?,
  games: json['games'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$PaymentDueToJson(_PaymentDue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'game_id': instance.gameId,
      'group_id': instance.groupId,
      'player_id': instance.playerId,
      'payment_owner_id': instance.paymentOwnerId,
      'amount_paise': instance.amountPaise,
      'status': _$DueStatusEnumMap[instance.status]!,
      'utr_reference': instance.utrReference,
      'submitted_at': instance.submittedAt?.toIso8601String(),
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'verified_by': instance.verifiedBy,
      'rejection_count': instance.rejectionCount,
      'created_at': instance.createdAt.toIso8601String(),
      'profiles': instance.profiles,
      'games': instance.games,
    };

const _$DueStatusEnumMap = {
  DueStatus.unpaid: 'unpaid',
  DueStatus.pendingVerification: 'pending_verification',
  DueStatus.paid: 'paid',
  DueStatus.rejected: 'rejected',
};
