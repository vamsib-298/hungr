import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../viewmodels/referral_viewmodel.dart';
import '../viewmodels/subscription_history_viewmodel.dart';

/// Modal bottom sheet showcasing the Viral Referral Loop
/// ("Refer 3 Friends who complete 1st order -> Get 3-Day Starter Pass FREE")
class ReferralViralSheet extends ConsumerStatefulWidget {
  const ReferralViralSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ReferralViralSheet(),
    );
  }

  @override
  ConsumerState<ReferralViralSheet> createState() => _ReferralViralSheetState();
}

class _ReferralViralSheetState extends ConsumerState<ReferralViralSheet> {
  bool _copied = false;

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.mediumImpact();
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Referral code $code copied to clipboard!', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
        backgroundColor: AppColors.neonMint,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _handleClaim(ReferralState refState) async {
    final customerState = ref.read(customerDashboardProvider);
    final success = await ref.read(referralProvider.notifier).claimFree3DayPass(
          dashboardNotifier: ref.read(customerDashboardProvider.notifier),
          historyNotifier: ref.read(subscriptionHistoryProvider.notifier),
          clusterName: customerState.selectedCluster.name,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.card_giftcard_rounded, color: AppColors.neonMint, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                '3-Day Pass Unlocked FREE!',
                style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Congratulations! 3 friends completed their first morning order. Your 3-Day Starter Pass is activated for ₹0.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    context.go(RouteNames.ticketCalendar);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.zomatoRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('View Morning Tickets ➔', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final referralState = ref.watch(referralProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.charcoalBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Reward Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.card_giftcard_rounded, size: 14, color: AppColors.goldenAmber),
                            const SizedBox(width: 4),
                            Text(
                              'VIRAL REWARD • 100% FREE',
                              style: AppTypography.monoBadge.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Headline & Value Proposition
                  Text(
                    'Refer 3 Friends,\nEat Free for 3 Days!',
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When 3 referred friends complete their first morning order on Hungr, your 3-Day Starter Pass (₹165 value) unlocks completely FREE for ₹0!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Interactive Progress Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: referralState.isRewardUnlocked
                            ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                            : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppDimensions.radius16,
                      border: Border.all(
                        color: referralState.isRewardUnlocked ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              referralState.isRewardUnlocked
                                  ? '🎉 Target Achieved!'
                                  : '${referralState.qualifiedOrderCount} of 3 Friends Ordered',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                color: referralState.isRewardUnlocked ? AppColors.neonMint : const Color(0xFF92400E),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                referralState.isRewardUnlocked
                                    ? 'UNLOCKED'
                                    : '${referralState.remainingOrdersNeeded} more order needed',
                                style: AppTypography.caption.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: referralState.isRewardUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: referralState.progressRatio,
                            minHeight: 10,
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              referralState.isRewardUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 3-Step Milestones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(3, (index) {
                            final isDone = index < referralState.qualifiedOrderCount;
                            final isTarget = index == 2;

                            return Column(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppColors.neonMint
                                        : (isTarget ? const Color(0xFFFEF3C7) : Colors.white),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDone
                                          ? AppColors.neonMint
                                          : (isTarget ? AppColors.goldenAmber : AppColors.charcoalBorder),
                                      width: isTarget ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: isDone
                                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                                        : (isTarget
                                            ? const Icon(Icons.card_giftcard_rounded, color: AppColors.goldenAmber, size: 16)
                                            : Text(
                                                '${index + 1}',
                                                style: AppTypography.caption.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textSubtle,
                                                ),
                                              )),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isTarget ? 'FREE PASS' : 'Friend ${index + 1}',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 9,
                                    fontWeight: isTarget ? FontWeight.bold : FontWeight.normal,
                                    color: isDone ? AppColors.neonMint : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Share Referral Code Box
                  Text(
                    'Your Exclusive Referral Code',
                    style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.charcoalBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          referralState.referralCode,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: AppColors.zomatoRed,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _copyCode(referralState.referralCode),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _copied ? AppColors.neonMint : AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: Icon(_copied ? Icons.check : Icons.copy_rounded, size: 14),
                          label: Text(_copied ? 'Copied' : 'Copy', style: AppTypography.labelSmall.copyWith(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Friends Activity Feed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Friends Invited (${referralState.friends.length})',
                        style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      // Interactive Demo Button for instant testing
                      InkWell(
                        onTap: () {
                          ref.read(referralProvider.notifier).simulateFriendFirstOrder();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.zomatoRedSurface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColors.zomatoRed, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                'Simulate 1st Order (+1)',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.zomatoRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...referralState.friends.map((friend) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: friend.hasOrdered ? const Color(0xFFA7F3D0) : AppColors.charcoalBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: friend.hasOrdered ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              friend.hasOrdered ? Icons.check_circle_rounded : Icons.person_outline_rounded,
                              color: friend.hasOrdered ? AppColors.neonMint : AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.name,
                                  style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  friend.cluster,
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: friend.hasOrdered ? const Color(0xFFECFDF5) : const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  friend.hasOrdered ? Icons.verified : Icons.hourglass_top_rounded,
                                  color: friend.hasOrdered ? AppColors.neonMint : AppColors.goldenAmber,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  friend.hasOrdered ? '1st Order Done (+1)' : 'Pending 1st Order',
                                  style: AppTypography.caption.copyWith(
                                    color: friend.hasOrdered ? AppColors.neonMint : const Color(0xFF92400E),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.charcoalBorder, width: 1)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: referralState.isRewardClaimed
                    ? ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go(RouteNames.ticketCalendar);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECFDF5),
                          foregroundColor: AppColors.neonMint,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.neonMint),
                        label: Text('3-Day Free Pass Active • View Schedule', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                      )
                    : (referralState.isRewardUnlocked
                        ? ElevatedButton.icon(
                            onPressed: () => _handleClaim(referralState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neonMint,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.card_giftcard_rounded, color: Colors.white),
                            label: Text('CLAIM 3-DAY STARTER PASS (₹0)', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _copyCode(referralState.referralCode),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.share_rounded, color: Colors.white),
                            label: Text(
                              'Share on WhatsApp (${referralState.remainingOrdersNeeded} more order needed)',
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
