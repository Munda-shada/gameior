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
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}