import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';
import 'package:gameior/core/theme/app_text_styles.dart';

void showToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppTextStyles.bodyMedium
          .copyWith(color: Colors.white)),
      backgroundColor: isError ? AppColors.destructive : AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(AppSpacing.base),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}