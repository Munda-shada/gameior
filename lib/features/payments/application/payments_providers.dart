import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/models/enums.dart';

part 'payments_providers.g.dart';

@riverpod
class AdminDuesNotifier extends _$AdminDuesNotifier {
  @override
  Future<List<PaymentDue>> build(String groupId) async {
    return ref.watch(paymentsRepositoryProvider).fetchDuesAsOwner(groupId: groupId);
  }

  Future<void> approve(String dueId) async {
    await ref.read(paymentsRepositoryProvider).approveDue(dueId);
    ref.invalidateSelf();
  }

  Future<void> reject(String dueId) async {
    await ref.read(paymentsRepositoryProvider).rejectDue(dueId);
    ref.invalidateSelf();
  }

  Future<void> markPaid(String dueId) async {
    await ref.read(paymentsRepositoryProvider).markAsPaid(dueId);
    ref.invalidateSelf();
  }

  Future<void> markAllPaid(String userId) async {
    await ref.read(paymentsRepositoryProvider).markAllDuesPaid(groupId: groupId, userId: userId);
    ref.invalidateSelf();
    ref.invalidate(adminDuesByPlayerProvider(groupId));
    ref.invalidate(adminDuesByGameProvider(groupId));
  }

  Future<void> triggerReminders({String? userId}) async {
    await ref.read(paymentsRepositoryProvider).remindDues(groupId: groupId, userId: userId);
  }
}

@riverpod
class MyDuesNotifier extends _$MyDuesNotifier {
  @override
  Future<List<PaymentDue>> build(String groupId) async {
    return ref.watch(paymentsRepositoryProvider).fetchMyDues(groupId: groupId);
  }

  Future<void> submitUtr({
    required String dueId,
    required String utrReference,
  }) async {
    await ref.read(paymentsRepositoryProvider).submitUtr(
      dueId: dueId,
      utrReference: utrReference,
    );
    ref.invalidateSelf();
  }
}

@riverpod
Future<List<PlayerDuesSummary>> adminDuesByPlayer(AdminDuesByPlayerRef ref, String groupId) async {
  final dues = await ref.watch(adminDuesNotifierProvider(groupId).future);
  
  final Map<String, List<PaymentDue>> grouped = {};
  for (final due in dues) {
    grouped.putIfAbsent(due.playerId, () => []).add(due);
  }

  final summaries = <PlayerDuesSummary>[];
  for (final entry in grouped.entries) {
    final playerDues = entry.value;
    final pending = playerDues.where((d) => d.status != DueStatus.paid).toList();
    if (pending.isEmpty) continue; // Only show players with outstanding dues

    summaries.add(PlayerDuesSummary(
      playerId: entry.key,
      playerName: playerDues.first.playerName,
      playerEmoji: playerDues.first.playerEmoji,
      totalPendingPaise: pending.fold(0, (sum, d) => sum + d.amountPaise),
      gameCount: pending.length,
      dues: playerDues,
    ));
  }
  return summaries;
}

@riverpod
Future<List<GameDuesSummary>> adminDuesByGame(AdminDuesByGameRef ref, String groupId) async {
  final dues = await ref.watch(adminDuesNotifierProvider(groupId).future);
  
  final Map<String, List<PaymentDue>> grouped = {};
  for (final due in dues) {
    grouped.putIfAbsent(due.gameId, () => []).add(due);
  }

  final summaries = <GameDuesSummary>[];
  for (final entry in grouped.entries) {
    final gameDues = entry.value;
    final pending = gameDues.where((d) => d.status != DueStatus.paid).toList();
    if (pending.isEmpty) continue; // Only show games with outstanding dues

    summaries.add(GameDuesSummary(
      gameId: entry.key,
      gameTitle: gameDues.first.gameTitle,
      scheduledAt: gameDues.first.scheduledAt,
      totalPendingPaise: pending.fold(0, (sum, d) => sum + d.amountPaise),
      unpaidCount: pending.length,
      playerDues: gameDues.map((d) => GamePlayerDue(
        playerId: d.playerId,
        playerName: d.playerName,
        playerEmoji: d.playerEmoji,
        due: d,
      )).toList(),
    ));
  }
  return summaries;
}

@riverpod
class PaymentsPlayerFilter extends _$PaymentsPlayerFilter {
  @override
  String? build(String groupId) => null;

  void set(String? userId) => state = userId;
}
