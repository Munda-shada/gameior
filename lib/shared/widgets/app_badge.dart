import 'package:flutter/material.dart';

enum AppBadgeVariant { confirmed, waitlist, unanswered, no, maybe, role, custom }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final Color? color;
  final Color? mutedColor;
  final bool leadingDot;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.custom,
    this.color,         // used when variant = custom
    this.mutedColor,    // background when variant = custom
    this.leadingDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: mutedColor ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Icon(Icons.circle, size: 8.0, color: color ?? Colors.grey),
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: TextStyle(color: color ?? Colors.black, fontSize: 12.0),
          ),
        ],
      ),
    );
  }
}