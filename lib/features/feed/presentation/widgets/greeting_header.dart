import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

class GreetingHeader extends StatelessWidget {
  final AsyncValue<dynamic> profileAsync;
  final String Function() getGreeting;

  const GreetingHeader({
    required this.profileAsync,
    required this.getGreeting,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.base,
        left: AppSpacing.base,
        right: AppSpacing.base,
        bottom: AppSpacing.base,
      ),
      child: profileAsync.when(
        loading: () => const SizedBox(height: 56),
        error: (_, __) => const SizedBox(height: 56),
        data: (profile) {
          final name = profile?.displayName ?? '';
          final emoji = profile?.emoji ?? '🏸';
          final greeting = getGreeting();

          return Row(
            children: [
              // Emoji avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      name.isEmpty ? 'Welcome back!' : name,
                      style: AppTextStyles.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
