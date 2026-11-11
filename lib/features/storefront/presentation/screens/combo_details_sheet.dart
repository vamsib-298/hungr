import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../../../core/widgets/obsidian_card.dart';

class ComboDetailsSheet extends StatelessWidget {
  final String heroTag;
  final String comboId;
  final String title;
  final String chefName;
  final String itemsDescription;
  final String calories;
  final String protein;
  final String carbs;
  final IconData comboIcon;

  const ComboDetailsSheet({
    super.key,
    required this.heroTag,
    required this.comboId,
    required this.title,
    required this.chefName,
    required this.itemsDescription,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.comboIcon,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Expanded Header with Steaming Vector
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: heroTag,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      HungrNetworkImage(
                        imageUrl: comboId == 'combo_a'
                            ? 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80'
                            : 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x55000000),
                              Colors.transparent,
                              Color(0xDD000000),
                            ],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.zomatoRed,
                            borderRadius: AppDimensions.radiusCircle,
                          ),
                          child: Text(
                            'PREPARED FRESH AT 06:30 IST',
                            style: AppTypography.monoBadge.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content Details
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.displayMedium.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: AppDimensions.radius8,
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Text(
                            'HYGIENE CERTIFIED',
                            style: AppTypography.monoBadge.copyWith(
                              color: AppColors.neonMint,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_pin, color: AppColors.goldenAmber, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Prepared by $chefName • Cluster Kitchen Unit',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.p20),

                    // Macro Nutrition Badges
                    Row(
                      children: [
                        _buildMacroBadge('CALORIES', calories, 'kcal'),
                        const SizedBox(width: AppDimensions.p12),
                        _buildMacroBadge('PROTEIN', protein, 'g'),
                        const SizedBox(width: AppDimensions.p12),
                        _buildMacroBadge('CARBS', carbs, 'g'),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.p24),

                    // Packaging & Delivery SOP Info
                    Text(
                      'Morning Tiffin Spec & Packing',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: AppDimensions.p12),
                    ObsidianCard(
                      child: Column(
                        children: [
                          _buildSpecRow(
                            Icons.layers_outlined,
                            'Thermal Steam Retaining',
                            'Packed in butter paper wrap with silver outer pouch.',
                          ),
                          const Divider(height: 20, color: AppColors.charcoalBorder),
                          _buildSpecRow(
                            Icons.timer_outlined,
                            '90-Minute Consumption Window',
                            'Consume hot before 09:30 AM for peak crispness and aroma.',
                          ),
                          const Divider(height: 20, color: AppColors.charcoalBorder),
                          _buildSpecRow(
                            Icons.local_shipping_outlined,
                            'Gate Drop Window',
                            '07:30 AM – 08:30 AM direct to your hostel watchman table.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppDimensions.p20),

                    Text(
                      'Dish Ingredients & Relish',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itemsDescription,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(AppDimensions.p16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.charcoalBorder)),
            boxShadow: [
              BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, -2)),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(comboId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.zomatoRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Select $title For Tomorrow',
                  style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMacroBadge(String label, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppDimensions.radius12,
          border: Border.all(color: AppColors.charcoalBorder),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTypography.monoPrice.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.zomatoRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
