import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class CostDetailsCard extends StatelessWidget {
  final String paymentModel;
  final int costPaise;
  final bool showBreakdown;
  final List<dynamic> costItems;

  const CostDetailsCard({
    required this.paymentModel,
    required this.costPaise,
    required this.showBreakdown,
    required this.costItems,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'FEES & BREAKDOWN'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment Model:', style: AppTextStyles.bodyMedium),
                  Text(
                    paymentModel == 'prepaid' ? 'PRE-PAID' : 'POST-PAID',
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.base),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paymentModel == 'prepaid' ? 'Match Fee:' : 'Estimated Fee:',
                    style: AppTextStyles.headlineSmall,
                  ),
                  Text(
                    '₹${(costPaise / 100).toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark),
                  ),
                ],
              ),
              if (showBreakdown && costItems.isNotEmpty) ...[
                const Divider(height: AppSpacing.base),
                const Text('Cost Breakdown:', style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                ...costItems.map((item) {
                  final label = item['label'] as String? ?? 'Item';
                  final amt = (item['amount_paise'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: AppTextStyles.bodyMedium),
                        Text('₹${(amt / 100).toStringAsFixed(0)}', style: AppTextStyles.bodySmall),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
