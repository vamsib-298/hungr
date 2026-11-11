import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Dark-mode skeleton loader.
/// Note: Circular progress spinners are strictly banned per Hungr specification.
class DarkShimmer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const DarkShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  const DarkShimmer.circular({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = AppDimensions.radiusCircle;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.matteCharcoal,
      highlightColor: AppColors.surfaceHighlight,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.matteCharcoal,
          borderRadius: borderRadius ?? AppDimensions.radius12,
          border: Border.all(
            color: AppColors.charcoalBorder,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
