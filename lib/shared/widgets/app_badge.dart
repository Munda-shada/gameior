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
    final theme = Theme.of(context);

    Color badgeColor;
    Color badgeBgColor;

    switch (variant) {
      case AppBadgeVariant.confirmed:
        badgeColor = theme.colorScheme.primary;
        badgeBgColor = theme.colorScheme.primary.withValues(alpha: 0.12);
      case AppBadgeVariant.waitlist:
      case AppBadgeVariant.maybe:
        badgeColor = theme.colorScheme.tertiary;
        badgeBgColor = theme.colorScheme.tertiary.withValues(alpha: 0.12);
      case AppBadgeVariant.unanswered:
      case AppBadgeVariant.no:
        badgeColor = theme.colorScheme.outline;
        badgeBgColor = theme.colorScheme.outline.withValues(alpha: 0.12);
      case AppBadgeVariant.role:
        badgeColor = theme.colorScheme.secondary;
        badgeBgColor = theme.colorScheme.secondary.withValues(alpha: 0.12);
      case AppBadgeVariant.custom:
        badgeColor = color ?? theme.colorScheme.onSurface;
        badgeBgColor = mutedColor ?? theme.colorScheme.surfaceContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot) ...[
            Icon(Icons.circle, size: 8.0, color: badgeColor),
            const SizedBox(width: 4.0),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}