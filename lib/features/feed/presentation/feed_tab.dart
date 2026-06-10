import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gameior/core/supabase/supabase_client.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/shared/widgets/app_bottom_sheet.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_empty_state.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/dues_hero_card.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duesSummaryAsync = ref.watch(feedDuesSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activity Feed'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(feedDuesSummaryProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.base),
          children: [
            // 1. Dues Hero Card (shows only if outstanding dues exist)
            duesSummaryAsync.when(
              data: (summary) {
                if (summary.totalPaise <= 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.base),
                  child: DuesHeroCard(
                    amountPaise: summary.totalPaise,
                    label: 'You owe across ${summary.groupCount} group${summary.groupCount > 1 ? 's' : ''}',
                    ctaLabel: 'Settle All',
                    onTap: () {
                      showAppBottomSheet(
                        context: context,
                        title: 'Consolidated Group Dues',
                        child: FeedDuesPaymentBottomSheet(summary: summary),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 2. Feed Announcements Placeholder (Sprint 5)
            const SizedBox(height: AppSpacing.lg),
            const AppEmptyState(
              icon: Icons.rss_feed_outlined,
              message: 'Stay tuned for match updates, announcements, and results in your activity feed!',
            ),
          ],
        ),
      ),
    );
  }
}

class FeedDuesPaymentBottomSheet extends ConsumerWidget {
  final FeedDuesSummary summary;
  const FeedDuesPaymentBottomSheet({required this.summary, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.base,
        right: AppSpacing.base,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.base,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a group below to pay and submit UTR reference:',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.base),
            ...summary.groupBreakdown.map((breakdown) {
              return _GroupPaymentItemCard(breakdown: breakdown);
            }),
          ],
        ),
      ),
    );
  }
}

class _GroupPaymentItemCard extends ConsumerStatefulWidget {
  final GroupDueSummary breakdown;
  const _GroupPaymentItemCard({required this.breakdown});

  @override
  ConsumerState<_GroupPaymentItemCard> createState() => _GroupPaymentItemCardState();
}

class _GroupPaymentItemCardState extends ConsumerState<_GroupPaymentItemCard> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitting = false;
  String _upiId = '';

  @override
  void initState() {
    super.initState();
    _loadGroupUpi();
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupUpi() async {
    final client = ref.read(supabaseClientProvider);
    try {
      final res = await client
          .from('groups')
          .select('default_upi_id')
          .eq('id', widget.breakdown.groupId)
          .single();
      if (mounted) {
        setState(() {
          _upiId = res['default_upi_id'] as String? ?? '';
        });
      }
    } catch (e) {
      // Fail silently
    }
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

    final client = ref.read(supabaseClientProvider);
    final repo = ref.read(paymentsRepositoryProvider);
    final utr = _utrController.text.trim();

    try {
      final userId = client.auth.currentUser!.id;
      
      // Fetch the most recent unpaid payment due for this group
      final response = await client
          .from('payment_dues')
          .select('id')
          .eq('group_id', widget.breakdown.groupId)
          .eq('player_id', userId)
          .eq('status', 'unpaid')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        throw Exception('No pending unpaid dues found in this group.');
      }

      final dueId = response['id'] as String;

      await repo.submitUtr(dueId: dueId, utrReference: utr);

      ref.invalidate(feedDuesSummaryProvider);

      if (mounted) {
        _utrController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment UTR submitted successfully!')),
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
    final double rupees = widget.breakdown.pendingPaise / 100.0;
    final groupName = widget.breakdown.groupName;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      groupName,
                      style: AppTextStyles.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₹${rupees.toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.destructive),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${widget.breakdown.unpaidCount} unpaid game${widget.breakdown.unpaidCount > 1 ? 's' : ''}',
                style: AppTextStyles.caption,
              ),
              const Divider(height: AppSpacing.lg),

              if (_upiId.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'UPI ID: $_upiId',
                        style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _upiId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('UPI ID copied!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                ElevatedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 14),
                  label: const Text('Open UPI App & Pay Total', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMuted,
                    foregroundColor: AppColors.primaryDark,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  onPressed: () => _launchUpiApp(_upiId, widget.breakdown.pendingPaise, groupName),
                ),
                const SizedBox(height: AppSpacing.base),
              ],

              AppTextField(
                controller: _utrController,
                label: '12-digit UTR (Settle most recent)',
                hint: 'Ref number',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'UTR is required.';
                  if (v.length != 12) return 'UTR must be 12 digits.';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Confirm UTR',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}