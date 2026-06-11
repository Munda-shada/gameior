import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/profile/application/notification_preferences_provider.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (prefsAsync.isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
            )
          else
            Icon(Icons.check, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading preferences: $err')),
        data: (prefs) {
          final notifier = ref.read(notificationPreferencesNotifierProvider.notifier);
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              _buildSectionHeader(context, 'PUSH NOTIFICATIONS'),
              SwitchListTile(
                title: const Text('Game Reminders'),
                subtitle: const Text('Get notified before a game starts'),
                value: prefs.gameReminders,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: notifier.toggleGameReminders,
              ),
              SwitchListTile(
                title: const Text('Waitlist Promotions'),
                subtitle: const Text('Alerts when you get bumped off the waitlist'),
                value: prefs.waitlistPromotions,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: notifier.toggleWaitlistPromotions,
              ),
              SwitchListTile(
                title: const Text('Payment Dues'),
                subtitle: const Text('Reminders for unpaid game sessions'),
                value: prefs.paymentDues,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: notifier.togglePaymentDues,
              ),
              SwitchListTile(
                title: const Text('Matchday Lineups'),
                subtitle: const Text('Notifications when the final roster is locked'),
                value: prefs.matchdayLineups,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: notifier.toggleMatchdayLineups,
              ),

              const Divider(height: AppSpacing.xxl),

              _buildSectionHeader(context, 'DELIVERY TIMING'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  'Choose how you want to receive less urgent notifications like group announcements or weekly roundups.',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DeliveryOptionTile(
                title: 'Immediate',
                subtitle: 'Send notifications as soon as they happen',
                value: 'immediate',
                groupValue: prefs.deliveryMode,
                onChanged: notifier.setDeliveryMode,
              ),
              _DeliveryOptionTile(
                title: 'Daily Digest',
                subtitle: 'Group everything into one notification per day',
                value: 'daily_digest',
                groupValue: prefs.deliveryMode,
                onChanged: notifier.setDeliveryMode,
              ),
              _DeliveryOptionTile(
                title: 'Quiet Hours',
                subtitle: 'Pause non-urgent alerts between 10 PM and 8 AM',
                value: 'quiet_hours',
                groupValue: prefs.deliveryMode,
                onChanged: notifier.setDeliveryMode,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DeliveryOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _DeliveryOptionTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}