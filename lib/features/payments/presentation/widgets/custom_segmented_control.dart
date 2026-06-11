import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class CustomSegmentedControl extends StatelessWidget {
  final String label1;
  final String label2;
  final bool isFirstSelected;
  final ValueChanged<bool> onSelected;

  const CustomSegmentedControl({
    super.key,
    required this.label1,
    required this.label2,
    required this.isFirstSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isFirstSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  label1,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isFirstSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelected(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: !isFirstSelected ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  label2,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: !isFirstSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
