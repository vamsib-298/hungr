import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Glassmorphism utility for floating headers, bottom navigation bars,
/// and contextual overlays inspired by CRED & Airbnb.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? shadows;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppDimensions.p16),
    this.margin,
    this.borderRadius,
    this.backgroundColor = AppColors.glassmorphicBackground,
    this.borderColor = AppColors.glassmorphicBorder,
    this.borderWidth = 1.0,
    this.blurSigma = 16.0,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimensions.radius16;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
