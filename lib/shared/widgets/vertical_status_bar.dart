import 'package:flutter/material.dart';

class VerticalStatusBar extends StatelessWidget {
  final String status;

  const VerticalStatusBar({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'yes':
      case 'confirmed':
      case 'paid':
      case 'completed':
        statusColor = theme.colorScheme.primary;
      case 'waitlist':
      case 'waitlisted':
      case 'maybe':
      case 'pending_verification':
        statusColor = theme.colorScheme.tertiary;
      case 'no':
      case 'cancelled':
      case 'rejected':
        statusColor = theme.colorScheme.error;
      default:
        statusColor = theme.colorScheme.outline;
    }

    return Container(
      width: 4.0,
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.circular(2.0),
      ),
    );
  }
}