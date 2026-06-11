import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';

part 'notification_preferences_provider.g.dart';

/// Simple immutable value class for the 5 notification toggles.
@immutable
class NotificationPrefs {
  final bool gameReminders;
  final bool waitlistPromotions;
  final bool paymentDues;
  final bool matchdayLineups;
  final String deliveryMode;

  const NotificationPrefs({
    required this.gameReminders,
    required this.waitlistPromotions,
    required this.paymentDues,
    required this.matchdayLineups,
    required this.deliveryMode,
  });

  NotificationPrefs copyWith({
    bool? gameReminders,
    bool? waitlistPromotions,
    bool? paymentDues,
    bool? matchdayLineups,
    String? deliveryMode,
  }) {
    return NotificationPrefs(
      gameReminders: gameReminders ?? this.gameReminders,
      waitlistPromotions: waitlistPromotions ?? this.waitlistPromotions,
      paymentDues: paymentDues ?? this.paymentDues,
      matchdayLineups: matchdayLineups ?? this.matchdayLineups,
      deliveryMode: deliveryMode ?? this.deliveryMode,
    );
  }
}

@riverpod
class NotificationPreferencesNotifier extends _$NotificationPreferencesNotifier {
  @override
  Future<NotificationPrefs> build() async {
    final profile = await ref.watch(currentUserProvider.future);
    return NotificationPrefs(
      gameReminders: profile?.notifGameReminders ?? true,
      waitlistPromotions: profile?.notifWaitlistPromotions ?? true,
      paymentDues: profile?.notifPaymentDues ?? true,
      matchdayLineups: profile?.notifMatchdayLineups ?? true,
      deliveryMode: profile?.notifDeliveryMode ?? 'immediate',
    );
  }

  Future<void> _save(NotificationPrefs prefs) async {
    // Optimistic update — UI reflects change instantly
    state = AsyncData(prefs);

    final client = ref.read(supabaseClientProvider);
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    await ref.read(profileRepositoryProvider).updateNotificationPreferences(
      userId: userId,
      notifGameReminders: prefs.gameReminders,
      notifWaitlistPromotions: prefs.waitlistPromotions,
      notifPaymentDues: prefs.paymentDues,
      notifMatchdayLineups: prefs.matchdayLineups,
      notifDeliveryMode: prefs.deliveryMode,
    );
    ref.invalidate(currentUserProvider);
  }

  void toggleGameReminders(bool val) =>
      _save(state.value!.copyWith(gameReminders: val));

  void toggleWaitlistPromotions(bool val) =>
      _save(state.value!.copyWith(waitlistPromotions: val));

  void togglePaymentDues(bool val) =>
      _save(state.value!.copyWith(paymentDues: val));

  void toggleMatchdayLineups(bool val) =>
      _save(state.value!.copyWith(matchdayLineups: val));

  void setDeliveryMode(String? val) {
    if (val != null) _save(state.value!.copyWith(deliveryMode: val));
  }
}
