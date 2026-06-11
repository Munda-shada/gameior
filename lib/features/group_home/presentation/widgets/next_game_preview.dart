import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_home/application/group_home_providers.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class NextGamePreview extends ConsumerWidget {
  final String groupId;
  final bool isAdmin;

  const NextGamePreview({
    required this.groupId,
    required this.isAdmin,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextGameAsync = ref.watch(nextGroupGameProvider(groupId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'NEXT SESSION'),
        nextGameAsync.when(
          loading: () => const SizedBox(
            height: 120,
            child: AppLoadingShimmer(type: ShimmerType.card),
          ),
          error: (err, _) => const AppErrorState(
            message: 'Failed to load next session',
          ),
          data: (game) {
            if (game == null) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.base),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 36, color: AppColors.textDisabled),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('No sessions scheduled yet', style: AppTextStyles.bodyMedium),
                    if (isAdmin) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Schedule a Game',
                        variant: AppButtonVariant.secondary,
                        isFullWidth: false,
                        onPressed: () {
                          // Switch to Sessions tab (index 1)
                          ref.read(groupWorkspaceTabProvider(groupId).notifier).state = 1;
                        },
                      ),
                    ],
                  ],
                ),
              );
            }

            final scheduledAt = DateTime.parse(game['scheduled_at'] as String).toLocal();
            final formattedTime = DateFormat('EEE, MMM d • h:mm a').format(scheduledAt);
            final desc = game['description'] as String?;

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () => context.push('/group/$groupId/game/${game['id']}'),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🏸', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  game['title'] as String? ?? 'Match Session',
                                  style: AppTextStyles.headlineMedium,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formattedTime,
                                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                        ],
                      ),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              game['venue'] as String? ?? 'Default venue',
                              style: AppTextStyles.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (desc != null && desc.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          desc,
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
