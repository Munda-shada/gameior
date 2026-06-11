import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/dues_hero_card.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/features/feed/presentation/widgets/dues_payment_sheet.dart';

class FeedDuesSection extends ConsumerWidget {
  const FeedDuesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duesSummaryAsync = ref.watch(feedDuesSummaryProvider);

    return duesSummaryAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        child: AppLoadingShimmer(type: ShimmerType.paymentRow),
      ),
      error: (e, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
        child: AppErrorState(
          message: 'Failed to load dues',
          onRetry: () => ref.invalidate(feedDuesSummaryProvider),
        ),
      ),
      data: (summary) {
        if (summary.totalPaise <= 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base, 0, AppSpacing.base, AppSpacing.base,
          ),
          child: DuesHeroCard(
            amountPaise: summary.totalPaise,
            label: 'You owe across ${summary.groupCount} group${summary.groupCount > 1 ? 's' : ''}',
            ctaLabel: 'Pay',
            onTap: () {
              showAppBottomSheet(
                context: context,
                title: 'Outstanding Dues',
                initialChildSizeRatio: 0.7,
                child: FeedDuesSheet(summary: summary),
              );
            },
          ),
        );
      },
    );
  }
}
