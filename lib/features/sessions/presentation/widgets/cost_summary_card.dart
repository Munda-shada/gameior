import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';
import 'package:gameior/shared/widgets/section_header.dart';

class CostSummaryCard extends StatelessWidget {
  final int costPaise;
  final int neededSlots;
  final int totalCostPaise;

  const CostSummaryCard({
    required this.costPaise,
    required this.neededSlots,
    required this.totalCostPaise,
    super.key,
  });

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.headlineSmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'COST SUMMARY'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Base Cost per person', '₹${(costPaise / 100.0).toStringAsFixed(0)}'),
              const Divider(height: AppSpacing.lg),
              _buildSummaryRow('Attending Slots', '$neededSlots slot${neededSlots > 1 ? 's' : ''}'),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Dues Payable', style: AppTextStyles.headlineSmall),
                  Text(
                    '₹${(totalCostPaise / 100.0).toStringAsFixed(0)}',
                    style: AppTextStyles.displayMedium.copyWith(color: AppColors.primaryDark),
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
