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
    required this.label,          // "You owe" vs "Pending from players"
    required this.onTap,
    this.ctaLabel = 'Pay',
    this.isAdminView = false,
  });

  @override
  Widget build(BuildContext context) {
    final double amountRupees = amountPaise / 100.0;
    // Formats ₹ amount (removes .00 if it's a whole number)
    final String formattedAmount = '₹${amountRupees.toStringAsFixed(amountRupees.truncateToDouble() == amountRupees ? 0 : 2)}';

    final Color backgroundColor = isAdminView ? Colors.blue.shade50 : Colors.red.shade50;
    final Color borderColor = isAdminView ? Colors.blue.shade200 : Colors.red.shade200;
    final Color labelColor = isAdminView ? Colors.blue.shade800 : Colors.red.shade800;
    final Color amountColor = isAdminView ? Colors.blue.shade900 : Colors.red.shade900;
    final Color buttonColor = isAdminView ? Colors.blue.shade700 : Colors.red.shade600;

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
                  style: TextStyle(fontSize: 14.0, color: labelColor, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8.0),
                Text(
                  formattedAmount,
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: amountColor),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
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