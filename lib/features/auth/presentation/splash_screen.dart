import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Router handles all redirects via authStateProvider stream.
    // This screen just shows a loader while the stream evaluates.
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo placeholder — replace with actual asset
            Text('🏸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.xl),
            Text('Gameior', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.xxxl),
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}