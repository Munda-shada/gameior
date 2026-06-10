import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';

abstract class AppTextStyles {
  static const String _fontFamily = 'Inter';

  // Display — used for hero numbers, large stats
  static const displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.2,
  );
  static const displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.25,
  );

  // Headline — screen titles, card headers
  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.3,
  );
  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.35,
  );
  static const headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
  );

  // Body — primary content text
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.4,
  );

  // Label — badges, chips, button text, section headers
  static const labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, height: 1.4,
    letterSpacing: 0.1,
  );
  static const labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, height: 1.3,
    letterSpacing: 0.4,
  );
  static const labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, height: 1.3,
    letterSpacing: 0.5,
  );

  // Caption — timestamps, metadata, hints
  static const caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11, fontWeight: FontWeight.w400,
    color: AppColors.textDisabled, height: 1.3,
  );

  // Section header — ALL CAPS labels above list sections
  static const sectionHeader = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11, fontWeight: FontWeight.w700,
    color: AppColors.textSecondary, height: 1.3,
    letterSpacing: 1.2,
  );
}