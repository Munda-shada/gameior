import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/features/profile/application/signup_provider.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  bool _isInitialized = false;
  late bool _gameReminders;
  late bool _waitlistPromotions;
  late bool _paymentDues;
  late bool _matchdayLineups;
  late String _deliveryTiming;

  Timer? _debounceTimer;
  bool _isSaving = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onPreferenceChanged() {
    setState(() => _isSaving = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final client = ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isSaving = false);
        return;
      }

      try {
        await ref.read(profileRepositoryProvider).updateNotificationPreferences(
              userId: user.id,
              notifGameReminders: _gameReminders,
              notifWaitlistPromotions: _waitlistPromotions,
              notifPaymentDues: _paymentDues,
              notifMatchdayLineups: _matchdayLineups,
              notifDeliveryMode: _deliveryTiming,
            );
        ref.invalidate(currentUserProvider);
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences saved'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save preferences: $e')),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ),
            )
          else
            const Icon(Icons.check, color: Colors.green),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading preferences: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }

          if (!_isInitialized) {
            _gameReminders = profile.notifGameReminders;
            _waitlistPromotions = profile.notifWaitlistPromotions;
            _paymentDues = profile.notifPaymentDues;
            _matchdayLineups = profile.notifMatchdayLineups;
            _deliveryTiming = profile.notifDeliveryMode;
            _isInitialized = true;
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            children: [
              _buildSectionHeader('PUSH NOTIFICATIONS'),
              SwitchListTile(
                title: const Text('Game Reminders'),
                subtitle: const Text('Get notified before a game starts'),
                value: _gameReminders,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _gameReminders = val);
                  _onPreferenceChanged();
                },
              ),
              SwitchListTile(
                title: const Text('Waitlist Promotions'),
                subtitle: const Text('Alerts when you get bumped off the waitlist'),
                value: _waitlistPromotions,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _waitlistPromotions = val);
                  _onPreferenceChanged();
                },
              ),
              SwitchListTile(
                title: const Text('Payment Dues'),
                subtitle: const Text('Reminders for unpaid game sessions'),
                value: _paymentDues,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _paymentDues = val);
                  _onPreferenceChanged();
                },
              ),
              SwitchListTile(
                title: const Text('Matchday Lineups'),
                subtitle: const Text('Notifications when the final roster is locked'),
                value: _matchdayLineups,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => _matchdayLineups = val);
                  _onPreferenceChanged();
                },
              ),

              const Divider(height: AppSpacing.xxl),

              _buildSectionHeader('DELIVERY TIMING'),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  'Choose how you want to receive less urgent notifications like group announcements or weekly roundups.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DeliveryOptionTile(
                title: 'Immediate',
                subtitle: 'Send notifications as soon as they happen',
                value: 'immediate',
                groupValue: _deliveryTiming,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _deliveryTiming = val);
                    _onPreferenceChanged();
                  }
                },
              ),
              _DeliveryOptionTile(
                title: 'Daily Digest',
                subtitle: 'Group everything into one notification per day',
                value: 'daily_digest',
                groupValue: _deliveryTiming,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _deliveryTiming = val);
                    _onPreferenceChanged();
                  }
                },
              ),
              _DeliveryOptionTile(
                title: 'Quiet Hours',
                subtitle: 'Pause non-urgent alerts between 11 PM and 7 AM',
                value: 'quiet_hours',
                groupValue: _deliveryTiming,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _deliveryTiming = val);
                    _onPreferenceChanged();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
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
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: AppColors.primary,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}