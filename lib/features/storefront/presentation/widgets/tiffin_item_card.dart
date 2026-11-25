import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../domain/tiffin_item_model.dart';

/// Next-Level Production Tiffin Item Card (Zomato Gold / Swiggy One Tier Polish)
/// Features:
/// - Interactive touch scale-down spring effect
/// - Seamless morphing ADD ➔ [ - QTY + ] counter with AnimatedSwitcher
/// - Animated number roll on quantity change
/// - Crisp veg/non-veg status pill
/// - Subtle gradient discount callout
class TiffinItemCard extends StatefulWidget {
  final TiffinItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool showKitchenName;

  const TiffinItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
    this.showKitchenName = false,
  });

  @override
  State<TiffinItemCard> createState() => _TiffinItemCardState();
}

class _TiffinItemCardState extends State<TiffinItemCard> {
  bool _isCardPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isAdded = widget.quantity > 0;
    final item = widget.item;

    return AnimatedScale(
      scale: _isCardPressed ? 0.985 : 1.0,
      duration: AppDimensions.durationFast,
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isCardPressed = true),
        onTapUp: (_) => setState(() => _isCardPressed = false),
        onTapCancel: () => setState(() => _isCardPressed = false),
        child: AnimatedContainer(
          duration: AppDimensions.durationNormal,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppDimensions.radius16,
            border: Border.all(
              color: isAdded ? AppColors.zomatoRed.withOpacity(0.45) : AppColors.charcoalBorder,
              width: isAdded ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isAdded
                    ? AppColors.zomatoRedGlow.withOpacity(0.08)
                    : const Color(0x08000000),
                blurRadius: isAdded ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Food Image Thumbnail with unique Hero Tag
              Hero(
                tag: 'tiffin_img_${item.shopId ?? 'std'}_${item.id}',
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: item.isVeg ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F2),
                    borderRadius: AppDimensions.radius12,
                    border: Border.all(
                      color: item.isVeg ? const Color(0xFFDCFCE7) : const Color(0xFFFECDD3),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (item.imageRef != null && item.imageRef!.isNotEmpty)
                        ClipRRect(
                          borderRadius: AppDimensions.radius12,
                          child: HungrNetworkImage(
                            imageUrl: item.imageRef!,
                            width: 84,
                            height: 84,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Center(
                          child: Icon(
                            item.category == TiffinItem.categoryBeverages
                                ? Icons.coffee_rounded
                                : (item.isVeg ? Icons.breakfast_dining_rounded : Icons.egg_rounded),
                            color: item.isVeg ? AppColors.neonMint : AppColors.zomatoRed,
                            size: 36,
                          ),
                        ),

                      // Top-Left Veg / Non-Veg Indicator
                      Positioned(
                        top: 5,
                        left: 5,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: const [
                              BoxShadow(color: Color(0x26000000), blurRadius: 3),
                            ],
                            border: Border.all(
                              color: item.isVeg ? const Color(0xFF16A34A) : AppColors.urgentCrimson,
                              width: 1.2,
                            ),
                          ),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: item.isVeg ? const Color(0xFF16A34A) : AppColors.urgentCrimson,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 2. Dish Name, Calorie Chip & Transparent Pricing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag & Nutrition Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.tag == TiffinItem.tagBestseller
                                ? AppColors.zomatoRedSurface
                                : AppColors.goldenAmberSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.tag.toUpperCase(),
                            style: AppTypography.monoBadge.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: item.tag == TiffinItem.tagBestseller
                                  ? AppColors.zomatoRed
                                  : AppColors.goldenAmber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${item.calories} kcal',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Item Name
                    Text(
                      item.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.showKitchenName && item.shopName != null && item.shopName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 11, color: AppColors.zomatoRed),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.shopName!,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 2),

                    // Description
                    Text(
                      item.description,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Pricing Row
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${item.price}',
                            style: AppTypography.monoPrice.copyWith(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '₹${item.originalPrice}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSubtle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              '${item.discountPercent}% OFF',
                              style: AppTypography.caption.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neonMint,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. Interactive Morphing Quantity Control
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedSwitcher(
                  duration: AppDimensions.durationNormal,
                  switchInCurve: Curves.elasticOut,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isAdded
                      ? Container(
                          key: const ValueKey('qty_active'),
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.zomatoRedSurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.zomatoRedBorder, width: 1.3),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onRemove();
                                },
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.remove_rounded, size: 16, color: AppColors.zomatoRed),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: Text(
                                  '${widget.quantity}',
                                  key: ValueKey('qty_${widget.quantity}'),
                                  style: AppTypography.titleMedium.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.zomatoRed,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  widget.onAdd();
                                },
                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  child: Icon(Icons.add_rounded, size: 16, color: AppColors.zomatoRed),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ElevatedButton(
                          key: const ValueKey('add_idle'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            widget.onAdd();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.zomatoRed,
                            elevation: 1.5,
                            shadowColor: const Color(0x1F000000),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: const Size(64, 34),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: AppColors.zomatoRedBorder, width: 1.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 15, color: AppColors.zomatoRed),
                              const SizedBox(width: 2),
                              Text(
                                'ADD',
                                style: AppTypography.labelSmall.copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.zomatoRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
