import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../domain/tiffin_item_model.dart';

/// Next-Gen Clean White Tiffin Item Card
/// Displays dish name, nutritional chips, transparent pricing with strikethrough,
/// discount badges, and an interactive quantity selector.
class TiffinItemCard extends StatelessWidget {
  final TiffinItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const TiffinItemCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAdded = quantity > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(
          color: isAdded ? AppColors.zomatoRed.withOpacity(0.4) : AppColors.charcoalBorder,
          width: isAdded ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Food Image Thumbnail (Swiggy / Zomato Style)
          Container(
            width: 80,
            height: 80,
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
                      width: 80,
                      height: 80,
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
                      size: 34,
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
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), blurRadius: 2),
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
          const SizedBox(width: 14),

          // Middle: Details & Pricing
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
                ),
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

                // Pricing Row (Auto-scaling for all mobile widths)
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
                          fontSize: 16,
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
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(4),
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

          // Right: Quantity Selector Button
          Align(
            alignment: Alignment.centerRight,
            child: isAdded
                ? Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.zomatoRedSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.zomatoRedBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onRemove();
                          },
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Icon(Icons.remove, size: 16, color: AppColors.zomatoRed),
                          ),
                        ),
                        Text(
                          '$quantity',
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zomatoRed,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            onAdd();
                          },
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Icon(Icons.add, size: 16, color: AppColors.zomatoRed),
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onAdd();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.zomatoRed,
                      elevation: 1,
                      shadowColor: const Color(0x1F000000),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      minimumSize: const Size(64, 34),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: AppColors.zomatoRedBorder, width: 1.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 14, color: AppColors.zomatoRed),
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
        ],
      ),
    );
  }
}
