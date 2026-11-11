import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Flagship Morning Porcelain & Crimson ThemeData configuring Impeller-optimized visuals.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.obsidianBackground,
      primaryColor: AppColors.zomatoRed,
      splashColor: AppColors.zomatoRedGlow,
      highlightColor: Colors.transparent,
      
      colorScheme: const ColorScheme.light(
        primary: AppColors.zomatoRed,
        onPrimary: Colors.white,
        primaryContainer: AppColors.zomatoRedSurface,
        onPrimaryContainer: AppColors.zomatoRedDark,
        secondary: AppColors.neonMint,
        onSecondary: Colors.white,
        surface: AppColors.matteCharcoal,
        onSurface: AppColors.textPrimary,
        error: AppColors.urgentCrimson,
        onError: Colors.white,
        outline: AppColors.charcoalBorder,
      ),

      // Card Theme with 1px Subtle Border & Soft Elevation
      cardTheme: const CardThemeData(
        color: AppColors.matteCharcoal,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radius16,
          side: BorderSide(
            color: AppColors.charcoalBorder,
            width: AppDimensions.cardBorderWidth,
          ),
        ),
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.matteCharcoal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.matteCharcoal,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.zomatoRed,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.zomatoRedGlow,
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius12,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.p20,
            vertical: AppDimensions.p16,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.zomatoRed,
          side: const BorderSide(color: AppColors.charcoalBorder, width: 1.0),
          textStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius12,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.p20,
            vertical: AppDimensions.p16,
          ),
        ),
      ),

      // Input Decoration (Phone Auth, OTP, Form fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p16,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSubtle),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        border: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.zomatoRed, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.urgentCrimson, width: 1.0),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppDimensions.radius12,
          borderSide: BorderSide(color: AppColors.urgentCrimson, width: 1.5),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
          side: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
        ),
      ),

      // Dialog Theme
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.radius20,
          side: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.charcoalBorder,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  // Backwards compatibility alias
  static ThemeData get darkTheme => lightTheme;

  // Reusable BoxShadow Glows
  static List<BoxShadow> get saffronGlowShadow => const [
        BoxShadow(
          color: AppColors.saffronGlow,
          blurRadius: 20,
          spreadRadius: 2,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get mintGlowShadow => const [
        BoxShadow(
          color: AppColors.neonMintGlow,
          blurRadius: 18,
          spreadRadius: 1,
          offset: Offset(0, 3),
        ),
      ];

  static List<BoxShadow> get urgentCrimsonGlowShadow => const [
        BoxShadow(
          color: AppColors.urgentCrimsonGlow,
          blurRadius: 20,
          spreadRadius: 2,
          offset: Offset(0, 4),
        ),
      ];
}
