import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Per-head Cost:',
                style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primaryDark),
              ),
              Text(
                '₹${perHeadRupees.toStringAsFixed(2)}',
                style: AppTextStyles.displayLarge.copyWith(color: AppColors.primaryDark),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Divisor:',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primaryDark),
              ),
              Text(
                '$chargedCount players billed',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryDark,
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
