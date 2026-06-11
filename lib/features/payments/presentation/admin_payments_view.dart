import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/core/utils/app_toast.dart';

import 'package:gameior/features/payments/presentation/widgets/custom_segmented_control.dart';
import 'package:gameior/features/payments/presentation/widgets/status_badge.dart';
import 'package:gameior/features/payments/presentation/widgets/auto_approve_settings_sheet.dart';

class AdminPaymentsView extends ConsumerStatefulWidget {
  final String groupId;
  const AdminPaymentsView({required this.groupId, super.key});

  @override
  ConsumerState<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends ConsumerState<AdminPaymentsView> {
  bool _byPlayer = true;
  bool _isReminding = false;
  final Set<String> _expandedIds = {};

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filterPlayerId = ref.watch(paymentsPlayerFilterProvider(widget.groupId));
    if (filterPlayerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          setState(() {
            _byPlayer = true;
            _expandedIds.add(filterPlayerId);
          });
          ref.read(paymentsPlayerFilterProvider(widget.groupId).notifier).set(null);
        }
      });
    }
    final byPlayerAsync = ref.watch(adminDuesByPlayerProvider(widget.groupId));
    final byGameAsync = ref.watch(adminDuesByGameProvider(widget.groupId));

    final hasDues = _byPlayer ? (byPlayerAsync.valueOrNull?.isNotEmpty ?? false) : (byGameAsync.valueOrNull?.isNotEmpty ?? false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          // Top settings and toggle bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: CustomSegmentedControl(
                    label1: 'By Player',
                    label2: 'By Game',
                    isFirstSelected: _byPlayer,
                    onSelected: (val) {
                      setState(() {
                        _byPlayer = val;
                        _expandedIds.clear();
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () {
                    showAppBottomSheet(
                      context: context,
                      title: 'Payments Settings',
                      child: AutoApproveSettingsBottomSheet(groupId: widget.groupId),
                    );
                  },
                ),
              ],
            ),
          ),

          if (hasDues)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base).copyWith(bottom: AppSpacing.sm),
              child: AppButton(
                label: 'Remind Pending Dues',
                leadingIcon: Icons.notifications_active_outlined,
                variant: AppButtonVariant.secondary,
                isLoading: _isReminding,
                onPressed: _isReminding
                    ? null
                    : () async {
                        setState(() => _isReminding = true);
                        try {
                          await ref
                              .read(adminDuesNotifierProvider(widget.groupId).notifier)
                              .triggerReminders();
                          if (context.mounted) {
                            showToast(context, 'Reminders sent to all members with pending dues!');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            showToast(context, 'Failed to send reminders: $e', isError: true);
                          }
                        } finally {
                          if (context.mounted) {
                            setState(() => _isReminding = false);
                          }
                        }
                      },
              ),
            ),

          Expanded(
            child: _byPlayer
                ? byPlayerAsync.when(
                    loading: () => const AppLoadingShimmer(type: ShimmerType.card),
                    error: (_, __) => AppErrorState(
                      message: 'Failed to load player dues summary',
                      onRetry: () => ref.invalidate(adminDuesNotifierProvider(widget.groupId)),
                    ),
                    data: (summaries) {
                      if (summaries.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.check_circle_outline,
                          message: "You're all caught up ✓",
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => ref.invalidate(adminDuesNotifierProvider(widget.groupId)),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                          itemCount: summaries.length,
                          itemBuilder: (ctx, index) {
                            final summary = summaries[index];
                            final isExpanded = _expandedIds.contains(summary.playerId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                              clipBehavior: Clip.antiAlias,
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainer,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: _PlayerAvatar(summary.playerEmoji),
                                    title: Text(summary.playerName, style: theme.textTheme.headlineSmall),
                                    subtitle: Text('${summary.gameCount} pending match${summary.gameCount > 1 ? 'es' : ''}', style: theme.textTheme.bodySmall),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${(summary.totalPendingPaise / 100.0).toStringAsFixed(0)}',
                                          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.error),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                      ],
                                    ),
                                    onTap: () => _toggleExpand(summary.playerId),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(height: 1),
                                    ...summary.dues.map((due) => _buildPlayerDueRow(due, theme)),
                                  ]
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : byGameAsync.when(
                    loading: () => const AppLoadingShimmer(type: ShimmerType.card),
                    error: (_, __) => AppErrorState(
                      message: 'Failed to load game dues summary',
                      onRetry: () => ref.invalidate(adminDuesNotifierProvider(widget.groupId)),
                    ),
                    data: (summaries) {
                      if (summaries.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.check_circle_outline,
                          message: "You're all caught up ✓",
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async => ref.invalidate(adminDuesNotifierProvider(widget.groupId)),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                          itemCount: summaries.length,
                          itemBuilder: (ctx, index) {
                            final summary = summaries[index];
                            final isExpanded = _expandedIds.contains(summary.gameId);
                            final formattedDate = DateFormat('MMM d, h:mm a').format(summary.scheduledAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                              clipBehavior: Clip.antiAlias,
                              elevation: 0,
                              color: theme.colorScheme.surfaceContainer,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(summary.gameTitle, style: theme.textTheme.headlineSmall),
                                    subtitle: Text('$formattedDate • ${summary.unpaidCount} unpaid', style: theme.textTheme.bodySmall),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${(summary.totalPendingPaise / 100.0).toStringAsFixed(0)}',
                                          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.error),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                      ],
                                    ),
                                    onTap: () => _toggleExpand(summary.gameId),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(height: 1),
                                    ...summary.playerDues.map((item) => _buildGameApprovalRow(item, theme)),
                                  ]
                                ],
                              ),
                            );
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

  Widget _buildPlayerDueRow(PaymentDue due, ThemeData theme) {
    final double rupees = due.amountPaise / 100.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(due.gameTitle, style: theme.textTheme.labelLarge),
                const SizedBox(height: 2),
                StatusBadge(status: due.status),
              ],
            ),
          ),
          Row(
            children: [
              Text('₹${rupees.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall),
              const SizedBox(width: AppSpacing.sm),
              if (due.status != DueStatus.paid)
                TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).markPaid(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      showToast(context, 'Failed to mark as paid.', isError: true);
                    }
                  },
                  child: const Text('Mark Paid'),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGameApprovalRow(GamePlayerDue item, ThemeData theme) {
    final due = item.due;
    final double rupees = due.amountPaise / 100.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          _PlayerAvatar(item.playerEmoji),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.playerName, style: theme.textTheme.labelLarge),
                if (due.utrReference != null)
                  Text('UTR: ${due.utrReference}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface)),
                const SizedBox(height: 2),
                StatusBadge(status: due.status),
              ],
            ),
          ),
          Row(
            children: [
              Text('₹${rupees.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall),
              const SizedBox(width: AppSpacing.sm),
              if (due.status == DueStatus.pendingVerification) ...[
                IconButton(
                  icon: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).approve(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      showToast(context, 'Verification approval failed.', isError: true);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.cancel_outlined, color: theme.colorScheme.error),
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).reject(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      showToast(context, 'Verification rejection failed.', isError: true);
                    }
                  },
                ),
              ] else if (due.status != DueStatus.paid)
                TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).markPaid(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      showToast(context, 'Failed to mark as paid.', isError: true);
                    }
                  },
                  child: const Text('Mark Paid'),
                ),
            ],
          )
        ],
      ),
    );
  }
}

class _PlayerAvatar extends StatelessWidget {
  final String emoji;
  const _PlayerAvatar(this.emoji);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}
