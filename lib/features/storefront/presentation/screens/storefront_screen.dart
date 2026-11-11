import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/confetti_burst_overlay.dart';
import '../../domain/tiffin_item_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import '../viewmodels/tiffin_shops_viewmodel.dart';
import '../widgets/active_pass_dashboard_card.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/hero_combo_card.dart';
import '../widgets/morning_addons_selector.dart';
import '../widgets/pass_card_3d.dart';
import '../widgets/sticky_cutoff_flip_clock.dart';
import '../widgets/tiffin_item_card.dart';
import '../widgets/tiffin_shop_card.dart';
import '../../../subscription/presentation/widgets/viral_referral_banner.dart';

/// Flagship Storefront Screen (Morning Porcelain & Crimson Theme)
/// Features dual ordering modes:
/// 1. Single-Day Tiffin with item-by-item pricing, nutrition chips, and quantity selectors.
/// 2. Multi-Day Passes (3-Day, 7-Day, 15-Day) with rollover guarantees and maximum savings.
class StorefrontScreen extends ConsumerStatefulWidget {
  const StorefrontScreen({super.key});

  @override
  ConsumerState<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends ConsumerState<StorefrontScreen> {
  String _selectedCategory = 'All';
  PassTierType _selectedTier = PassTierType.routine7Day;
  String _selectedComboId = 'combo_a';
  final Set<String> _selectedPassAddons = {};
  final GlobalKey<ConfettiBurstOverlayState> _confettiKey = GlobalKey();
  DateTime? _lastBackPressTime;

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
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);
    final shops = ref.watch(tiffinShopsProvider);

    final bool isSingleDayMode = cartState.orderMode == OrderMode.singleDay;

