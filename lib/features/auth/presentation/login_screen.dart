import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/constants/app_constants.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/features/auth/application/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _agreeToTerms = false;
  late TapGestureRecognizer _termsRecognizer;
  late TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _onTermsTap;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _onPrivacyTap;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _onTermsTap() {
    _launchExternalUrl(AppConstants.termsOfServiceUrl);
  }

  void _onPrivacyTap() {
    _launchExternalUrl(AppConstants.privacyPolicyUrl);
  }

  Future<void> _launchExternalUrl(String urlString) async {
    final url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          showToast(context, 'Could not open link: $urlString', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Could not open link: $urlString', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    // Show error toast if auth fails
    ref.listen(authNotifierProvider, (_, next) {
      if (next.hasError) {
        showToast(context, 'Sign in failed. Please try again.', isError: true);
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo + tagline
              const Text('🏸', style: TextStyle(fontSize: 72)),
              const SizedBox(height: AppSpacing.base),
              Text(
                'Gameior',
                style: theme.textTheme.displayLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Play more. Organize less.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(flex: 3),
              // Google button
              AppButton(
                label: 'Continue with Google',
                variant: AppButtonVariant.secondary,
                leadingIcon: Icons.g_mobiledata, // replace with Google SVG
                isLoading: isLoading,
                onPressed: (isLoading || !_agreeToTerms)
                    ? null
                    : () => ref.read(authNotifierProvider.notifier)
                              .signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.md),
              // Apple button (show only on iOS)
              if (theme.platform == TargetPlatform.iOS) ...[
                AppButton(
                  label: 'Continue with Apple',
                  variant: AppButtonVariant.secondary,
                  leadingIcon: Icons.apple,
                  isLoading: isLoading,
                  onPressed: (isLoading || !_agreeToTerms)
                      ? null
                      : () => ref.read(authNotifierProvider.notifier)
                                .signInWithApple(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // Terms checkbox row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    activeColor: theme.colorScheme.primary,
                    checkColor: theme.colorScheme.onPrimary,
                    onChanged: isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: _termsRecognizer,
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: _privacyRecognizer,
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}