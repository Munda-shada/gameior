// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    @JsonKey(name: 'display_name') required String displayName,
    String? phone,
    required String emoji,
    @JsonKey(name: 'upi_id') String? upiId,
    @JsonKey(name: 'is_profile_complete') required bool isProfileComplete,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(true) @JsonKey(name: 'notif_game_reminders') bool notifGameReminders,
    @Default(true) @JsonKey(name: 'notif_waitlist_promotions') bool notifWaitlistPromotions,
    @Default(true) @JsonKey(name: 'notif_payment_dues') bool notifPaymentDues,
    @Default(true) @JsonKey(name: 'notif_matchday_lineups') bool notifMatchdayLineups,
    @Default('immediate') @JsonKey(name: 'notif_delivery_mode') String notifDeliveryMode,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}