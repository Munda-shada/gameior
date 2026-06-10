import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_error_state.dart';
import 'package:gameior/shared/widgets/app_loading_shimmer.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';

class PaymentsTab extends ConsumerWidget {
  final String groupId;
  const PaymentsTab({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextAsync = ref.watch(groupContextProvider(groupId));

    return contextAsync.when(
      loading: () => const AppLoadingShimmer(type: ShimmerType.listTile),
      error: (e, _) => AppErrorState(
        message: 'Failed to load payments context',
        onRetry: () => ref.invalidate(groupContextProvider(groupId)),
      ),
      data: (groupCtx) {
        final role = groupCtx.myRole;
        final isAdmin = role == MemberRole.host || role == MemberRole.coHost;

        if (isAdmin) {
          return AdminPaymentsView(groupId: groupId);
        } else {
          return PlayerPaymentsView(groupId: groupId, defaultUpiId: groupCtx.group.defaultUpiId ?? '');
        }
      },
    );
  }
}

// ─── ADMIN VIEW ──────────────────────────────────────────

class AdminPaymentsView extends ConsumerStatefulWidget {
  final String groupId;
  const AdminPaymentsView({required this.groupId, super.key});

  @override
  ConsumerState<AdminPaymentsView> createState() => _AdminPaymentsViewState();
}

class _AdminPaymentsViewState extends ConsumerState<AdminPaymentsView> {
  bool _byPlayer = true;
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
    final byPlayerAsync = ref.watch(adminDuesByPlayerProvider(widget.groupId));
    final byGameAsync = ref.watch(adminDuesByGameProvider(widget.groupId));

