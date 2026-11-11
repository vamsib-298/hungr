import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

/// Next-level cached image loader supporting high-res online food photography
/// with shimmer placeholder and elegant fallback.
class HungrNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const HungrNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    Widget imageWidget;
    if (isOnline) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: const Color(0xFFF3F4F6),
          highlightColor: const Color(0xFFE5E7EB),
          child: Container(
            width: width,
            height: height,
            color: Colors.white,
          ),
        ),
        errorWidget: (context, url, error) => _buildFallback(),
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF9FAFB),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_rounded, size: 28, color: AppColors.textSubtle),
            SizedBox(height: 4),
            Text(
              'HUNGR',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.textSubtle,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
