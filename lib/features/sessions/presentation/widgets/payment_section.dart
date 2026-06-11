import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/shared/models/enums.dart';
import 'package:gameior/shared/widgets/app_text_field.dart';
import 'package:gameior/shared/widgets/section_header.dart';
import 'package:gameior/features/sessions/presentation/widgets/cost_breakdown_editor.dart';

class PaymentSection extends StatelessWidget {
  final PaymentModel paymentModel;
  final ValueChanged<PaymentModel> onPaymentModelChanged;
  final TextEditingController costController;
  final TextEditingController upiController;
  final bool showCostBreakdown;
  final ValueChanged<bool> onCostBreakdownExpanded;
  final List<Map<String, dynamic>> costItems;
  final VoidCallback onAddCostItem;
  final Function(int) onRemoveCostItem;
  final Function(int, String) onCostItemLabelChanged;
  final Function(int, double) onCostItemAmountChanged;

  const PaymentSection({
    required this.paymentModel,
    required this.onPaymentModelChanged,
    required this.costController,
    required this.upiController,
    required this.showCostBreakdown,
    required this.onCostBreakdownExpanded,
    required this.costItems,
    required this.onAddCostItem,
    required this.onRemoveCostItem,
    required this.onCostItemLabelChanged,
    required this.onCostItemAmountChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'FEES & UPI SETTINGS'),
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
              Text('Payment Model', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('PRE-PAID')),
                      selected: paymentModel == PaymentModel.prepaid,
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: paymentModel == PaymentModel.prepaid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) onPaymentModelChanged(PaymentModel.prepaid);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('POST-PAID')),
                      selected: paymentModel == PaymentModel.postpaid,
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: paymentModel == PaymentModel.postpaid
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (selected) {
                        if (selected) onPaymentModelChanged(PaymentModel.postpaid);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.base),
              AppTextField(
                controller: costController,
                label: paymentModel == PaymentModel.prepaid
                    ? 'Cost per person (₹)'
                    : 'Estimated cost per person (₹) (Optional)',
                hint: '150',
                enabled: !showCostBreakdown,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (paymentModel == PaymentModel.prepaid && (v == null || v.isEmpty)) {
                    return 'Cost is required for prepaid model.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.base),
              AppTextField(
                controller: upiController,
                label: 'Organizer UPI ID (for receiving collections)',
                hint: 'name@upi',
                validator: (v) => v == null || v.isEmpty ? 'UPI ID is required.' : null,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Cost Breakdown Accordion
              ExpansionTile(
                leading: Icon(Icons.calculate_outlined, color: theme.colorScheme.primary),
                title: Text('Add Cost Breakdown', style: theme.textTheme.headlineSmall),
                subtitle: Text('Sum elements to calculate per head cost', style: theme.textTheme.bodySmall),
                initiallyExpanded: showCostBreakdown,
                onExpansionChanged: onCostBreakdownExpanded,
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
            ],
          ),
        ),
      ],
    );
  }
}
