import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myDuesAsync = ref.watch(myDuesNotifierProvider(widget.groupId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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

          Expanded(
            child: myDuesAsync.when(
              loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
              error: (_, _) => AppErrorState(
                message: 'Failed to load your dues',
                onRetry: () => ref.invalidate(myDuesNotifierProvider(widget.groupId)),
              ),
              data: (dues) {
                if (_gameWise) {
                  // ── Pending Dues tab (unchanged) ──────────────────────────
                  final pending = dues.where((d) =>
                    d.status == DueStatus.unpaid ||
                    d.status == DueStatus.pendingVerification,
                  ).toList();

                  if (pending.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.check_circle_outline,
                      message: "You're all caught up ✓",
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(myDuesNotifierProvider(widget.groupId)),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                      itemCount: pending.length,
                      itemBuilder: (ctx, index) =>
                          _DueCard(due: pending[index], fallbackUpiId: widget.defaultUpiId, showSettle: true),
                    ),
                  );
                }

                // ── Ledger tab — chronological month-grouped feed ──────────
                if (dues.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No payment history yet.',
                  );
                }

                // Sort descending by game date
                final sorted = [...dues]
                  ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

                // Group by month label
                final grouped = <String, List<PaymentDue>>{};
                for (final due in sorted) {
                  final month = DateFormat('MMMM yyyy').format(due.scheduledAt);
                  grouped.putIfAbsent(month, () => []).add(due);
                }

                final monthKeys = grouped.keys.toList();

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(myDuesNotifierProvider(widget.groupId)),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                    itemCount: monthKeys.fold<int>(
                        0, (sum, k) => sum + 1 + grouped[k]!.length),
                    itemBuilder: (ctx, flatIndex) {
                      // Flatten month headers + items into a single list
                      int cursor = 0;
                      for (final month in monthKeys) {
                        if (flatIndex == cursor) {
                          // Month header
                          return _MonthHeader(month: month);
                        }
                        cursor++;
                        final items = grouped[month]!;
                        if (flatIndex < cursor + items.length) {
                          final due = items[flatIndex - cursor];
                          return _DueCard(
                            due: due,
                            fallbackUpiId: widget.defaultUpiId,
                            showSettle: due.status == DueStatus.unpaid,
                          );
                        }
                        cursor += items.length;
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Month header widget ──────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final String month;
  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.base, bottom: AppSpacing.xs),
      child: Text(
        month.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Due card widget ──────────────────────────────────────────────────────────

class _DueCard extends StatelessWidget {
  final PaymentDue due;
  final String fallbackUpiId;
  final bool showSettle;

  const _DueCard({
    required this.due,
    required this.fallbackUpiId,
    required this.showSettle,
  });

  Color _stripeColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return switch (due.status) {
      DueStatus.paid                => cs.primary,
      DueStatus.unpaid              => cs.error,
      DueStatus.pendingVerification => cs.tertiary,
      DueStatus.rejected            => cs.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final double rupees = due.amountPaise / 100.0;
    final formattedDate = DateFormat('MMM d, yyyy').format(due.scheduledAt);
    final stripe = _stripeColor(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      elevation: 0,
      color: cs.surfaceContainer,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Status stripe
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: stripe,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  bottomLeft: Radius.circular(AppRadius.lg),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base, vertical: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Title + meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(due.gameTitle, style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 2),
                          Text(formattedDate, style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          )),
                          const SizedBox(height: 4),
                          StatusBadge(status: due.status),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Amount + settle button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '₹${rupees.toStringAsFixed(0)}',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: due.status == DueStatus.paid ? cs.primary : cs.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (showSettle) ...[
                          const SizedBox(height: 4),
                          Builder(
                            builder: (ctx) => ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: cs.onPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md),
                                minimumSize: const Size(0, 30),
                              ),
                              onPressed: () {
                                showAppBottomSheet(
                                  context: ctx,
                                  title: 'Settle Payment',
                                  child: SettlePaymentSheet(
                                      due: due, fallbackUpiId: fallbackUpiId),
                                );
                              },
                              child: const Text('Settle',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
