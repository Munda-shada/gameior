import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class BillingPreviewCard extends StatelessWidget {
  final double perHeadRupees;
  final int chargedCount;

  const BillingPreviewCard({
    required this.perHeadRupees,
    required this.chargedCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Per-head Cost:',
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary),
              ),
              Text(
                '₹${perHeadRupees.toStringAsFixed(2)}',
                style: theme.textTheme.displayLarge?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Divisor:',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
              ),
              Text(
                '$chargedCount players billed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
