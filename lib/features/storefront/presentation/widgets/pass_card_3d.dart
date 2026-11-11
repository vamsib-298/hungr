import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../subscription/presentation/viewmodels/referral_viewmodel.dart';

enum PassTierType {
  trial3Day,
  routine7Day,
  power15Day,
}

class PassCard3D extends ConsumerWidget {
  final PassTierType tier;
  final bool isSelected;
  final VoidCallback onTap;

  const PassCard3D({
    super.key,
    required this.tier,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralState = ref.watch(referralProvider);

    final title = _getTitle();
    final price = _getPrice();
    final effectivePrice = _getEffectivePrice();
    final meals = _getMeals();
    final badgeText = _getBadgeText();
    final accentColor = _getAccentColor();

    final bool isTrial = tier == PassTierType.trial3Day;
    final bool isFreeUnlocked = isTrial && referralState.isRewardUnlocked;
    final bool isClaimed = isTrial && referralState.isRewardClaimed;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.radius16,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: AppDimensions.radius16,
          color: isSelected ? AppColors.zomatoRedSurface : Colors.white,
          border: Border.all(
            color: isSelected ? accentColor : (isFreeUnlocked ? AppColors.neonMint : AppColors.charcoalBorder),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? accentColor.withOpacity(0.18) : const Color(0x08000000),
              blurRadius: isSelected ? 12 : 6,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left Selection Radio Indicator
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? accentColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? accentColor : AppColors.textSubtle,
                  width: 1.8,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            // Middle: Pass Title & Validity
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isFreeUnlocked ? AppColors.neonMint : accentColor).withOpacity(0.16),
                          borderRadius: AppDimensions.radiusCircle,
                        ),
                        child: Text(
                          isClaimed
                              ? 'ACTIVE'
                              : (isFreeUnlocked ? 'FREE UNLOCKED' : badgeText),
                          style: AppTypography.monoBadge.copyWith(
                            color: isFreeUnlocked ? AppColors.neonMint : accentColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$meals Morning Tiffins • Pause Anytime',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMutedSlate,
                      fontSize: 11,
                    ),
                  ),
                  if (isTrial && !isClaimed) ...[
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.referral),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard_rounded, size: 12, color: AppColors.goldenAmber),
                          const SizedBox(width: 4),
                          Text(
                            isFreeUnlocked
                                ? '3 Friends Ordered • Ready to claim for ₹0'
                                : 'Or FREE with 3 Friend Orders (${referralState.qualifiedOrderCount}/3) ➔',
                            style: AppTypography.caption.copyWith(
                              color: isFreeUnlocked ? AppColors.neonMint : const Color(0xFF92400E),
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right: Price & Effective Price (Auto-scaled)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFreeUnlocked) ...[
                    Row(
                      children: [
                        Text(
                          '₹$price',
                          style: AppTypography.caption.copyWith(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSubtle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FREE',
                          style: AppTypography.monoPrice.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neonMint,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹0 / meal',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neonMint,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '₹$price',
                      style: AppTypography.monoPrice.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textCrispWhite,
                      ),
                    ),
                    Text(
                      '₹$effectivePrice / meal',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neonMint,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTitle() {
    switch (tier) {
      case PassTierType.trial3Day:
        return '3-Day Starter';
      case PassTierType.routine7Day:
        return '7-Day Routine';
      case PassTierType.power15Day:
        return '15-Day Power';
    }
  }

  int _getPrice() {
    switch (tier) {
      case PassTierType.trial3Day:
        return 165;
      case PassTierType.routine7Day:
        return 350;
      case PassTierType.power15Day:
        return 720;
    }
  }

  int _getEffectivePrice() {
    switch (tier) {
      case PassTierType.trial3Day:
        return 55;
      case PassTierType.routine7Day:
        return 50;
      case PassTierType.power15Day:
        return 48;
    }
  }

  int _getMeals() {
    switch (tier) {
      case PassTierType.trial3Day:
        return 3;
      case PassTierType.routine7Day:
        return 7;
      case PassTierType.power15Day:
        return 15;
    }
  }

  String _getBadgeText() {
    switch (tier) {
      case PassTierType.trial3Day:
        return 'TRIAL';
      case PassTierType.routine7Day:
        return 'MOST POPULAR';
      case PassTierType.power15Day:
        return 'MAX SAVINGS';
    }
  }

  Color _getAccentColor() {
    switch (tier) {
      case PassTierType.trial3Day:
        return AppColors.neonMint;
      case PassTierType.routine7Day:
        return AppColors.zomatoRedLight;
      case PassTierType.power15Day:
        return AppColors.electricSaffron;
    }
  }
}
