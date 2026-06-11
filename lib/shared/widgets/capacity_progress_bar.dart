import 'package:flutter/material.dart';

class CapacityProgressBar extends StatelessWidget {
  final int confirmed;
  final int capacity;
  final bool showLabel;

  const CapacityProgressBar({
    super.key,
    required this.confirmed,
    required this.capacity,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = capacity > 0 ? (confirmed / capacity).clamp(0.0, 1.0) : 0.0;
    final bool isFull = confirmed >= capacity;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text(
            '$confirmed / $capacity spots filled',
            style: (theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12.0)).copyWith(
              fontWeight: isFull ? FontWeight.bold : FontWeight.normal,
              color: isFull ? theme.colorScheme.tertiary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6.0),
        ],
        LinearProgressIndicator(
          value: progress,
          minHeight: 6.0,
          borderRadius: BorderRadius.circular(3.0),
          backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
          color: isFull ? theme.colorScheme.tertiary : theme.colorScheme.primary,
        ),
      ],
    );
  }
}