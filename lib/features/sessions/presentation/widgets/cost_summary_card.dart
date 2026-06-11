import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
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

  Widget _buildSummaryRow(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value, style: theme.textTheme.headlineSmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'COST SUMMARY'),
        Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _buildSummaryRow(theme, 'Base Cost per person', '₹${(costPaise / 100.0).toStringAsFixed(0)}'),
              const Divider(height: AppSpacing.lg),
              _buildSummaryRow(theme, 'Attending Slots', '$neededSlots slot${neededSlots > 1 ? 's' : ''}'),
              const Divider(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Dues Payable', style: theme.textTheme.headlineSmall),
                  Text(
                    '₹${(totalCostPaise / 100.0).toStringAsFixed(0)}',
                    style: (theme.textTheme.displayMedium ?? const TextStyle()).copyWith(
                      color: theme.colorScheme.primary,
                    ),
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
