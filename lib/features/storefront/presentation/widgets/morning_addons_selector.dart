import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/business_rules.dart';

class AddonItem {
  final String id;
  final String title;
  final int price;
  final String description;
  final IconData icon;

  const AddonItem({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.icon,
  });
}

class MorningAddonsSelector extends StatelessWidget {
  final Set<String> selectedAddonIds;
  final ValueChanged<String> onToggleAddon;

  const MorningAddonsSelector({
    super.key,
    required this.selectedAddonIds,
    required this.onToggleAddon,
  });

  static const List<AddonItem> availableAddons = [
    AddonItem(
      id: BusinessRules.addonBoiledEggsId,
      title: BusinessRules.addonBoiledEggsTitle,
      price: BusinessRules.addonBoiledEggsPrice,
      description: '2 Farm-fresh steamed eggs with pepper salt sachets.',
      icon: Icons.egg_outlined,
    ),
    AddonItem(
      id: BusinessRules.addonFilterCoffeeId,
      title: BusinessRules.addonFilterCoffeeTitle,
      price: BusinessRules.addonFilterCoffeePrice,
      description: 'Piping hot Kumbakonam decoction in insulated flask pouch.',
      icon: Icons.coffee_outlined,
    ),
    AddonItem(
      id: BusinessRules.addonBadamMilkId,
      title: BusinessRules.addonBadamMilkTitle,
      price: BusinessRules.addonBadamMilkPrice,
      description: 'Hot saffron badam milk pouch with crushed almonds.',
      icon: Icons.local_drink_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Morning Add-Ons',
                style: AppTypography.displayMedium.copyWith(fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.electricSaffron.withOpacity(0.15),
                borderRadius: AppDimensions.radius8,
              ),
              child: Text(
                '₹0 EXTRA DELIVERY',
                style: AppTypography.monoBadge.copyWith(
                  color: AppColors.electricSaffron,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.p8),
        Text(
          'Delivered fresh with your morning tiffin • ₹0 extra delivery',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: AppDimensions.p12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: availableAddons.length,
          itemBuilder: (context, index) {
            final addon = availableAddons[index];
            final isAdded = selectedAddonIds.contains(addon.id);

            return InkWell(
              onTap: () => onToggleAddon(addon.id),
              borderRadius: AppDimensions.radius12,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isAdded ? AppColors.goldenAmberSurface : Colors.white,
                  borderRadius: AppDimensions.radius12,
                  border: Border.all(
                    color: isAdded ? AppColors.goldenAmber : AppColors.charcoalBorder,
                    width: isAdded ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isAdded ? const Color(0xFFFEF3C7) : const Color(0xFFF3F4F6),
                        borderRadius: AppDimensions.radius8,
                      ),
                      child: Icon(addon.icon, color: AppColors.goldenAmber, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addon.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            addon.description,
                            style: AppTypography.bodySmall.copyWith(fontSize: 10.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+₹${addon.price}',
                      style: AppTypography.monoPrice.copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isAdded ? AppColors.electricSaffron : AppColors.surfaceHighlight,
                        borderRadius: AppDimensions.radius8,
                      ),
                      child: Text(
                        isAdded ? 'ADDED' : '+ ADD',
                        style: AppTypography.monoBadge.copyWith(
                          color: isAdded ? Colors.black : AppColors.textCrispWhite,
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
