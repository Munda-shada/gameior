import 'package:flutter/material.dart';
import 'package:gameior/core/theme/app_colors.dart';
import 'package:gameior/core/theme/app_spacing.dart';

class AppTheme {
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor, Color disabledColor) {
    const String displayFont = 'Outfit';
    const String bodyFont = 'PlusJakartaSans';

    return TextTheme(
      // Display — used for hero numbers, large stats
      displayLarge: TextStyle(fontFamily: displayFont, fontSize: 32, fontWeight: FontWeight.w700, color: primaryColor, height: 1.2),
      displayMedium: TextStyle(fontFamily: displayFont, fontSize: 24, fontWeight: FontWeight.w700, color: primaryColor, height: 1.25),

      // Headline — screen titles, card headers
      headlineLarge: TextStyle(fontFamily: displayFont, fontSize: 20, fontWeight: FontWeight.w600, color: primaryColor, height: 1.3),
      headlineMedium: TextStyle(fontFamily: displayFont, fontSize: 17, fontWeight: FontWeight.w600, color: primaryColor, height: 1.35),
      headlineSmall: TextStyle(fontFamily: displayFont, fontSize: 15, fontWeight: FontWeight.w600, color: primaryColor, height: 1.4),

      // Body — primary content text
      bodyLarge: TextStyle(fontFamily: bodyFont, fontSize: 15, fontWeight: FontWeight.w400, color: primaryColor, height: 1.5),
      bodyMedium: TextStyle(fontFamily: bodyFont, fontSize: 13, fontWeight: FontWeight.w400, color: secondaryColor, height: 1.5),
      bodySmall: TextStyle(fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor, height: 1.4),

      // Label — badges, chips, button text, section headers
      labelLarge: TextStyle(fontFamily: bodyFont, fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor, height: 1.4, letterSpacing: 0.1),
      labelMedium: TextStyle(fontFamily: bodyFont, fontSize: 12, fontWeight: FontWeight.w600, color: secondaryColor, height: 1.3, letterSpacing: 0.4),
      labelSmall: TextStyle(fontFamily: bodyFont, fontSize: 11, fontWeight: FontWeight.w500, color: secondaryColor, height: 1.3, letterSpacing: 0.5),
      
      // Caption is generally mapped to bodySmall in M3, but we can override it here if we use it directly
    );
  }

  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightTextOnPrimary,
      secondary: AppColors.lightAccent,
      tertiary: AppColors.lightWaitlist,
      error: AppColors.lightDestructive,
      surface: AppColors.lightSurfaceSolid,
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerLowest: AppColors.lightBgBase,
      onSurface: AppColors.lightTextPrimary,
      onSurfaceVariant: AppColors.lightTextSecondary,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderGlow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBgBase,
      textTheme: _buildTextTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary, AppColors.lightTextDisabled),
      
      // Glassmorphism preparations: transparent or translucent backgrounds
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface, // Translucent
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface, // Translucent
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface, // Translucent
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.lightTextDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurfaceSolid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurfaceSolid,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightDestructive),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.lightTextDisabled,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkTextOnPrimary,
      secondary: AppColors.darkAccent,
      tertiary: AppColors.darkWaitlist,
      error: AppColors.darkDestructive,
      surface: AppColors.darkSurfaceSolid,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerLowest: AppColors.darkBgBase,
      onSurface: AppColors.darkTextPrimary,
      onSurfaceVariant: AppColors.darkTextSecondary,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderGlow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBgBase,
      textTheme: _buildTextTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary, AppColors.darkTextDisabled),
      
      // Glassmorphism preparations: transparent or translucent backgrounds
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface, // Translucent
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface, // Translucent
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface, // Translucent
        selectedItemColor: AppColors.darkPrimary,
        unselectedItemColor: AppColors.darkTextDisabled,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceSolid,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceSolid,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkDestructive),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.darkTextDisabled,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

