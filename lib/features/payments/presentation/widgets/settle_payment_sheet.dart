import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/features/group_workspace/application/group_context_provider.dart';
import 'package:gameior/features/payments/application/payments_providers.dart';
import 'package:gameior/features/payments/domain/payment_due.dart';
import 'package:gameior/shared/widgets/app_button.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/core/utils/app_toast.dart';

class SettlePaymentSheet extends ConsumerStatefulWidget {
  final PaymentDue due;
  final String fallbackUpiId;
  const SettlePaymentSheet({required this.due, required this.fallbackUpiId, super.key});

  @override
  ConsumerState<SettlePaymentSheet> createState() => _SettlePaymentSheetState();
}

class _SettlePaymentSheetState extends ConsumerState<SettlePaymentSheet> {
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
          showToast(context, 'No UPI apps found. Please pay manually.', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Could not launch UPI app. Please pay manually.', isError: true);
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
      ref.invalidate(groupContextProvider(widget.due.groupId));

      if (mounted) {
        Navigator.of(context).pop();
        showToast(context, 'Payment submitted successfully for verification!');
      }
    } catch (e) {
      if (mounted) {
        showToast(context, 'Submission failed: $e', isError: true);
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
                    showToast(context, 'UPI ID copied!');
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
