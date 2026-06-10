import 'package:flutter/material.dart';
import 'package:gameior/shared/models/enums.dart';

abstract class AppColors {
  // Brand
  static const primary        = Color(0xFF00C07F);
  static const primaryDark    = Color(0xFF009963);
  static const primaryMuted   = Color(0xFFE6FFF5);

  // Status
  static const waitlist       = Color(0xFFFF8C00);
  static const waitlistMuted  = Color(0xFFFFF3E0);
  static const confirmed      = primary;
  static const unanswered     = Color(0xFF9CA3AF);

  // Destructive
  static const destructive    = Color(0xFFE53935);
  static const destructiveMuted = Color(0xFFFFEBEE);

  // Neutral
  static const surface        = Color(0xFFFFFFFF);
  static const background     = Color(0xFFF5F6FA);
  static const border         = Color(0xFFE8EAF0);

  // Text
  static const textPrimary    = Color(0xFF0D1117);
  static const textSecondary  = Color(0xFF6B7280);
  static const textDisabled   = Color(0xFFB0B7C3);
  static const textOnPrimary  = Color(0xFFFFFFFF);

  // Overlay
  static const overlay        = Color(0x800D1117);
}
extension RsvpStatusColor on RsvpStatus {
  Color get color => switch (this) {
    RsvpStatus.yes        => AppColors.primary,
    RsvpStatus.guest      => AppColors.primary,
    RsvpStatus.waitlist   => AppColors.waitlist,
    RsvpStatus.no         => AppColors.textDisabled,
    RsvpStatus.maybe      => AppColors.waitlist,
    RsvpStatus.unanswered => AppColors.unanswered,
  };

  Color get mutedColor => switch (this) {
    RsvpStatus.yes        => AppColors.primaryMuted,
    RsvpStatus.guest      => AppColors.primaryMuted,
    RsvpStatus.waitlist   => AppColors.waitlistMuted,
    RsvpStatus.no         => AppColors.background,
    RsvpStatus.maybe      => AppColors.waitlistMuted,
    RsvpStatus.unanswered => AppColors.background,
  };
}