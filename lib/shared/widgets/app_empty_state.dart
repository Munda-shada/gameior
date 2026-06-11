import 'package:flutter/material.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;
  final IconData? icon;

  const AppEmptyState({
    super.key,
    required this.message,
    this.ctaLabel,
    this.onCtaTap,
    this.icon,              // defaults to sport-appropriate icon
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? Icons.sports_score,
              size: 64.0,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (ctaLabel != null && onCtaTap != null) ...[
              const SizedBox(height: 24.0),
              AppButton(
                label: ctaLabel!,
                onPressed: onCtaTap,
                isFullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}