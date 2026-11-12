import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/confetti_burst_overlay.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../domain/tiffin_item_model.dart';
import '../../domain/tiffin_shop_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import '../viewmodels/tiffin_shops_viewmodel.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/hero_combo_card.dart';
import '../widgets/morning_addons_selector.dart';
import '../widgets/pass_card_3d.dart';
import '../widgets/tiffin_item_card.dart';
import '../../data/shop_sync_service.dart';
import 'shop_details_screen.dart';
import '../../../subscription/presentation/widgets/viral_referral_banner.dart';

/// Clean, Minimalist Customer Storefront Screen (Morning Porcelain & Crimson Theme)
/// Architected strictly for customers booking daily morning tiffins and multi-day meal passes.
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

    // Silent Realtime Operations Live Sync Listener (Notifies user if a kitchen updates)
    ref.listen(liveOpsEventStreamProvider, (previous, next) {
      next.whenData((event) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.description,
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: event.action == OpsSyncAction.statusChange
                ? (event.description.contains('Open')
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706))
                : AppColors.zomatoRed,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
    });

    final bool isSingleDayMode = cartState.orderMode == OrderMode.singleDay;
    final bool isPastCutoff = DateTimeUtils.isAfterCutoffToday();

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
                  // 1. Sleek Minimal Top App Bar
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    scrolledUnderElevation: 1,
                    shadowColor: const Color(0x1F000000),
                    toolbarHeight: 64,
                    title: Row(
                      children: [
                        // App Brand Icon
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.zomatoRedGlow,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.asset(
                              'assets/icons/app_icon_512.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // App Name + Gate Location Selector
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'HUNGR',
                                style: AppTypography.headlineLarge.copyWith(
                                  fontSize: 17,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  context.push(RouteNames.clusterSelection);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on_rounded, color: AppColors.zomatoRed, size: 12),
                                    const SizedBox(width: 3),
                                    Flexible(
                                      child: Text(
                                        customerState.selectedCluster.name,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
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
                        ),
                        // Customer Tickets / Orders Icon Button
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.ticketCalendar);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.charcoalBorder),
                                ),
                                child: const Icon(Icons.confirmation_number_outlined, color: AppColors.textPrimary, size: 18),
                              ),
                              if (customerState.tickets.isNotEmpty || customerState.hasActivePass)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF16A34A),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Customer Profile Icon
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(RouteNames.profile);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
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

                  // 2. Main Body Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 2A. Smart Active Ticket Status Pill (Only if user has active delivery/pass)
                          if (customerState.hasActivePass || customerState.tickets.isNotEmpty) ...[
                            _buildActiveOrderBanner(context, customerState),
                            const SizedBox(height: 12),
                          ],

                          // 2B. Compact Cutoff Ribbon (Non-intrusive & informative)
                          _buildCutoffRibbon(isPastCutoff),
                          const SizedBox(height: 14),

                          // 3. Dual Mode Switcher (Daily Tiffin vs Meal Passes)
                          _buildModeSwitcher(isSingleDayMode, cartNotifier),
                          const SizedBox(height: 18),

                          // 4A. SINGLE-DAY TIFFIN VIEW
                          if (isSingleDayMode) ...[
                            // Partner Kitchens Section (Horizontal Scrollable Showcase)
                            _buildKitchensSection(shops),
                            const SizedBox(height: 20),

                            // Category Selector Chips
                            _buildCategoryChips(),
                            const SizedBox(height: 14),

                            // Menu Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fresh Morning Dishes',
                                  style: AppTypography.displayMedium.copyWith(fontSize: 17, color: AppColors.textPrimary),
                                ),
                                Text(
                                  '${displayedItems.length} items',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Prepared at dawn and dropped at your security gate by 7:30 AM',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                            ),
                            const SizedBox(height: 12),

                            // A-la-carte Items List
                            ...displayedItems.map((item) {
                              final quantity = cartState.itemQuantities[item.id] ?? 0;
                              return TiffinItemCard(
                                item: item,
                                quantity: quantity,
                                onAdd: () => cartNotifier.addItem(item.id),
                                onRemove: () => cartNotifier.removeItem(item.id),
                              );
                            }),

                            const SizedBox(height: 16),
                            // Hostel Roommate Saving Tip
                            _buildRoommateTip(),
                          ] else ...[
                            // 4B. MULTI-DAY MEAL PASSES VIEW
                            const ViralReferralBanner(),
                            const SizedBox(height: 4),

                            Text(
                              'Choose Your Routine Pass',
                              style: AppTypography.displayMedium.copyWith(fontSize: 18, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pause anytime before 9:00 PM • Automatic zero-loss rollover guarantee',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
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
                              'You can swap your combo daily in your Ticket Calendar',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
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

            // Floating Minimal Cart Bar
            const FloatingCartBar(),
          ],
        ),
      ),
    );
  }

  // --- SUB-WIDGET BUILDERS (CLEAN & MODULAR) ---

  /// Active Morning Order Status Pill (Clean Swiggy/Zomato style)
  Widget _buildActiveOrderBanner(BuildContext context, CustomerDashboardState customerState) {
    final bagToken = customerState.tickets.isNotEmpty ? customerState.tickets.first.bagToken : '#SS-04';
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push(RouteNames.ticketCalendar);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF86EFAC)),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF16A34A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Morning Meal Confirmed • Bag $bagToken',
                    style: AppTypography.labelLarge.copyWith(
                      color: const Color(0xFF15803D),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    'Dropping at ${customerState.selectedCluster.name} by 7:30 AM',
                    style: AppTypography.caption.copyWith(color: const Color(0xFF166534), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF16A34A), size: 13),
          ],
        ),
      ),
    );
  }

  /// Compact Cutoff Ribbon
  Widget _buildCutoffRibbon(bool isPastCutoff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isPastCutoff ? const Color(0xFFF3E8FF) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPastCutoff ? const Color(0xFFD8B4FE) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPastCutoff ? Icons.nightlight_round : Icons.bolt_rounded,
            color: isPastCutoff ? const Color(0xFF7E22CE) : const Color(0xFFB45309),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPastCutoff
                  ? '🌙 Past 9:00 PM: Booking open for ${DateTimeUtils.targetDeliveryLabel()} drop'
                  : '🔥 9:00 PM Cutoff: Booking closes tonight for tomorrow morning drop',
              style: AppTypography.caption.copyWith(
                color: isPastCutoff ? const Color(0xFF581C87) : const Color(0xFF78350F),
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mode Switcher (Daily Tiffins vs Meal Passes)
  Widget _buildModeSwitcher(bool isSingleDayMode, CartViewModel cartNotifier) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSingleDayMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSingleDayMode
                      ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '🍱 Daily Tiffins',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: isSingleDayMode ? AppColors.zomatoRed : AppColors.textSecondary,
                    ),
                  ),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: !isSingleDayMode ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: !isSingleDayMode
                      ? const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🎟️ Meal Passes',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: !isSingleDayMode ? AppColors.zomatoRed : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SAVE 35%',
                        style: AppTypography.caption.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal Partner Kitchens Carousel
  Widget _buildKitchensSection(List<TiffinShop> shops) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Partner Kitchens in Khammam',
              style: AppTypography.displayMedium.copyWith(fontSize: 16.5, color: AppColors.textPrimary),
            ),
            Text(
              '${shops.length} Hubs',
              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 154,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: shops.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final shop = shops[index];
              return _buildCompactKitchenCard(shop);
            },
          ),
        ),
      ],
    );
  }

  /// Compact Horizontal Kitchen Card
  Widget _buildCompactKitchenCard(TiffinShop shop) {
    return OpenContainer(
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: const Duration(milliseconds: 380),
      openElevation: 0,
      closedElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.white,
      middleColor: Colors.white,
      closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      openShape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      closedBuilder: (context, openContainer) {
        return InkWell(
          onTap: openContainer,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.charcoalBorder),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Cover Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                      child: SizedBox(
                        height: 84,
                        width: double.infinity,
                        child: HungrNetworkImage(
                          imageUrl: shop.carouselImages.first,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: shop.isOpen ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          shop.isOpen ? 'OPEN' : 'CLOSED',
                          style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 12),
                            const SizedBox(width: 2),
                            Text(
                              shop.rating.toStringAsFixed(1),
                              style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Shop Details
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: AppTypography.titleSmall.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        shop.specialties.isNotEmpty ? shop.specialties.first : 'Woodfire Breakfast',
                        style: AppTypography.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, closeContainer) {
        return ShopDetailsScreen(shopId: shop.id);
      },
    );
  }

  /// Category Filter Chips
  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
    );
  }

  /// Subtle Roommate Savings Tip
  Widget _buildRoommateTip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const Icon(Icons.group_add_outlined, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hostel Roommates? Add companion meals for just ₹45 each at checkout to save together!',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
