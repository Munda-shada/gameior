import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class CostBreakdownEditor extends StatelessWidget {
  final List<Map<String, dynamic>> costItems;
  final VoidCallback onAddItem;
  final Function(int) onRemoveItem;
  final Function(int, String) onLabelChanged;
  final Function(int, double) onAmountChanged;

  const CostBreakdownEditor({
    required this.costItems,
    required this.onAddItem,
    required this.onRemoveItem,
    required this.onLabelChanged,
    required this.onAmountChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...costItems.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final labelController = TextEditingController(text: item['label'] as String);
          final valController = TextEditingController(text: (item['costRupees'] as double).toStringAsFixed(0));

          // Set cursor position to the end of the text
          labelController.selection = TextSelection.fromPosition(TextPosition(offset: labelController.text.length));
          valController.selection = TextSelection.fromPosition(TextPosition(offset: valController.text.length));

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: labelController,
                    decoration: const InputDecoration(labelText: 'Item Label', hintText: 'Court fee'),
                    onChanged: (val) => onLabelChanged(idx, val),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: valController,
                    decoration: const InputDecoration(labelText: 'Amount (₹)'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (val) {
                      final parsed = double.tryParse(val) ?? 0.0;
                      onAmountChanged(idx, parsed);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.destructive),
                  onPressed: () => onRemoveItem(idx),
                ),
              ],
            ),
          );
        }),
        if (costItems.length < 5)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Line Item'),
              onPressed: onAddItem,
            ),
          ),
      ],
    );
  }
}
