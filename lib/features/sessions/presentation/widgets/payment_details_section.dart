import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class PaymentDetailsSection extends StatelessWidget {
  final String upiId;
  final VoidCallback onOpenUpiApp;
  final VoidCallback onCopied;

  const PaymentDetailsSection({
    required this.upiId,
    required this.onOpenUpiApp,
    required this.onCopied,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PAYMENT DETAILS'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              const Text(
                'Scan or transfer to organizer\'s UPI ID below:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              SelectableText(
                upiId,
                style: AppTextStyles.displayMedium.copyWith(color: AppColors.primary, fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Open UPI App'),
                    onPressed: onOpenUpiApp,
                  ),
                  const SizedBox(width: AppSpacing.base),
                  IconButton(
                    icon: const Icon(Icons.copy, color: AppColors.textSecondary),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: upiId));
                      onCopied();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
