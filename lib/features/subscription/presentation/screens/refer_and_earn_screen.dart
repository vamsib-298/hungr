import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/confetti_burst_overlay.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../viewmodels/referral_viewmodel.dart';
import '../viewmodels/subscription_history_viewmodel.dart';

/// Flagship Dedicated Refer & Earn Screen
/// Features the 3-member viral loop:
/// "Refer 3 Friends -> They complete their 1st order -> You get 3-Day Starter Pass FREE!"
class ReferAndEarnScreen extends ConsumerStatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  ConsumerState<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends ConsumerState<ReferAndEarnScreen> {
  final GlobalKey<ConfettiBurstOverlayState> _confettiKey = GlobalKey();
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
    _confettiKey.currentState?.burstAtCenter();

    final success = await ref.read(referralProvider.notifier).claimFree3DayPass(
          dashboardNotifier: ref.read(customerDashboardProvider.notifier),
          historyNotifier: ref.read(subscriptionHistoryProvider.notifier),
          clusterName: customerState.selectedCluster.name,
        );

    if (!mounted) return;

    if (success) {
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
                'Congratulations! 3 of your referred friends completed their first morning order. Your 3-Day Starter Pass is activated for ₹0.',
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.profile);
        }
      },
      child: ConfettiBurstOverlay(
        key: _confettiKey,
        child: Scaffold(
          backgroundColor: AppColors.obsidianBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RouteNames.profile);
                }
              },
            ),
            title: Text(
              'Refer & Earn Free Pass',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Headline Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppDimensions.radius16,
                    border: Border.all(color: const Color(0xFFFDE68A)),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.card_giftcard_rounded, color: AppColors.goldenAmber, size: 24),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '3 FRIENDS = 3 DAYS FREE',
                                  style: AppTypography.monoBadge.copyWith(
                                    color: const Color(0xFF92400E),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10.5,
                                  ),
                                ),
                                Text(
                                  'Eat Free for 3 Days!',
                                  style: AppTypography.headlineMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.zomatoRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SAVE ₹165',
                              style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 9.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Refer 3 friends to Hungr. When all 3 friends complete their first morning breakfast order, your 3-Day Starter Pass (3 hot South Indian meals) unlocks for ₹0!',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 2. Rule Explainer Callout Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.neonMint, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Important Rule: Friends must place their 1st breakfast order to qualify as a valid credit.',
                          style: AppTypography.caption.copyWith(
                            color: const Color(0xFF166534),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Milestone Progress Tracker (3 Members)
                ObsidianCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            referralState.isRewardUnlocked
                                ? '🎉 Target Reached (3 of 3 Ordered)'
                                : '${referralState.qualifiedOrderCount} of 3 Friends Ordered',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w800,
                              color: referralState.isRewardUnlocked ? AppColors.neonMint : AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: referralState.isRewardUnlocked
                                  ? const Color(0xFFECFDF5)
                                  : AppColors.zomatoRedSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              referralState.isRewardUnlocked
                                  ? 'PASS READY'
                                  : '${referralState.remainingOrdersNeeded} more order needed',
                              style: AppTypography.caption.copyWith(
                                color: referralState.isRewardUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                                fontWeight: FontWeight.bold,
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
                          backgroundColor: const Color(0xFFF3F4F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            referralState.isRewardUnlocked ? AppColors.neonMint : AppColors.zomatoRed,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 3 Milestone Circles
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(3, (index) {
                          final isDone = index < referralState.qualifiedOrderCount;
                          final isTarget = index == 2;

                          return Column(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? AppColors.neonMint
                                      : (isTarget ? const Color(0xFFFEF3C7) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDone
                                        ? AppColors.neonMint
                                        : (isTarget ? AppColors.goldenAmber : AppColors.charcoalBorder),
                                    width: isTarget ? 2.0 : 1.2,
                                  ),
                                ),
                                child: Center(
                                  child: isDone
                                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                      : (isTarget
                                          ? const Icon(Icons.card_giftcard_rounded, color: AppColors.goldenAmber, size: 18)
                                          : Text(
                                              '${index + 1}',
                                              style: AppTypography.titleSmall.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSubtle,
                                              ),
                                            )),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isTarget ? 'FREE PASS' : 'Friend ${index + 1}',
                                style: AppTypography.caption.copyWith(
                                  fontSize: 10,
                                  fontWeight: isTarget ? FontWeight.bold : FontWeight.w500,
                                  color: isDone ? AppColors.neonMint : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                isDone ? '1st Order Done' : (isTarget ? 'Target' : 'Pending Order'),
                                style: AppTypography.caption.copyWith(
                                  fontSize: 9,
                                  color: isDone ? AppColors.neonMint : AppColors.textSubtle,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Referral Code Box
                ObsidianCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Unique Referral Code',
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
                      const SizedBox(height: 8),
                      Text(
                        'Friends get ₹50 OFF their first order when they enter your code at checkout.',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. How It Works Steps
                ObsidianCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('How It Works', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      _buildStepRow(
                        step: '1',
                        title: 'Share your code or invite link',
                        desc: 'Send to hostel friends, roommates or campus colleagues.',
                      ),
                      const SizedBox(height: 10),
                      _buildStepRow(
                        step: '2',
                        title: 'Friends place their 1st morning order',
                        desc: 'They enjoy hot gate tiffin with ₹50 discount.',
                      ),
                      const SizedBox(height: 10),
                      _buildStepRow(
                        step: '3',
                        title: 'You unlock 3-Day Pass FREE',
                        desc: 'When 3 friends order, your 3-Day Starter Pass is 100% free (₹0).',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 6. Friends Activity Feed
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Referred Friends (${referralState.friends.length})',
                      style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    // Quick Demo Simulator for user evaluation
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
                const SizedBox(height: 8),

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
          bottomSheet: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.charcoalBorder, width: 1)),
              boxShadow: [
                BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, -3)),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: referralState.isRewardClaimed
                    ? ElevatedButton.icon(
                        onPressed: () => context.go(RouteNames.ticketCalendar),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFECFDF5),
                          foregroundColor: AppColors.neonMint,
                          elevation: 0,
                          side: const BorderSide(color: Color(0xFFA7F3D0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.check_circle_rounded, color: AppColors.neonMint),
                        label: Text('3-Day Free Pass Active • View Tickets', style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }

  Widget _buildStepRow({required String step, required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w600, fontSize: 12.5)),
              Text(desc, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10.5)),
            ],
          ),
        ),
      ],
    );
  }
}