    return Scaffold(
      backgroundColor: AppColors.background,
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
                  icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
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
                              color: AppColors.surface,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: _PlayerAvatar(summary.playerEmoji),
                                    title: Text(summary.playerName, style: AppTextStyles.headlineSmall),
                                    subtitle: Text('${summary.gameCount} pending match${summary.gameCount > 1 ? 'es' : ''}', style: AppTextStyles.bodySmall),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${(summary.totalPendingPaise / 100.0).toStringAsFixed(0)}',
                                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.destructive),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textDisabled),
                                      ],
                                    ),
                                    onTap: () => _toggleExpand(summary.playerId),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(height: 1),
                                    ...summary.dues.map((due) => _buildPlayerDueRow(due)),
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
                              color: AppColors.surface,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(summary.gameTitle, style: AppTextStyles.headlineSmall),
                                    subtitle: Text('$formattedDate • ${summary.unpaidCount} unpaid', style: AppTextStyles.bodySmall),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${(summary.totalPendingPaise / 100.0).toStringAsFixed(0)}',
                                          style: AppTextStyles.headlineLarge.copyWith(color: AppColors.destructive),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textDisabled),
                                      ],
                                    ),
                                    onTap: () => _toggleExpand(summary.gameId),
                                  ),
                                  if (isExpanded) ...[
                                    const Divider(height: 1),
                                    ...summary.playerDues.map((item) => _buildGameApprovalRow(item)),
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

  Widget _buildPlayerDueRow(PaymentDue due) {
    final double rupees = due.amountPaise / 100.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(due.gameTitle, style: AppTextStyles.labelLarge),
                const SizedBox(height: 2),
                _StatusBadge(due.status),
              ],
            ),
          ),
          Row(
            children: [
              Text('₹${rupees.toStringAsFixed(0)}', style: AppTextStyles.headlineSmall),
              const SizedBox(width: AppSpacing.sm),
              if (due.status != DueStatus.paid)
                TextButton(
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).markPaid(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to mark as paid.')),
                      );
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

  Widget _buildGameApprovalRow(GamePlayerDue item) {
    final due = item.due;
    final double rupees = due.amountPaise / 100.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _PlayerAvatar(item.playerEmoji),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.playerName, style: AppTextStyles.labelLarge),
                if (due.utrReference != null)
                  Text('UTR: ${due.utrReference}', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                _StatusBadge(due.status),
              ],
            ),
          ),
          Row(
            children: [
              Text('₹${rupees.toStringAsFixed(0)}', style: AppTextStyles.headlineSmall),
              const SizedBox(width: AppSpacing.sm),
              if (due.status == DueStatus.pendingVerification) ...[
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).approve(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification approval failed.')),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: AppColors.destructive),
                  onPressed: () async {
                    try {
                      await ref.read(adminDuesNotifierProvider(widget.groupId).notifier).reject(due.id);
                      ref.invalidate(adminDuesNotifierProvider(widget.groupId));
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Verification rejection failed.')),
                      );
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to mark as paid.')),
                      );
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

// ─── PLAYER VIEW ──────────────────────────────────────────

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
                              _StatusBadge(due.status),
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
                                      child: _SettlePaymentSheet(due: due, fallbackUpiId: widget.defaultUpiId),
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

class _SettlePaymentSheet extends ConsumerStatefulWidget {
  final PaymentDue due;
  final String fallbackUpiId;
  const _SettlePaymentSheet({required this.due, required this.fallbackUpiId});

  @override
  ConsumerState<_SettlePaymentSheet> createState() => _SettlePaymentSheetState();
}

class _SettlePaymentSheetState extends ConsumerState<_SettlePaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _launchUpiApp(String upiId, int amountPaise, String title) async {
    final formattedAmount = (amountPaise / 100.0).toStringAsFixed(2);
    final upiUrl = 'upi://pay?'
        'pa=$upiId'
        '&am=$formattedAmount'
        '&tn=${Uri.encodeComponent(title)}'
        '&cu=INR';

    final uri = Uri.parse(upiUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No UPI apps found. Please pay manually.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch UPI app. Please pay manually.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final utr = _utrController.text.trim();

    try {
      await ref.read(myDuesNotifierProvider(widget.due.groupId).notifier).submitUtr(
            dueId: widget.due.id,
            utrReference: utr,
          );
      ref.invalidate(myDuesNotifierProvider(widget.due.groupId));
      
      // Also invalidate context/dues summaries if needed
      ref.invalidate(groupContextProvider(widget.due.groupId));

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted successfully for verification!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final upiId = widget.due.games?['upi_id'] as String? ?? widget.fallbackUpiId;
    final gameTitle = widget.due.gameTitle;
    final amountPaise = widget.due.amountPaise;

    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.base,
          right: AppSpacing.base,
          top: AppSpacing.base,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(gameTitle, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(child: SelectableText('Pay to UPI: $upiId', style: AppTextStyles.bodyMedium)),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: upiId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UPI ID copied!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.base),
            
            Container(
              padding: const EdgeInsets.all(AppSpacing.base),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dues Payable', style: AppTextStyles.headlineSmall),
                  Text(
                    '₹${(amountPaise / 100.0).toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.base),

            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open UPI App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                elevation: 0,
              ),
              onPressed: () => _launchUpiApp(upiId, amountPaise, gameTitle),
            ),
            const SizedBox(height: AppSpacing.base),

            AppTextField(
              controller: _utrController,
              label: '12-digit UPI Transaction Ref (UTR)',
              hint: 'E.g. 408712345678',
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'UTR is required.';
                if (v.length != 12) return 'UTR must be exactly 12 digits.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.base),

            AppButton(
              label: 'Submit UTR Reference',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── UTILITY WIDGETS ──────────────────────────────────────

class CustomSegmentedControl extends StatelessWidget {
  final String label1;
  final String label2;
  final bool isFirstSelected;
  final ValueChanged<bool> onSelected;

  const CustomSegmentedControl({
    super.key,
    required this.label1,
    required this.label2,
    required this.isFirstSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isFirstSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  label1,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isFirstSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: !isFirstSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  label2,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: !isFirstSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
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
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final DueStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade600;
    String label = 'UNPAID';

    switch (status) {
      case DueStatus.unpaid:
        bg = AppColors.destructiveMuted;
        fg = AppColors.destructive;
        label = 'UNPAID';
        break;
      case DueStatus.pendingVerification:
        bg = AppColors.waitlistMuted;
        fg = AppColors.waitlist;
        label = 'PENDING VERIFICATION';
        break;
      case DueStatus.paid:
        bg = AppColors.primaryMuted;
        fg = AppColors.primaryDark;
        label = 'PAID';
        break;
      case DueStatus.rejected:
        bg = AppColors.destructiveMuted;
        fg = AppColors.destructive;
        label = 'REJECTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class AutoApproveSettingsBottomSheet extends ConsumerStatefulWidget {
  final String groupId;
  const AutoApproveSettingsBottomSheet({required this.groupId, super.key});

  @override
  ConsumerState<AutoApproveSettingsBottomSheet> createState() =>
      _AutoApproveSettingsBottomSheetState();
}

class _AutoApproveSettingsBottomSheetState
    extends ConsumerState<AutoApproveSettingsBottomSheet> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final groupCtxAsync = ref.watch(groupContextProvider(widget.groupId));

    return groupCtxAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Failed to load group details')),
      data: (groupCtx) {
        final autoApprove = groupCtx.group.autoApprovePayments;

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Payment Settings', style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: const Text('Auto-approve payments', style: AppTextStyles.headlineSmall),
                subtitle: const Text('Skip manual UTR verification. Incoming player payments will be marked as PAID instantly.', style: AppTextStyles.bodySmall),
                value: autoApprove,
                onChanged: _isSaving
                    ? null
                    : (val) async {
                        setState(() => _isSaving = true);
                        try {
                          await ref.read(paymentsRepositoryProvider).setAutoApprove(
                                groupId: widget.groupId,
                                enabled: val,
                              );
                          ref.invalidate(groupContextProvider(widget.groupId));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(val ? 'Auto-approve payments enabled!' : 'Auto-approve payments disabled!')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to save settings.')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isSaving = false);
                          }
                        }
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}
