import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/features/auth/data/auth_repository.dart';
import 'package:gameior/shared/widgets/app_dialog.dart';
import 'package:gameior/features/profile/application/signup_provider.dart';
import 'package:gameior/core/router/route_names.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const AppLoadingShimmer(),
        error: (e, _) => AppErrorState(
          message: 'Failed to load profile',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return ListView(
            children: [
              // Profile hero card
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Text(profile.emoji,
                         style: const TextStyle(fontSize: 48)),
                    const SizedBox(width: AppSpacing.base),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(profile.displayName,
                             style: AppTextStyles.headlineMedium),
                        if (profile.phone != null)
                          Text(profile.phone!,
                               style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.profileEdit),
              ),
              const Divider(),
              ListTile(
                title: const Text('Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.profileNotifications),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Logout',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.destructive),
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
              const Divider(),
              ListTile(
                title: Text(
                  'Delete Account',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppColors.destructive),
                ),
                onTap: () => context.push(Routes.profileDelete),
              ),
            ],
          );
        },
      ),
    );
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
      // Router auto-redirects to /login via authStateProvider
    }
  }
}