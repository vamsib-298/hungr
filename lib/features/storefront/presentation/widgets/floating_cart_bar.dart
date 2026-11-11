import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'pass_card_3d.dart';

/// Floating checkout pill bar displayed at the bottom of the Storefront
/// when items or a pass are in the user's cart.
class FloatingCartBar extends ConsumerWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    // Hide if nothing is in the cart
    if (cartState.isEmpty) return const SizedBox.shrink();

    final isSingleDay = cartState.orderMode == OrderMode.singleDay;
    final int total = cartState.totalPayable;
    final String label = isSingleDay
        ? '${cartState.totalItemCount} ITEM${cartState.totalItemCount > 1 ? 'S' : ''}'
        : (cartState.selectedPassTier == PassTierType.trial3Day
            ? '3-DAY STARTER PASS'
            : (cartState.selectedPassTier == PassTierType.power15Day
                ? '15-DAY POWER PASS'
                : '7-DAY ROUTINE PASS'));

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF111827), // Crisp Dark Slate Floating Contrast
              borderRadius: AppDimensions.radius20,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Item Count & Price
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.zomatoRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.monoBadge.copyWith(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (cartState.savingsAmount > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Save ₹${cartState.savingsAmount}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.neonMint,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹$total',
                          style: AppTypography.monoPrice.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'plus taxes',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white60,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Right: Checkout Button
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.push(RouteNames.passCheckout);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.zomatoRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Cart',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
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
