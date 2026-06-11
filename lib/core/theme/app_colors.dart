import 'package:flutter/material.dart';
import 'package:gameior/shared/models/enums.dart';

abstract class AppColors {
  // Cyber-Pitch Dark Theme Colors
  static const darkBgBase = Color(0xFF04060A);
  static const darkBgCanvas = Color(0xFF090E17);
  static const darkSurface = Color(0xBF0E1524); // rgba(14, 21, 36, 0.75)
  static const darkSurfaceHover = Color(0xD9162136); // rgba(22, 33, 54, 0.85)
  static const darkSurfaceSolid = Color(0xFF0F1626);
  static const darkBorder = Color(0x12FFFFFF); // rgba(255, 255, 255, 0.07)
  static const darkBorderHover = Color(0x26FFFFFF); // rgba(255, 255, 255, 0.15)
  static const darkBorderGlow = Color(0x1F00F5FF); // rgba(0, 245, 255, 0.12)
  
  static const darkPrimary = Color(0xFF00F5FF);
  static const darkPrimaryDark = Color(0xFF00C2CC);
  static const darkPrimaryMuted = Color(0x1400F5FF); // rgba(0, 245, 255, 0.08)
  static const darkPrimaryGlow = Color(0x5900F5FF); // rgba(0, 245, 255, 0.35)
  
  static const darkAccent = Color(0xFF10FF70);
  static const darkAccentDark = Color(0xFF0CD95E);
  static const darkAccentMuted = Color(0x1410FF70); // rgba(16, 255, 112, 0.08)
  
  static const darkWaitlist = Color(0xFFFFAD00);
  static const darkWaitlistDark = Color(0xFFD69100);
  static const darkWaitlistMuted = Color(0x14FFAD00); // rgba(255, 173, 0, 0.08)
  
  static const darkDestructive = Color(0xFFFF3B5C);
  static const darkDestructiveDark = Color(0xFFD62F4C);
  static const darkDestructiveMuted = Color(0x14FF3B5C); // rgba(255, 59, 92, 0.08)
  
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF8E9CAE);
  static const darkTextTertiary = Color(0xFF526073);
  static const darkTextDisabled = Color(0xFF3C4656);
  static const darkTextOnPrimary = Color(0xFF04060A);
  
  static const darkOverlay = Color(0xCC030508); // rgba(3, 5, 8, 0.8)

  // Premium Light Theme Colors
  static const lightBgBase = Color(0xFFF4F6FA);
  static const lightBgCanvas = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xE6FFFFFF); // rgba(255, 255, 255, 0.9)
  static const lightSurfaceHover = Color(0xFFF8FAFC);
  static const lightSurfaceSolid = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8F0);
  static const lightBorderHover = Color(0xFFCBD5E1);
  static const lightBorderGlow = Color(0x1A00C07F); // rgba(0, 192, 127, 0.1)
  
  static const lightPrimary = Color(0xFF00C07F);
  static const lightPrimaryDark = Color(0xFF009963);
  static const lightPrimaryMuted = Color(0xFFE6FFF5);
  static const lightPrimaryGlow = Color(0x3300C07F); // rgba(0, 192, 127, 0.2)
  
  static const lightAccent = Color(0xFF00C07F);
  static const lightAccentDark = Color(0xFF009963);
  static const lightAccentMuted = Color(0xFFE6FFF5);
  
  static const lightWaitlist = Color(0xFFFF8C00);
  static const lightWaitlistDark = Color(0xFFE07B00);
  static const lightWaitlistMuted = Color(0xFFFFF3E0);
  
  static const lightDestructive = Color(0xFFE53935);
  static const lightDestructiveDark = Color(0xFFC62828);
  static const lightDestructiveMuted = Color(0xFFFFEBEE);
  
  static const lightTextPrimary = Color(0xFF0D131F);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);
  static const lightTextDisabled = Color(0xFFCBD5E1);
  static const lightTextOnPrimary = Color(0xFFFFFFFF);
  
  static const lightOverlay = Color(0x800D131F); // rgba(13, 19, 31, 0.5)

  // NOTE: Static 'AppColors.xxx' usage is deprecated and should be migrated to Theme.of(context).colorScheme.xxx
  // The following aliases map directly to the light theme for backward compatibility during migration.
  @Deprecated('Use Theme.of(context).colorScheme.primary instead')
  static const primary = lightPrimary;
  @Deprecated('Use Theme.of(context).colorScheme.surface instead')
  static const surface = lightSurfaceSolid;
  @Deprecated('Use Theme.of(context).colorScheme.background instead')
  static const background = lightBgBase;
  @Deprecated('Use Theme.of(context).colorScheme.outline instead')
  static const border = lightBorder;
  @Deprecated('Use Theme.of(context).colorScheme.onSurface instead')
  static const textPrimary = lightTextPrimary;
  @Deprecated('Use Theme.of(context).colorScheme.onSurfaceVariant instead')
  static const textSecondary = lightTextSecondary;
  @Deprecated('Use AppColors.lightTextDisabled or custom token mapping')
  static const textDisabled = lightTextDisabled;
}

extension RsvpStatusColor on RsvpStatus {
  Color color(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return switch (this) {
      RsvpStatus.yes        => colorScheme.primary,
      RsvpStatus.guest      => colorScheme.primary,
      RsvpStatus.waitlist   => colorScheme.tertiary,
      RsvpStatus.maybe      => colorScheme.tertiary,
      RsvpStatus.no         => colorScheme.onSurface.withValues(alpha: 0.4),
      RsvpStatus.unanswered => colorScheme.onSurface.withValues(alpha: 0.2),
    };
  }
}
