// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Group _$GroupFromJson(Map<String, dynamic> json) => _Group(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  sport: $enumDecode(_$SportTypeEnumMap, json['sport']),
  hostId: json['host_id'] as String,
  defaultVenue: json['default_venue'] as String?,
  maxCapacity: (json['max_capacity'] as num?)?.toInt(),
  paymentModel: $enumDecode(_$PaymentModelEnumMap, json['payment_model']),
  defaultCostPaise: (json['default_cost_paise'] as num).toInt(),
  defaultUpiId: json['default_upi_id'] as String?,
  clubRules: json['club_rules'] as String?,
  allowMemberInvites: json['allow_member_invites'] as bool,
  autoApproveJoins: json['auto_approve_joins'] as bool,
  allowGuests: json['allow_guests'] as bool,
  showCostBreakdown: json['show_cost_breakdown'] as bool,
  autoApprovePayments: json['auto_approve_payments'] as bool,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$GroupToJson(_Group instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'sport': _$SportTypeEnumMap[instance.sport]!,
  'host_id': instance.hostId,
  'default_venue': instance.defaultVenue,
  'max_capacity': instance.maxCapacity,
  'payment_model': _$PaymentModelEnumMap[instance.paymentModel]!,
  'default_cost_paise': instance.defaultCostPaise,
  'default_upi_id': instance.defaultUpiId,
  'club_rules': instance.clubRules,
  'allow_member_invites': instance.allowMemberInvites,
  'auto_approve_joins': instance.autoApproveJoins,
  'allow_guests': instance.allowGuests,
  'show_cost_breakdown': instance.showCostBreakdown,
  'auto_approve_payments': instance.autoApprovePayments,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SportTypeEnumMap = {
  SportType.badminton: 'badminton',
  SportType.football: 'football',
  SportType.cricket: 'cricket',
  SportType.basketball: 'basketball',
  SportType.tennis: 'tennis',
  SportType.volleyball: 'volleyball',
  SportType.pickleball: 'pickleball',
  SportType.other: 'other',
};

const _$PaymentModelEnumMap = {
  PaymentModel.prepaid: 'prepaid',
  PaymentModel.postpaid: 'postpaid',
};

_GroupSummary _$GroupSummaryFromJson(Map<String, dynamic> json) =>
    _GroupSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: $enumDecode(_$SportTypeEnumMap, json['sport']),
      myRole: $enumDecode(_$MemberRoleEnumMap, json['my_role']),
      myStatus: $enumDecode(_$MembershipStatusEnumMap, json['my_status']),
      memberCount: (json['member_count'] as num).toInt(),
      pendingDuesPaise: (json['pending_dues_paise'] as num).toInt(),
      pendingFromPlayersPaise: (json['pending_from_players_paise'] as num)
          .toInt(),
      hasUpcomingSessions: json['has_upcoming_sessions'] as bool,
    );

Map<String, dynamic> _$GroupSummaryToJson(_GroupSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sport': _$SportTypeEnumMap[instance.sport]!,
      'my_role': _$MemberRoleEnumMap[instance.myRole]!,
      'my_status': _$MembershipStatusEnumMap[instance.myStatus]!,
      'member_count': instance.memberCount,
      'pending_dues_paise': instance.pendingDuesPaise,
      'pending_from_players_paise': instance.pendingFromPlayersPaise,
      'has_upcoming_sessions': instance.hasUpcomingSessions,
    };

const _$MemberRoleEnumMap = {
  MemberRole.host: 'host',
  MemberRole.coHost: 'co_host',
  MemberRole.player: 'player',
};

const _$MembershipStatusEnumMap = {
  MembershipStatus.pendingApproval: 'pending_approval',
  MembershipStatus.active: 'active',
  MembershipStatus.removed: 'removed',
  MembershipStatus.left: 'left',
};
