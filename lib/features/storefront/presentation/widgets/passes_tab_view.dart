import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../subscription/presentation/widgets/viral_referral_banner.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import 'hero_combo_card.dart';
import 'morning_addons_selector.dart';
import 'pass_card_3d.dart';

/// Dedicated Swiggy-One style Morning Pass Subscription Builder Tab
class PassesTabView extends ConsumerStatefulWidget {
  final VoidCallback onViewSchedule;

  const PassesTabView({
    super.key,
    required this.onViewSchedule,
  });

  @override
  ConsumerState<PassesTabView> createState() => _PassesTabViewState();
}

class _PassesTabViewState extends ConsumerState<PassesTabView> {
  PassTierType _selectedTier = PassTierType.routine7Day;
  String _selectedComboId = 'combo_a';
  final Set<String> _selectedPassAddons = {};

  void _onTogglePassAddon(String id) {
    setState(() {
      if (_selectedPassAddons.contains(id)) {
        _selectedPassAddons.remove(id);
      } else {
        _selectedPassAddons.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerDashboardProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.card_membership_rounded, color: Color(0xFFB45309), size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hungr Morning Passes',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Save up to 26% • Zero-loss meal pause anytime',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              children: [
                if (customerState.hasActivePass) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppDimensions.radius16,
                      border: Border.all(color: const Color(0xFF6EE7B7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.neonMint, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active ${customerState.activeTier.displayName}',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF065F46),
                                ),
                              ),
                              Text(
                                '${customerState.mealsRemaining} of ${customerState.totalMeals} breakfasts left',
                                style: AppTypography.caption.copyWith(color: const Color(0xFF047857)),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: widget.onViewSchedule,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonMint,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Schedule', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],

                const ViralReferralBanner(),
                const SizedBox(height: 14),

                Text(
                  'Choose a Plan',
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),

                PassCard3D(
                  tier: PassTierType.routine7Day,
                  isSelected: _selectedTier == PassTierType.routine7Day,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTier = PassTierType.routine7Day);
                    cartNotifier.selectPassTier(PassTierType.routine7Day);
                  },
                ),
                PassCard3D(
                  tier: PassTierType.power15Day,
                  isSelected: _selectedTier == PassTierType.power15Day,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTier = PassTierType.power15Day);
                    cartNotifier.selectPassTier(PassTierType.power15Day);
                  },
                ),
                PassCard3D(
                  tier: PassTierType.trial3Day,
                  isSelected: _selectedTier == PassTierType.trial3Day,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTier = PassTierType.trial3Day);
                    cartNotifier.selectPassTier(PassTierType.trial3Day);
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'First Day Breakfast Choice',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'SWAP ANY DAY',
                        style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                HeroComboCard(
                  comboId: 'combo_a',
                  tagTitle: 'OPTION A',
                  title: 'Hot Set Dosa (2 pcs)',
                  chefName: 'Sri Venkateshwara Hub',
                  description: '2 Fluffy Set Dosas + Groundnut Chutney + Allam Chutney + Piping Sambar.',
                  calories: '420',
                  protein: '11g',
                  carbs: '68g',
                  comboIcon: Icons.breakfast_dining,
                  isSelected: _selectedComboId == 'combo_a',
                  onSelected: () => setState(() => _selectedComboId = 'combo_a'),
                ),

                HeroComboCard(
                  comboId: 'combo_b',
                  tagTitle: 'OPTION B',
                  title: 'Steamed Idli (4 pcs) + Medu Vada (1 pc)',
                  chefName: 'Amma Chethi Vanta',
                  description: '4 Soft Steamed Idlis + 1 Crispy Medu Vada + Chutney + Drumstick Sambar.',
                  calories: '390',
                  protein: '14g',
                  carbs: '62g',
                  comboIcon: Icons.dinner_dining,
                  isSelected: _selectedComboId == 'combo_b',
                  onSelected: () => setState(() => _selectedComboId = 'combo_b'),
                ),

                const SizedBox(height: 14),

                MorningAddonsSelector(
                  selectedAddonIds: _selectedPassAddons,
                  onToggleAddon: _onTogglePassAddon,
                ),
              ],
            ),
          ),

          // Sticky CTA Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.charcoalBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  cartNotifier.clearCart();
                  cartNotifier.setOrderMode(OrderMode.subscriptionPass);
                  cartNotifier.selectPassTier(_selectedTier);
                  for (final id in _selectedPassAddons) {
                    cartNotifier.addItem(id);
                  }
                  context.push(RouteNames.passCheckout);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.zomatoRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue • ${_selectedTier.displayName} (₹${_selectedTier.price})',
                      style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
