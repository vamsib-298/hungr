import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Hungr Typography System:
/// - Plus Jakarta Sans: Headers, Hero Titles, Badges
/// - Inter: Clean, legible body copy, descriptions, dialogs
/// - JetBrains Mono: Precise digits, live countdown flip clock, monetary values
class AppTypography {
  AppTypography._();

  // Plus Jakarta Sans - Headlines & Titles
  static TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textCrispWhite,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textCrispWhite,
        letterSpacing: -0.4,
      );

  static TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textCrispWhite,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
        letterSpacing: -0.2,
      );

  static TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
      );

  static TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
      );

  static TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
      );

  // Inter - Body & Informational Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textCrispWhite,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedSlate,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textMutedSlate,
      );

  static TextStyle get caption => bodySmall;

  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textMutedSlate,
        letterSpacing: 0.5,
      );

  // JetBrains Mono - Real-time Countdown, Metrics, Prices & Timestamps
  static TextStyle get monoClockLarge => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.electricSaffron,
        letterSpacing: 1.0,
      );

  static TextStyle get monoClockUrgent => GoogleFonts.jetBrainsMono(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.urgentCrimson,
        letterSpacing: 1.0,
      );

  static TextStyle get monoPrice => GoogleFonts.jetBrainsMono(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textCrispWhite,
      );

  static TextStyle get monoBadge => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textCrispWhite,
        letterSpacing: 0.5,
      );
}
