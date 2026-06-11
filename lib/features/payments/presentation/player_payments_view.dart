import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';

import 'package:gameior/features/payments/presentation/widgets/custom_segmented_control.dart';
import 'package:gameior/features/payments/presentation/widgets/status_badge.dart';
import 'package:gameior/features/payments/presentation/widgets/settle_payment_sheet.dart';

class PlayerPaymentsView extends ConsumerStatefulWidget {
  final String groupId;
  final String defaultUpiId;
  const PlayerPaymentsView({required this.groupId, required this.defaultUpiId, super.key});

  @override
  ConsumerState<PlayerPaymentsView> createState() => _PlayerPaymentsViewState();
}

class _PlayerPaymentsViewState extends ConsumerState<PlayerPaymentsView> {
  bool _gameWise = true;
  String _activeFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final myDuesAsync = ref.watch(myDuesNotifierProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: CustomSegmentedControl(
              label1: 'Pending Dues',
              label2: 'Payment Ledger',
              isFirstSelected: _gameWise,
              onSelected: (val) {
                setState(() {
                  _gameWise = val;
                });
              },
            ),
          ),

          if (!_gameWise)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.base, right: AppSpacing.base, bottom: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Paid', 'Unpaid', 'Pending'].map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _activeFilter = filter;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          Expanded(
            child: myDuesAsync.when(
              loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
              error: (_, __) => AppErrorState(
                message: 'Failed to load your dues',
                onRetry: () => ref.invalidate(myDuesNotifierProvider(widget.groupId)),
              ),
              data: (dues) {
                final filtered = dues.where((due) {
                  if (_gameWise) {
                    return due.status == DueStatus.unpaid || due.status == DueStatus.pendingVerification;
                  } else {
                    if (_activeFilter == 'Paid') return due.status == DueStatus.paid;
                    if (_activeFilter == 'Unpaid') return due.status == DueStatus.unpaid;
                    if (_activeFilter == 'Pending') return due.status == DueStatus.pendingVerification;
                    return true;
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.check_circle_outline,
                    message: "You're all caught up ✓",
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(myDuesNotifierProvider(widget.groupId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final due = filtered[index];
                      final double rupees = due.amountPaise / 100.0;
                      final formattedDate = DateFormat('MMM d, yyyy').format(due.scheduledAt);

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                        elevation: 0,
                        color: AppColors.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.xs),
                          title: Text(due.gameTitle, style: AppTextStyles.headlineSmall),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formattedDate, style: AppTextStyles.caption),
                              const SizedBox(height: 4),
                              StatusBadge(status: due.status),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${rupees.toStringAsFixed(0)}',
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: due.status == DueStatus.paid ? AppColors.primaryDark : AppColors.destructive,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              if (_gameWise && due.status == DueStatus.unpaid)
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                  ),
                                  onPressed: () {
                                    showAppBottomSheet(
                                      context: context,
                                      title: 'Settle Payment',
                                      child: SettlePaymentSheet(due: due, fallbackUpiId: widget.defaultUpiId),
                                    );
                                  },
                                  child: const Text('Settle'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
