import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../viewmodels/referral_viewmodel.dart';

/// Next-Level Viral Referral Banner for Storefront
/// Highlights the "Refer 3 Friends who complete 1st order -> Get 3-Day Starter Pass FREE" loop.
class ViralReferralBanner extends ConsumerWidget {
  const ViralReferralBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refState = ref.watch(referralProvider);

    final bool isUnlocked = refState.isRewardUnlocked;
    final bool isClaimed = refState.isRewardClaimed;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(RouteNames.referral);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isClaimed
                ? [const Color(0xFFF0FDF4), const Color(0xFFECFDF5)]
                : (isUnlocked
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppDimensions.radius16,
          border: Border.all(
            color: isClaimed
                ? const Color(0xFFA7F3D0)
                : (isUnlocked ? AppColors.neonMint : const Color(0xFFFDE68A)),
            width: 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Gift Badge Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: Icon(
                    isClaimed
                        ? Icons.check_circle_rounded
                        : (isUnlocked ? Icons.card_giftcard_rounded : Icons.card_giftcard_rounded),
                    color: isUnlocked ? AppColors.neonMint : AppColors.goldenAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),

                // Main Heading & Value Hook
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              isClaimed
                                  ? '3-DAY FREE PASS CLAIMED'
                                  : (isUnlocked ? '3-DAY PASS UNLOCKED FREE!' : 'REFER 3 FRIENDS = 3 DAYS FREE'),
                              style: AppTypography.monoBadge.copyWith(
                                color: isUnlocked ? AppColors.neonMint : const Color(0xFF92400E),
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isClaimed ? 'CLAIMED' : 'SAVE ₹165',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isClaimed
                            ? 'Your 3-day breakfast routine is running!'
                            : (isUnlocked
                                ? 'Tap to activate your 3-Day Starter Pass for ₹0'
                                : 'Invite 3 friends to order & unlock your ₹165 Pass for ₹0'),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Arrow Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isUnlocked ? AppColors.neonMint : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isClaimed
                            ? 'View'
                            : (isUnlocked ? 'Claim' : '${refState.qualifiedOrderCount}/3'),
                        style: AppTypography.caption.copyWith(
                          color: isUnlocked ? AppColors.neonMint : const Color(0xFF92400E),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: isUnlocked ? AppColors.neonMint : const Color(0xFF92400E),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (!isClaimed) ...[
              const SizedBox(height: 10),
              // Mini Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: refState.progressRatio,
                  minHeight: 6,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${refState.qualifiedOrderCount} of 3 friends completed 1st order',
                    style: AppTypography.caption.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  Text(
                    isUnlocked
                        ? 'Ready to claim for ₹0!'
                        : '${refState.remainingOrdersNeeded} more order needed for Free 3-Day Pass',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
