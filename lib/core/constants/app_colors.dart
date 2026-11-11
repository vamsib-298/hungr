import 'package:flutter/material.dart';

/// Hungr Flagship Crisp Light Theme Palette ("Morning Porcelain & Crimson")
/// Engineered for Impeller 120FPS rendering with high contrast,
/// clean pure white surfaces, crisp slate typography, and appetite-stimulating crimson accents.
class AppColors {
  AppColors._();

  // Primary Canvas & Surface (Pristine Light Palette)
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color obsidianBackground = Color(0xFFF8F9FA); // Clean Soft Canvas
  static const Color matteCharcoal = Color(0xFFFFFFFF); // Elevated Crisp Card Surface
  static const Color charcoalBorder = Color(0xFFE5E7EB); // 1px Subtle Border (Tailwind Gray-200)
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Secondary Gray Surface
  static const Color surfaceHighlight = Color(0xFFE5E7EB); // Elevated Highlight

  // Glassmorphic Backdrop
  static const Color glassmorphicBackground = Color(0xEEFFFFFF); // 93% Frosted White
  static const Color glassmorphicBorder = Color(0x1F000000); // 12% Black Subtle Edge

  // Primary Brand (Zomato Hunger-Stimulating Crimson Red & Accents)
  static const Color zomatoRed = Color(0xFFE23744); // Proven Appetite Red
  static const Color zomatoRedDark = Color(0xFFB81D2B); // Deep Rich Crimson
  static const Color zomatoRedGlow = Color(0x26E23744); // Soft Crimson Ambient Shadow
  static const Color zomatoRedLight = Color(0xFFFF5263); // Bright Coral Red Highlight
  static const Color zomatoRedSurface = Color(0xFFFFF1F2); // Rose-50 Tinted Surface
  static const Color zomatoRedBorder = Color(0xFFFECDD3); // Rose-200 Subtle Border

  // Legacy & Cross-token Aliases (Mapped to Zomato Red)
  static const Color electricSaffron = zomatoRed;
  static const Color electricSaffronDark = zomatoRedDark;
  static const Color saffronGlow = zomatoRedGlow;
  static const Color saffronLight = zomatoRedLight;
  static const Color goldenAmber = Color(0xFFD97706); // Warm Breakfast Amber (Readable on white)
  static const Color goldenAmberSurface = Color(0xFFFFFBEB); // Amber-50 Light Surface

  // Functional Accents (High-Contrast for Light Theme)
  static const Color neonMint = Color(0xFF059669); // Emerald-600: Active Pass / Delivered
  static const Color neonMintGlow = Color(0x20059669); // Ambient Emerald Shadow
  static const Color neonMintSurface = Color(0xFFECFDF5); // Emerald-50 Soft Surface
  static const Color urgentCrimson = Color(0xFFDC2626); // Red-600: 9:00 PM Cutoff Alert
  static const Color urgentCrimsonGlow = Color(0x26DC2626); // Crimson Shadow
  static const Color urgentCrimsonSurface = Color(0xFFFEF2F2); // Red-50 Soft Alert Surface
  static const Color warningAmber = Color(0xFFD97706); // Pending / In Preparation

  // Typography (Razor-Sharp Tailwind Slate Palette on White)
  static const Color textCrispWhite = Color(0xFF111827); // Gray-900: Primary High-Contrast Titles
  static const Color textPrimary = Color(0xFF111827); // Primary Dark Text
  static const Color textMutedSlate = Color(0xFF4B5563); // Gray-600: Subtitles / Metadata
  static const Color textSecondary = Color(0xFF4B5563); // Secondary Text
  static const Color textSubtle = Color(0xFF9CA3AF); // Gray-400: Inactive / Placeholders
  static const Color textDark = Color(0xFF111827); // Dark Text

  // Pass Tier Card Gradients
  static const LinearGradient zomatoRedGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE23744),
      Color(0xFFB81D2B),
    ],
  );

  static const LinearGradient saffronCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFFF1F2),
    ],
  );

  static const LinearGradient trialPassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8F9FA),
    ],
  );

  static const LinearGradient powerPassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFECFDF5),
    ],
  );
}
