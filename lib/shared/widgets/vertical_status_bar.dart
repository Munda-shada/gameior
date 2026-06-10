import 'package:flutter/material.dart';

class VerticalStatusBar extends StatelessWidget {
  final String status;

  const VerticalStatusBar({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'yes':
      case 'confirmed':
      case 'paid':
      case 'completed':
        statusColor = Colors.green;
      case 'waitlist':
      case 'waitlisted':
      case 'maybe':
      case 'pending_verification':
        statusColor = Colors.orange;
      case 'no':
      case 'cancelled':
      case 'rejected':
        statusColor = Colors.red;
      default:
        statusColor = Colors.grey.shade400;
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