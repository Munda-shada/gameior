import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/features/auth/application/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    // Show error toast if auth fails
    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        showToast(context, 'Sign in failed. Please try again.', isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo + tagline
              Text('🏸', style: TextStyle(fontSize: 72)),
              const SizedBox(height: AppSpacing.base),
              Text('Gameior', style: AppTextStyles.displayLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Play more. Organize less.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(flex: 3),
              // Google button
              AppButton(
                label: 'Continue with Google',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.g_mobiledata, // replace with Google SVG
                isLoading: isLoading,
                onPressed: isLoading
                    ? null
                    : () => ref.read(authNotifierProvider.notifier)
                              .signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.md),
              // Apple button (show only on iOS)
              if (Theme.of(context).platform == TargetPlatform.iOS)
                AppButton(
                  label: 'Continue with Apple',
                  variant: AppButtonVariant.secondary,
                  leadingIcon: Icons.apple,
                  isLoading: isLoading,
                  onPressed: isLoading
                      ? null
                      : () => ref.read(authNotifierProvider.notifier)
                                .signInWithApple(),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}