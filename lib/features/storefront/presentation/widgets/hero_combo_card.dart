import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../screens/combo_details_sheet.dart';

class HeroComboCard extends StatelessWidget {
  final String comboId; // 'combo_a' or 'combo_b'
  final String tagTitle; // 'Option A' or 'Option B'
  final String title;
  final String chefName;
  final String description;
  final String calories;
  final String protein;
  final String carbs;
  final IconData comboIcon;
  final bool isSelected;
  final VoidCallback onSelected;

  const HeroComboCard({
    super.key,
    required this.comboId,
    required this.tagTitle,
    required this.title,
    required this.chefName,
    required this.description,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.comboIcon,
    required this.isSelected,
    required this.onSelected,
  });

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<String>(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) {
          return ComboDetailsSheet(
            heroTag: 'hero_$comboId',
            comboId: comboId,
            title: title,
            chefName: chefName,
            itemsDescription: description,
            calories: calories,
            protein: protein,
            carbs: carbs,
            comboIcon: comboIcon,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutExpo,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    ).then((result) {
      if (result == comboId) {
        onSelected();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: AppDimensions.radius16,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.zomatoRedSurface : Colors.white,
          borderRadius: AppDimensions.radius16,
          border: Border.all(
            color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.zomatoRedGlow : const Color(0x0A000000),
              blurRadius: isSelected ? 14 : 6,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Food Thumbnail with Option Tag
            Stack(
              children: [
                Hero(
                  tag: 'hero_$comboId',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      borderRadius: AppDimensions.radius12,
                    ),
                    child: ClipRRect(
                      borderRadius: AppDimensions.radius12,
                      child: HungrNetworkImage(
                        imageUrl: comboId == 'combo_a'
                            ? 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80'
                            : 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 3,
                  left: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tagTitle,
                      style: AppTypography.monoBadge.copyWith(
                        fontSize: 8,
                        color: isSelected ? AppColors.electricSaffron : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Middle: Title, Short Description & Nutritional Metric
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCrispWhite,
                            fontSize: 14.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMutedSlate,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$calories kcal • $protein protein',
                        style: AppTypography.monoBadge.copyWith(
                          color: AppColors.neonMint,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _openDetails(context),
                        child: Text(
                          'Details ℹ️',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSubtle,
                            fontSize: 9.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right: Selection Radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.electricSaffron : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.electricSaffron : AppColors.textSubtle,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.black)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
