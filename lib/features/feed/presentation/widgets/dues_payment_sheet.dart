import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/features/payments/application/feed_dues_provider.dart';
import 'package:gameior/features/payments/data/payments_repository.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/core/utils/app_toast.dart';
import 'package:gameior/core/supabase/supabase_client.dart';

class FeedDuesSheet extends ConsumerStatefulWidget {
  final FeedDuesSummary summary;
  const FeedDuesSheet({required this.summary, super.key});

  @override
  ConsumerState<FeedDuesSheet> createState() => _FeedDuesSheetState();
}

class _FeedDuesSheetState extends ConsumerState<FeedDuesSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pay dues across ${widget.summary.groupCount} group${widget.summary.groupCount > 1 ? 's' : ''}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          ...widget.summary.groupBreakdown.map(
            (breakdown) => GroupDuesCard(breakdown: breakdown),
          ),
        ],
      ),
    );
  }
}

class GroupDuesCard extends ConsumerStatefulWidget {
  final GroupDueSummary breakdown;
  const GroupDuesCard({required this.breakdown, super.key});

  @override
  ConsumerState<GroupDuesCard> createState() => _GroupDuesCardState();
}

class _GroupDuesCardState extends ConsumerState<GroupDuesCard> {
  final _formKey = GlobalKey<FormState>();
  final _utrController = TextEditingController();
  bool _isSubmitting = false;
  String _upiId = '';

  @override
  void initState() {
    super.initState();
    _loadUpi();
  }

  @override
  void dispose() {
    _utrController.dispose();
    super.dispose();
  }

  Future<void> _loadUpi() async {
    final client = ref.read(supabaseClientProvider);
    try {
      final res = await client
          .from('groups')
          .select('default_upi_id')
          .eq('id', widget.breakdown.groupId)
          .single();
      if (mounted) {
        setState(() => _upiId = res['default_upi_id'] as String? ?? '');
      }
    } catch (_) {}
  }

  Future<void> _launchUpi() async {
    if (_upiId.isEmpty) return;
    final amount = (widget.breakdown.pendingPaise / 100.0).toStringAsFixed(2);
    final uri = Uri.parse(
      'upi://pay?pa=$_upiId&am=$amount&tn=${Uri.encodeComponent(widget.breakdown.groupName)}&cu=INR',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        showToast(context, 'No UPI app found. Copy the UPI ID and pay manually.', isError: true);
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
      final response = await client
          .from('payment_dues')
          .select('id')
          .eq('group_id', widget.breakdown.groupId)
          .eq('player_id', userId)
          .eq('status', 'unpaid')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) throw Exception('No pending dues found.');

      await repo.submitUtr(
        dueId: response['id'] as String,
        utrReference: utr,
      );

      ref.invalidate(feedDuesSummaryProvider);

      if (mounted) {
        _utrController.clear();
        showToast(context, 'Payment submitted — awaiting host verification!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rupees = (widget.breakdown.pendingPaise / 100.0).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.base),
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name + amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.breakdown.groupName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹$rupees',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              '${widget.breakdown.unpaidCount} unpaid game${widget.breakdown.unpaidCount > 1 ? 's' : ''}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Divider(height: AppSpacing.lg, color: theme.colorScheme.outline.withValues(alpha: 0.3)),
            if (widget.breakdown.unpaidCount > 1) ...[
              Text(
                'You have multiple outstanding dues in this group. Please visit the Payments tab to pay them individually.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: 'Go to Payments',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.push('/group/${widget.breakdown.groupId}?tab=3');
                },
              ),
            ] else ...[
              // UPI row
              if (_upiId.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _upiId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _upiId));
                        showToast(context, 'UPI ID copied');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text('Open UPI App · ₹$rupees'),
                    onPressed: _launchUpi,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
              // UTR field
              AppTextField(
                controller: _utrController,
                label: '12-digit UTR reference',
                hint: '408712345678',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return 'UTR is required';
                  if (v.length != 12) return 'Must be exactly 12 digits';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Confirm Payment',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
