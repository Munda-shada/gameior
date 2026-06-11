import 'package:flutter/material.dart';

class DuesHeroCard extends StatelessWidget {
  final int amountPaise;
  final String label;
  final VoidCallback onTap;
  final String ctaLabel;
  final bool isAdminView;

  const DuesHeroCard({
    super.key,
    required this.amountPaise,
    required this.label, // "You owe" vs "Pending from players"
    required this.onTap,
    this.ctaLabel = 'Pay',
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double amountRupees = amountPaise / 100.0;
    // Formats ₹ amount (removes .00 if it's a whole number)
    final String formattedAmount = '₹${amountRupees.toStringAsFixed(amountRupees.truncateToDouble() == amountRupees ? 0 : 2)}';

    final Color backgroundColor = isAdminView
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.error.withValues(alpha: 0.08);

    final Color borderColor = isAdminView
        ? theme.colorScheme.primary.withValues(alpha: 0.3)
        : theme.colorScheme.error.withValues(alpha: 0.3);

    final Color labelColor = isAdminView
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    final Color amountColor = theme.colorScheme.onSurface;

    final Color buttonColor = isAdminView
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    final Color buttonTextColor = isAdminView
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onError;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  formattedAmount,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: buttonTextColor,
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(ctaLabel),
          ),
        ],
      ),
    );
  }
}