import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_spacing.dart';


void showToast(BuildContext context, String message, {bool isError = false}) {
  final theme = Theme.of(context);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onPrimary),
      ),
      backgroundColor: isError ? theme.colorScheme.error : theme.colorScheme.onSurface,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.base),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}