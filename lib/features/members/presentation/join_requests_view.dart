import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/members/application/members_providers.dart';
import 'package:gameior/features/members/domain/member.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/core/utils/app_toast.dart';

class JoinRequestsView extends ConsumerWidget {
  final String groupId;
  const JoinRequestsView({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(groupJoinRequestsProvider(groupId));

    return requestsAsync.when(
      loading: () => const SingleChildScrollView(
        child: Column(
          children: [
            AppLoadingShimmer(type: ShimmerType.memberRow),
            AppLoadingShimmer(type: ShimmerType.memberRow),
            AppLoadingShimmer(type: ShimmerType.memberRow),
          ],
        ),
      ),
      error: (e, _) => AppErrorState(
        message: 'Failed to load join requests: $e',
        onRetry: () => ref.invalidate(groupJoinRequestsProvider(groupId)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return const AppEmptyState(
            message: 'No pending join requests.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(groupJoinRequestsProvider(groupId)),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.base),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  side: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.border.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(req.emoji, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.base),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.displayName, style: AppTextStyles.headlineSmall),
                                const SizedBox(height: 2),
                                Text(req.phone, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.base),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Reject',
                              variant: AppButtonVariant.ghost,
                              onPressed: () async {
                                await ref
                                    .read(groupJoinRequestsProvider(groupId).notifier)
                                    .reject(userId: req.userId);
                                if (context.mounted) {
                                  showToast(context, 'Join request for ${req.displayName} rejected.');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppButton(
                              label: 'Accept',
                              onPressed: () async {
                                await ref
                                    .read(groupJoinRequestsProvider(groupId).notifier)
                                    .approve(userId: req.userId);
                                if (context.mounted) {
                                  showToast(context, 'Join request for ${req.displayName} accepted!');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