    // Filter items based on selected category
    final List<TiffinItem> displayedItems = TiffinItem.standardMenu.where((item) {
      if (_selectedCategory == 'All') return true;
      return item.category == _selectedCategory;
    }).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit Hungr', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: ConfettiBurstOverlay(
        key: _confettiKey,
        child: Stack(
        children: [
          Scaffold(
          backgroundColor: AppColors.obsidianBackground,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sleek Modern App Bar with White Surface & Crisp Branding
              SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 1,
                shadowColor: const Color(0x1F000000),
                toolbarHeight: 62,
                title: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.zomatoRedGlow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/icons/app_icon_512.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'HUNGR',
                          style: AppTypography.headlineLarge.copyWith(
                            fontSize: 18,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        InkWell(
                          onTap: () => context.push(RouteNames.clusterSelection),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.zomatoRed, size: 12),
                              const SizedBox(width: 2),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 180),
                                child: Text(
                                  customerState.selectedCluster.name,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.zomatoRed, size: 14),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Driver Manifest Link
                    InkWell(
                      onTap: () => context.push(RouteNames.driverManifest),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.charcoalBorder),
                        ),
                        child: const Icon(Icons.delivery_dining_outlined, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                    // Profile Icon
                    InkWell(
                      onTap: () => context.push(RouteNames.profile),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.charcoalBorder),
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Pinned 9:00 PM Flip-Clock Header
              SliverPersistentHeader(
                pinned: true,
                delegate: StickyCutoffFlipClockHeader(height: 80),
              ),

              // 3. Main Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Pass Dashboard Card (if user has active pass)
                      if (customerState.hasActivePass) ...[
                        const ActivePassDashboardCard(),
                        const SizedBox(height: 16),
                      ],

                      // Minimal Gate Drop Capacity Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppDimensions.radius12,
                          border: Border.all(color: AppColors.charcoalBorder),
                          boxShadow: const [
                            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, color: AppColors.goldenAmber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${customerState.selectedCluster.name} • 14 drops left for tomorrow',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '86% FILLED',
                                style: AppTypography.monoBadge.copyWith(
                                  color: AppColors.neonMint,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Strict Gate Drop Policy Notice (Requirement 7)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: AppDimensions.radius12,
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '⚡ Security Gate Drop Policy',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: const Color(0xFF1E40AF),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Deliveries are strictly made to your Hostel Security Desk or Main Gate by 7:30 AM. No floor-by-floor climbing.',
                                    style: AppTypography.caption.copyWith(
                                      color: const Color(0xFF1E3A8A),
                                      fontSize: 10.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 4. Strategic Dual-Funnel Mode Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.charcoalBorder),
                        ),
                        child: Row(
                          children: [
                            // Single-Day Tiffin Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  cartNotifier.setOrderMode(OrderMode.singleDay);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSingleDayMode ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: isSingleDayMode
                                        ? const [
                                            BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Single-Day Tiffin',
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: isSingleDayMode ? AppColors.zomatoRed : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Tomorrow Morning Drop',
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 9.5,
                                          color: isSingleDayMode ? AppColors.textPrimary : AppColors.textSubtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Multi-Day Passes Option
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  cartNotifier.setOrderMode(OrderMode.subscriptionPass);
                                  cartNotifier.selectPassTier(_selectedTier);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: !isSingleDayMode ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: !isSingleDayMode
                                        ? const [
                                            BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Meal Passes',
                                            style: AppTypography.titleSmall.copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: !isSingleDayMode ? AppColors.zomatoRed : AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.goldenAmberSurface,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'SAVE ₹360',
                                              style: AppTypography.caption.copyWith(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.goldenAmber,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '3, 7, 15-Day Routine',
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 9.5,
                                          color: !isSingleDayMode ? AppColors.textPrimary : AppColors.textSubtle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 5A. Single-Day Tiffin View (Catalog with Individual Prices)
                      if (isSingleDayMode) ...[
                        // Category Selector Bar
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              TiffinItem.categoryDailyBreakfast,
                              TiffinItem.categoryMorningAddons,
                              TiffinItem.categoryBeverages,
                            ].map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selectedCategory = cat);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.zomatoRedSurface : Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                                        width: isSelected ? 1.4 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: AppTypography.labelSmall.copyWith(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? AppColors.zomatoRed : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Viral Referral Quick Invite Pill
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.referral);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.card_giftcard_rounded, color: AppColors.goldenAmber, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Refer 3 Friends who order to unlock 3 Days of Free Breakfast! ➔',
                                    style: AppTypography.caption.copyWith(
                                      color: const Color(0xFF92400E),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Partner Tiffin Centers Showcase (Swiggy / Zomato Style)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Top Tiffin Centers in Khammam',
                              style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${shops.length} Kitchens',
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Local legends delivering hot wood-fire breakfasts to your gate by 7:30 AM',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),

                        // Swiggy/Zomato Auto-Scrolling Cards
                        ...shops.map((shop) {
                          return TiffinShopCard(
                            shop: shop,
                            onTap: () => context.push(RouteNames.shopDetails, extra: shop.id),
                          );
                        }),

                        const SizedBox(height: 16),

                        // Section Title: A-la-carte dishes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fresh Morning Tiffins (A-la-carte)',
                              style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${displayedItems.length} items',
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Steaming hot breakfast prepared fresh and dropped at your gate by 7:30 AM',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),

                        // List of Tiffin Items
                        ...displayedItems.map((item) {
                          final quantity = cartState.itemQuantities[item.id] ?? 0;
                          return TiffinItemCard(
                            item: item,
                            quantity: quantity,
                            onAdd: () => cartNotifier.addItem(item.id),
                            onRemove: () => cartNotifier.removeItem(item.id),
                          );
                        }),
                      ] else ...[
                        // 5B. Multi-Day Passes View
                        // Viral Referral Loop Banner
                        const ViralReferralBanner(),

                        Text(
                          'Choose Your Subscription Pass',
                          style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pause anytime before 9:00 PM • Zero-loss rollover guarantee',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),

                        PassCard3D(
                          tier: PassTierType.routine7Day,
                          isSelected: _selectedTier == PassTierType.routine7Day,
                          onTap: () {
                            setState(() => _selectedTier = PassTierType.routine7Day);
                            cartNotifier.selectPassTier(PassTierType.routine7Day);
                          },
                        ),
                        PassCard3D(
                          tier: PassTierType.power15Day,
                          isSelected: _selectedTier == PassTierType.power15Day,
                          onTap: () {
                            setState(() => _selectedTier = PassTierType.power15Day);
                            cartNotifier.selectPassTier(PassTierType.power15Day);
                          },
                        ),
                        PassCard3D(
                          tier: PassTierType.trial3Day,
                          isSelected: _selectedTier == PassTierType.trial3Day,
                          onTap: () {
                            setState(() => _selectedTier = PassTierType.trial3Day);
                            cartNotifier.selectPassTier(PassTierType.trial3Day);
                          },
                        ),

                        const SizedBox(height: 20),

                        // Tomorrow's Combo Preference
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tomorrow’s Combo Preference',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'ROTATING DAILY',
                                style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You can swap your combo daily in the Ticket Calendar',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),

                        HeroComboCard(
                          comboId: 'combo_a',
                          tagTitle: 'OPTION A',
                          title: 'Hot Set Dosa (2 pcs)',
                          chefName: 'Partner Chef Aunty 1',
                          description: '2 Fluffy Set Dosas + Groundnut Chutney + Allam (Ginger) Chutney + Piping Sambar.',
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
                          chefName: 'Partner Chef Aunty 2',
                          description: '4 Soft Steamed Idlis + 1 Crispy Medu Vada + Chutney + Drumstick Sambar.',
                          calories: '390',
                          protein: '14g',
                          carbs: '62g',
                          comboIcon: Icons.dinner_dining,
                          isSelected: _selectedComboId == 'combo_b',
                          onSelected: () => setState(() => _selectedComboId = 'combo_b'),
                        ),

                        const SizedBox(height: 16),

                        // Morning Add-ons Selector
                        MorningAddonsSelector(
                          selectedAddonIds: _selectedPassAddons,
                          onToggleAddon: _onTogglePassAddon,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

          // 6. Floating Cart & Checkout Pill
          const FloatingCartBar(),
        ],
      ),
      ),
    );
  }
}
