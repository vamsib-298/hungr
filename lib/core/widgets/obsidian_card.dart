import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Matte Charcoal (#14161D) surface card with 1px subtle border (#232734)
class ObsidianCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const ObsidianCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    this.margin,
    this.borderRadius,
    this.backgroundColor = AppColors.matteCharcoal,
    this.borderColor = AppColors.charcoalBorder,
    this.borderWidth = AppDimensions.cardBorderWidth,
    this.onTap,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppDimensions.radius16;

    final container = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: shadows ??
            const [
              BoxShadow(
                color: Color(0x0D000000), // 5% Soft Shadow
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          splashColor: AppColors.saffronGlow,
          highlightColor: Colors.transparent,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return container;
  }
}
