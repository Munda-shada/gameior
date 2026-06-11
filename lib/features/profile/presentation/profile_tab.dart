import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_shadows.dart';
import 'package:gameior/core/theme/theme_provider.dart';
import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/auth/data/auth_repository.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/features/profile/domain/profile.dart';
import 'package:gameior/features/profile/data/profile_repository.dart';
import 'package:gameior/features/profile/application/profile_providers.dart';
import 'package:gameior/core/router/route_names.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProvider);
    final statsAsync = ref.watch(globalProfileStatsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const AppLoadingShimmer(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load profile',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            children: [
              // Hero Section
              _buildHeroSection(context, profile),

              // Stats Grid Section
              statsAsync.when(
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Center(child: Text('Failed to load statistics: $e')),
                data: (stats) => _buildStatsGrid(context, stats),
              ),

              const SizedBox(height: AppSpacing.md),

              // Menu: Account Section
              _buildSectionHeader(context, 'Account'),
              _buildMenuItem(
                context,
                emoji: '📝',
                label: 'Edit Display Profile',
                onTap: () => context.push(Routes.profileEdit),
              ),
              _buildMenuItem(
                context,
                emoji: '🔔',
                label: 'Notification Settings',
                onTap: () => context.push(Routes.profileNotifications),
              ),
              _buildMenuItem(
                context,
                emoji: '🔕',
                label: 'Muted Groups',
                onTap: () => _showMutedGroupsSheet(context),
              ),
              _buildMenuItem(
                context,
                emoji: '💳',
                label: 'UPI Payment Settings',
                onTap: () => _showUpiSettingsSheet(context, ref, profile),
              ),
              _buildThemeMenuItem(context, ref),

              // Menu: Support & Legal Section
              _buildSectionHeader(context, 'Support & Legal'),
              _buildMenuItem(
                context,
                emoji: '📧',
                label: 'Help Centre & FAQ',
                onTap: () => _launchExternalUrl(context, AppConstants.helpCentreUrl),
              ),
              _buildMenuItem(
                context,
                emoji: '📄',
                label: 'Terms of Service',
                onTap: () => _launchExternalUrl(context, AppConstants.termsOfServiceUrl),
              ),
              _buildMenuItem(
                context,
                emoji: '🔒',
                label: 'Privacy Policy',
                onTap: () => _launchExternalUrl(context, AppConstants.privacyPolicyUrl),
              ),

              // Menu: Danger Zone
              _buildSectionHeader(
                context,
                'Danger Zone',
                color: colorScheme.error,
              ),
              _buildMenuItem(
                context,
                emoji: '⚠️',
                label: 'Delete Account',
                isDanger: true,
                onTap: () => context.push(Routes.profileDelete),
              ),
              _buildMenuItem(
                context,
                emoji: '🚪',
                label: 'Log Out',
                isDanger: true,
                onTap: () => _confirmLogout(context, ref),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, Profile profile) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          // Glowing circular Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 2),
              boxShadow: isDark ? AppShadows.glow(colorScheme.primary) : null,
            ),
            child: Center(
              child: Text(
                profile.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.displayName,
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (profile.phone != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              profile.phone!,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final attendanceVal = stats['attendancePct'] as double;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: [
        _buildStatTile(
          context,
          value: '${stats['gamesPlayed']}',
          label: 'Played',
          valueColor: colorScheme.primary,
        ),
        _buildStatTile(
          context,
          value: '${attendanceVal.toStringAsFixed(0)}%',
          label: 'Attend %',
          valueColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF10FF70) : colorScheme.primary,
        ),
        _buildStatTile(
          context,
          value: '${stats['groupsCount']}',
          label: 'Groups',
          valueColor: colorScheme.tertiary,
        ),
        _buildStatTile(
          context,
          value: '${stats['upcomingGames']}',
          label: 'Upcoming',
          valueColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFFFAD00) : colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildStatTile(BuildContext context, {
    required String value,
    required String label,
    required Color valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFamily: 'Outfit',
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {Color? color}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        top: AppSpacing.lg,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: color ?? colorScheme.onSurfaceVariant,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required String emoji,
    required String label,
    String? trailingText,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDanger ? colorScheme.error : colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (trailingText != null) ...[
                    Text(
                      trailingText,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeMenuItem(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    String modeText = 'System Default';
    if (themeMode == ThemeMode.light) {
      modeText = 'Light Theme';
    } else if (themeMode == ThemeMode.dark) {
      modeText = 'Dark Theme';
    }

    return _buildMenuItem(
      context,
      emoji: '🎨',
      label: 'Theme Mode',
      trailingText: modeText,
      onTap: () => _showThemeSelector(context, ref),
    );
  }

  void _showThemeSelector(BuildContext context, WidgetRef ref) {
    final currentMode = ref.read(themeModeProvider);
    showAppBottomSheet(
      context: context,
      title: 'Choose Theme Mode',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('System Default'),
            trailing: currentMode == ThemeMode.system
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Light Theme'),
            trailing: currentMode == ThemeMode.light
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Dark Theme'),
            trailing: currentMode == ThemeMode.dark
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showMutedGroupsSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      title: 'Muted Groups',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final mutedGroups = ['Sunday Football Crew', 'Casual Cricket Group'];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Muted groups won\'t send FCM notifications until unmuted.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              if (mutedGroups.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Text('No muted groups'),
                  ),
                )
              else
                ...mutedGroups.map((name) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
                          minimumSize: const Size(60, 28),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                          side: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        onPressed: () {
                          showToast(context, '$name unmuted!');
                          Navigator.pop(context);
                        },
                        child: const Text('Unmute', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                )),
            ],
          );
        }
      ),
    );
  }

  void _showUpiSettingsSheet(BuildContext context, WidgetRef ref, Profile profile) {
    final controller = TextEditingController(text: profile.upiId ?? '');
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showAppBottomSheet(
      context: context,
      title: 'UPI Payment Settings',
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          final colorScheme = Theme.of(context).colorScheme;
          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your default UPI ID is used when you host sessions. Players will see this to make payments.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Your UPI ID',
                    hintText: 'name@upi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      if (!val.contains('@')) return 'Enter a valid UPI ID (e.g. name@upi)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Linked UPI Apps',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: const Column(
                          children: [
                            Text('📱', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 4),
                            Text('PhonePe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.5)),
                        ),
                        child: Column(
                          children: [
                            Text('G', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                            const SizedBox(height: 4),
                            Text('GPay ✓', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                        ),
                        child: const Column(
                          children: [
                            Text('🏦', style: TextStyle(fontSize: 22)),
                            SizedBox(height: 4),
                            Text('Paytm', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onPressed: isSaving
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) return;
                            setSheetState(() => isSaving = true);
                            try {
                              await ref.read(profileRepositoryProvider).updateUpiId(
                                    userId: profile.id,
                                    upiId: controller.text.trim().isEmpty ? null : controller.text.trim(),
                                  );
                              ref.invalidate(currentUserProvider);
                              ref.invalidate(globalProfileStatsProvider);
                              if (context.mounted) {
                                showToast(context, 'UPI settings saved!');
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (context.mounted) {
                                showToast(context, 'Failed to save UPI settings: $e', isError: true);
                              }
                            } finally {
                              setSheetState(() => isSaving = false);
                            }
                          },
                    child: isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary)),
                          )
                        : const Text('Save UPI Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Future<void> _launchExternalUrl(BuildContext context, String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          showToast(context, 'Could not open link: $urlString', isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) {
        showToast(context, 'Error launching link: $e', isError: true);
      }
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showAppDialog(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      isDestructive: true,
    );
    if (confirm == true) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }
}