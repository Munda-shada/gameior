// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:gameior/shared/models/enums.dart';

part 'payment_due.freezed.dart';
part 'payment_due.g.dart';

@freezed
abstract class PaymentDue with _$PaymentDue {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PaymentDue({
    required String id,
    required String gameId,
    required String groupId,
    required String playerId,
    required String paymentOwnerId,
    required int amountPaise,
    required DueStatus status,
    String? utrReference,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    String? verifiedBy,
    required int rejectionCount,
    required DateTime createdAt,
    // Nested profiles join payload
    Map<String, dynamic>? profiles,
    // Nested games join payload
    Map<String, dynamic>? games,
  }) = _PaymentDue;

  factory PaymentDue.fromJson(Map<String, dynamic> json) =>
      _$PaymentDueFromJson(json);
}

extension PaymentDueGetters on PaymentDue {
  String get playerName {
    if (profiles != null) {
      return profiles!['display_name'] as String? ?? 'Player';
    }
    return 'Player';
  }

  String get playerEmoji {
    if (profiles != null) {
      return profiles!['emoji'] as String? ?? '🏸';
    }
    return '🏸';
  }

  String get gameTitle {
    if (games != null) {
      return games!['title'] as String? ?? 'Match Session';
    }
    return 'Match Session';
  }

  DateTime get scheduledAt {
    if (games != null && games!['scheduled_at'] != null) {
      return DateTime.parse(games!['scheduled_at'] as String).toLocal();
    }
    return DateTime.now();
  }
}

// Aggregated view for admin "by player"
@freezed
abstract class PlayerDuesSummary with _$PlayerDuesSummary {
  const factory PlayerDuesSummary({
    required String playerId,
    required String playerName,
    required String playerEmoji,
    required int totalPendingPaise,
    required int gameCount,
    required List<PaymentDue> dues,   // expanded dues per game
  }) = _PlayerDuesSummary;
}

// Aggregated view for admin "by game"
@freezed
abstract class GameDuesSummary with _$GameDuesSummary {
  const factory GameDuesSummary({
    required String gameId,
    required String gameTitle,
    required DateTime scheduledAt,
    required int totalPendingPaise,
    required int unpaidCount,
    required List<GamePlayerDue> playerDues,
  }) = _GameDuesSummary;
}

@freezed
abstract class GamePlayerDue with _$GamePlayerDue {
  const factory GamePlayerDue({
    required String playerId,
    required String playerName,
    required String playerEmoji,
    required PaymentDue due,
  }) = _GamePlayerDue;
}
