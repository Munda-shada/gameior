import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'rsvp.freezed.dart';
part 'rsvp.g.dart';

@freezed
abstract class Rsvp with _$Rsvp {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Rsvp({
    required String id,
    required String gameId,
    required String userId,
    required RsvpStatus status,
    required int guestCount,
    required bool userIsPlaying,
    int? waitlistPosition,
    DateTime? respondedAt,
  }) = _Rsvp;

  factory Rsvp.fromJson(Map<String, dynamic> json) => _$RsvpFromJson(json);
}
