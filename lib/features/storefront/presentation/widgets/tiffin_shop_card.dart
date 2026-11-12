import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../domain/tiffin_shop_model.dart';

/// Swiggy / Zomato style animated showcase card for partner tiffin shops.
/// Features automatic image carousel cycling through signature dishes (Idli, Dosa, Bonda),
/// dynamic open/closed badges, zone markers, and seamless navigation.
class TiffinShopCard extends StatefulWidget {
  final TiffinShop shop;
  final VoidCallback onTap;

  const TiffinShopCard({
    super.key,
    required this.shop,
    required this.onTap,
  });

  @override
  State<TiffinShopCard> createState() => _TiffinShopCardState();
}

class _TiffinShopCardState extends State<TiffinShopCard> {
  late final PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.shop.carouselImages.length > 1) {
      _carouselTimer = Timer.periodic(const Duration(milliseconds: 3200), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        final nextPage = (_currentPage + 1) % widget.shop.carouselImages.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;
    final bool isClosed = !shop.isOpen;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(
          color: isClosed ? const Color(0xFFE5E7EB) : AppColors.charcoalBorder,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppDimensions.radius16,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Swiggy/Zomato Auto-scrolling Hero Carousel (Bounds API Morph)
                Stack(
                  children: [
                    Hero(
                      tag: 'shop_hero_image_${shop.id}',
                      createRectTween: SmoothTransitions.createArcTween,
                      flightShuttleBuilder: SmoothTransitions.heroFlightShuttle,
                      child: SizedBox(
                        height: 165,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemCount: shop.carouselImages.length,
                          itemBuilder: (context, index) {
                            final imagePath = shop.carouselImages[index];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                HungrNetworkImage(
                                  imageUrl: imagePath,
                                  fit: BoxFit.cover,
                                ),
                                // Subtle bottom gradient for readability
                                const Positioned.fill(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Color(0x88000000),
                                        ],
                                        stops: [0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),

                    // Closed overlay banner if not open
                    if (isClosed)
                      Positioned.fill(
                        child: Container(
                          color: const Color(0xA6000000),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: shop.status == ShopStatus.permanentlyClosed
                                    ? const Color(0xFF374151)
                                    : AppColors.zomatoRed,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    shop.status == ShopStatus.closedToday
                                        ? 'CLOSED TODAY'
                                        : (shop.status == ShopStatus.closedTemporary
                                            ? 'TEMPORARILY CLOSED'
                                            : 'PERMANENTLY CLOSED'),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  if (shop.reopenDate != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      shop.reopenDate!,
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Top Left Badges: Pure Veg & Discount
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Row(
                        children: [
                          if (shop.isPureVeg)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x1F000000), blurRadius: 4),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF16A34A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PURE VEG',
                                    style: AppTypography.monoBadge.copyWith(
                                      fontSize: 8.5,
                                      color: const Color(0xFF16A34A),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (shop.discountLabel != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.zomatoRed,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                shop.discountLabel!,
                                style: AppTypography.monoBadge.copyWith(
                                  fontSize: 8.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Top Right: Rating Pill
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15803D),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              shop.rating.toStringAsFixed(1),
                              style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                          ],
                        ),
                      ),
                    ),

                    // Bottom Right: Carousel Indicator Dots
                    if (shop.carouselImages.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            shop.carouselImages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: _currentPage == index ? 14 : 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? Colors.white : Colors.white54,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Bottom Left: Khammam Zone Pill
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xCC000000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: AppColors.goldenAmber, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              shop.zone,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // 2. Shop Information & Status Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shop Name & Forward Arrow
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              shop.name,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textSubtle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Tagline / Specialty
                      Text(
                        shop.tagline,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Specialties Chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: shop.specialties.map((spec) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              spec,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      const Divider(height: 1, color: Color(0xFFF3F4F6)),
                      const SizedBox(height: 8),

                      // Delivery & Status Info Row
                      if (shop.isOpen) ...[
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${shop.deliveryWindow} • Gate Drop Only',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            Text(
                              '${shop.menuItems.length} Dishes ➔',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.zomatoRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(Icons.info_outline_rounded, color: AppColors.zomatoRed, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                shop.closureReason ?? 'Closed temporarily',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.zomatoRed,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (shop.reopenDate != null)
                              Text(
                                shop.reopenDate!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
