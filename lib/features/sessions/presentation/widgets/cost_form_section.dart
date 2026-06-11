import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/features/sessions/presentation/widgets/cost_breakdown_editor.dart';

class CostFormSection extends StatelessWidget {
  final TextEditingController costController;
  final bool allDuesSettled;
  final bool showCostBreakdown;
  final ValueChanged<bool> onCostBreakdownExpanded;
  final List<Map<String, dynamic>> costItems;
  final VoidCallback onAddCostItem;
  final Function(int) onRemoveCostItem;
  final Function(int, String) onCostItemLabelChanged;
  final Function(int, double) onCostItemAmountChanged;
  final bool chargeAllRsvped;
  final ValueChanged<bool> onChargeAllRsvpedChanged;

  const CostFormSection({
    required this.costController,
    required this.allDuesSettled,
    required this.showCostBreakdown,
    required this.onCostBreakdownExpanded,
    required this.costItems,
    required this.onAddCostItem,
    required this.onRemoveCostItem,
    required this.onCostItemLabelChanged,
    required this.onCostItemAmountChanged,
    required this.chargeAllRsvped,
    required this.onChargeAllRsvpedChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'EXPENSES & BILLING MODEL'),
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
              TextField(
                controller: costController,
                enabled: !allDuesSettled,
                decoration: const InputDecoration(
                  labelText: 'Total Cost (₹)',
                  prefixText: '₹ ',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
              ),
              const SizedBox(height: AppSpacing.base),

              // Cost items accordion
              ExpansionTile(
                leading: Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
                title: Text('Add Cost Breakdown', style: theme.textTheme.headlineSmall),
                subtitle: Text('Sum elements to calculate total cost', style: theme.textTheme.bodySmall),
                initiallyExpanded: showCostBreakdown,
                onExpansionChanged: allDuesSettled ? null : onCostBreakdownExpanded,
                children: [
                  CostBreakdownEditor(
                    costItems: costItems,
                    onAddItem: onAddCostItem,
                    onRemoveItem: onRemoveCostItem,
                    onLabelChanged: onCostItemLabelChanged,
                    onAmountChanged: onCostItemAmountChanged,
                  ),
                ],
              ),
              const Divider(height: AppSpacing.lg),

              SwitchListTile.adaptive(
                activeTrackColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
                title: Text('Charge all RSVPed players', style: theme.textTheme.headlineSmall),
                subtitle: Text('If off, only checked attendees below will be charged', style: theme.textTheme.bodySmall),
                value: chargeAllRsvped,
                onChanged: allDuesSettled ? null : onChargeAllRsvpedChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
