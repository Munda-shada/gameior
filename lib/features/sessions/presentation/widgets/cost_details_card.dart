import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'FEES & BREAKDOWN'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Model:', style: theme.textTheme.bodyMedium),
                  Text(
                    paymentModel == 'prepaid' ? 'PRE-PAID' : 'POST-PAID',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: AppSpacing.base),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    paymentModel == 'prepaid' ? 'Match Fee:' : 'Estimated Fee:',
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    '₹${(costPaise / 100).toStringAsFixed(0)}',
                    style: (theme.textTheme.displayMedium ?? const TextStyle()).copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              if (showBreakdown && costItems.isNotEmpty) ...[
                const Divider(height: AppSpacing.base),
                Text('Cost Breakdown:', style: theme.textTheme.labelSmall),
                const SizedBox(height: AppSpacing.xs),
                ...costItems.map((item) {
                  final label = item['label'] as String? ?? 'Item';
                  final amt = (item['amount_paise'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: theme.textTheme.bodyMedium),
                        Text('₹${(amt / 100).toStringAsFixed(0)}', style: theme.textTheme.bodySmall),
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
