import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';

void showToast(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.destructive : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
}