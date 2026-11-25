import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../data/shop_sync_service.dart';
import '../../domain/offer_model.dart';
import '../../domain/tiffin_item_model.dart';
import '../../domain/tiffin_shop_model.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import '../viewmodels/offers_viewmodel.dart';
import '../viewmodels/tiffin_shops_viewmodel.dart';
import '../widgets/cart_action_helper.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/orders_tab_view.dart';
import '../widgets/passes_tab_view.dart';
import '../widgets/tiffin_item_card.dart';
import '../widgets/tiffin_shop_card.dart';

/// Swiggy-Grade Customer Shell with 4 Persistent Tabs:
/// 0: Order (Home discovery, search, live offers, kitchens & dishes)
/// 1: Passes (Morning meal subscription plans)
/// 2: Orders (Upcoming morning tickets & real Firestore order history)
/// 3: Account (Profile, delivery gate, referral & WhatsApp support)
class StorefrontScreen extends ConsumerStatefulWidget {
  const StorefrontScreen({super.key});

  @override
  ConsumerState<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends ConsumerState<StorefrontScreen> {
  int _currentTab = 0;
  String _selectedCategory = 'All';
  bool _vegOnly = false;
  bool _openNowOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  DateTime? _lastBackPressTime;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerDashboardProvider);

    // Real-time kitchen operational broadcast notifications
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
                    style: AppTypography.bodySmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.textPrimary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      });
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentTab != 0) {
          setState(() => _currentTab = 0);
          return;
        }
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
      child: Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        body: IndexedStack(
          index: _currentTab,
          children: [
            _buildHomeOrderTab(),
            PassesTabView(
              onViewSchedule: () => setState(() => _currentTab = 2),
            ),
            OrdersTabView(
              onExploreMenu: () => setState(() => _currentTab = 0),
            ),
            const ProfileScreen(isEmbedded: true),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.charcoalBorder, width: 1)),
            boxShadow: [
              BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, -3)),
            ],
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: AppColors.zomatoRedSurface,
            selectedIndex: _currentTab,
            onDestinationSelected: (idx) {
              HapticFeedback.selectionClick();
              setState(() => _currentTab = idx);
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.restaurant_menu_rounded, color: AppColors.zomatoRed),
                label: 'Order',
              ),
              const NavigationDestination(
                icon: Icon(Icons.card_membership_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.card_membership_rounded, color: AppColors.zomatoRed),
                label: 'Passes',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: customerState.hasUpcomingMeal,
                  backgroundColor: AppColors.neonMint,
                  child: const Icon(Icons.receipt_long_outlined, color: AppColors.textSecondary),
                ),
                selectedIcon: Badge(
                  isLabelVisible: customerState.hasUpcomingMeal,
                  backgroundColor: AppColors.neonMint,
                  child: const Icon(Icons.receipt_long_rounded, color: AppColors.zomatoRed),
                ),
                label: 'Orders',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.person_rounded, color: AppColors.zomatoRed),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeOrderTab() {
    final customerState = ref.watch(customerDashboardProvider);
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);
    final shops = ref.watch(tiffinShopsProvider);
    final offers = ref.watch(offersProvider);
    final authState = ref.watch(authProvider);

    final bool isPastCutoff = DateTimeUtils.isAfterCutoffToday();
    final q = _searchQuery.trim().toLowerCase();

    // Sort open kitchens first, then filter by search / open toggle
    final sortedShops = List<TiffinShop>.from(shops)
      ..sort((a, b) {
        if (a.isOpen == b.isOpen) return b.rating.compareTo(a.rating);
        return a.isOpen ? -1 : 1;
      });

    final filteredShops = sortedShops.where((shop) {
      if (_openNowOnly && !shop.isOpen) return false;
      if (_vegOnly && !shop.isPureVeg) return false;
      if (q.isEmpty) return true;
      final shopMatch = shop.name.toLowerCase().contains(q) ||
          shop.zone.toLowerCase().contains(q) ||
          shop.specialties.any((s) => s.toLowerCase().contains(q));
      final dishMatch = shop.menuItems.any((d) => d.name.toLowerCase().contains(q));
      return shopMatch || dishMatch;
    }).toList();

    // Aggregate live dishes exclusively from OPEN partner kitchens
    final List<TiffinItem> liveDishes = [];
    for (final shop in sortedShops.where((s) => s.isOpen)) {
      for (final rawDish in shop.menuItems) {
        if (!rawDish.isAvailable) continue;
        final dish = rawDish.copyWith(shopId: shop.id, shopName: shop.name);
        if (_vegOnly && !dish.isVeg) continue;
        if (_selectedCategory != 'All' && dish.category != _selectedCategory) continue;
        if (q.isNotEmpty) {
          final match = dish.name.toLowerCase().contains(q) ||
              dish.description.toLowerCase().contains(q) ||
              shop.name.toLowerCase().contains(q);
          if (!match) continue;
        }
        liveDishes.add(dish);
      }
    }

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Swiggy-Style Top Location Header
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 1,
              automaticallyImplyLeading: false,
              toolbarHeight: 62,
              title: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push(RouteNames.clusterSelection);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.zomatoRedSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.location_on_rounded, color: AppColors.zomatoRed, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        customerState.selectedCluster.name,
                                        style: AppTypography.titleSmall.copyWith(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.zomatoRed, size: 18),
                                  ],
                                ),
                                Text(
                                  '7:30 AM Gate Drop • ${customerState.selectedCluster.addressZone}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10.5,
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
                  ),
                  const SizedBox(width: 8),
                  if (!authState.isAuthenticated)
                    ElevatedButton(
                      onPressed: () => context.push(RouteNames.phoneAuth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.zomatoRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Sign In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                  else
                    InkWell(
                      onTap: () => setState(() => _currentTab = 1),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, color: Color(0xFFB45309), size: 15),
                            const SizedBox(width: 3),
                            Text(
                              customerState.hasActivePass ? '${customerState.mealsRemaining} left' : 'Pass',
                              style: AppTypography.labelSmall.copyWith(
                                color: const Color(0xFF92400E),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Main Storefront Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, cartState.isEmpty ? 28 : 104),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2A. Swiggy Search Bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.charcoalBorder),
                        boxShadow: const [
                          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: "Search 'Set Dosa', 'Idli', 'Filter Coffee'...",
                          hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.zomatoRed, size: 21),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSubtle),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2B. Active Morning Meal Tracker (ONLY if user actually ordered!)
                    if (customerState.hasUpcomingMeal && customerState.nextScheduledTicket != null) ...[
                      _buildActiveOrderBanner(customerState),
                      const SizedBox(height: 12),
                    ],

                    // 2C. Clean 9:00 PM Cutoff Info Strip
                    _buildCutoffRibbon(isPastCutoff),
                    const SizedBox(height: 14),

                    // 2D. Live Offers Carousel (from Cloud Firestore)
                    if (offers.isNotEmpty && q.isEmpty) ...[
                      _buildOffersCarousel(offers, cartNotifier),
                      const SizedBox(height: 18),
                    ],

                    // 2E. Filter Chips Row
                    _buildFilterChips(),
                    const SizedBox(height: 18),

                    // 2F. Partner Kitchens Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tiffin Centers in Khammam',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${filteredShops.where((s) => s.isOpen).length} Open',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.neonMint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (filteredShops.isEmpty)
                      _buildNoResultsCard('No kitchens match your filters')
                    else
                      ...filteredShops.map(
                        (shop) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TiffinShopCard(
                            shop: shop,
                            onTap: () => context.push(RouteNames.shopDetails, extra: shop.id),
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 2G. Popular Morning Dishes from Open Kitchens
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Fresh Morning Dishes',
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${liveDishes.length} items',
                          style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Cooked fresh at dawn • Hot delivery by 7:30 AM',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.5),
                    ),
                    const SizedBox(height: 12),

                    if (liveDishes.isEmpty)
                      _buildNoResultsCard('No dishes match your search or filters')
                    else
                      ...liveDishes.map((item) {
                        final isSameKitchen =
                            cartState.activeKitchenId == null || cartState.activeKitchenId == item.shopId;
                        final quantity = isSameKitchen ? (cartState.itemQuantities[item.id] ?? 0) : 0;
                        return TiffinItemCard(
                          item: item,
                          quantity: quantity,
                          showKitchenName: true,
                          onAdd: () => addTiffinItemWithKitchenCheck(context, ref, item),
                          onRemove: () => cartNotifier.removeItem(item.id),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Floating Cart Bar above bottom navigation
        const FloatingCartBar(),
      ],
    );
  }

  Widget _buildActiveOrderBanner(CustomerDashboardState customerState) {
    final ticket = customerState.nextScheduledTicket!;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentTab = 2);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF86EFAC)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breakfast Confirmed • Bag ${ticket.bagToken}',
                    style: AppTypography.labelLarge.copyWith(
                      color: const Color(0xFF15803D),
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    '${ticket.specialtyName ?? 'Morning Tiffin'} • Tap to manage',
                    style: AppTypography.caption.copyWith(color: const Color(0xFF166534), fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF16A34A), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildCutoffRibbon(bool isPastCutoff) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isPastCutoff ? const Color(0xFFF3E8FF) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPastCutoff ? const Color(0xFFD8B4FE) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPastCutoff ? Icons.nightlight_round : Icons.schedule_rounded,
            color: isPastCutoff ? const Color(0xFF7E22CE) : const Color(0xFFB45309),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isPastCutoff
                  ? 'Booking open for ${DateTimeUtils.targetDeliveryLabel()} 7:30 AM drop'
                  : 'Order before 9:00 PM tonight for tomorrow morning drop',
              style: AppTypography.caption.copyWith(
                color: isPastCutoff ? const Color(0xFF581C87) : const Color(0xFF78350F),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffersCarousel(List<OfferModel> offers, CartViewModel cartNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deals & Offers For You',
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final offer = offers[index];
              final isFirst = index % 2 == 0;
              return InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: offer.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.textPrimary,
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Coupon ${offer.code} copied! Apply it at checkout.',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 255,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFirst
                          ? [const Color(0xFFE23744), const Color(0xFFB81D2B)]
                          : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    offer.badgeText,
                                    style: AppTypography.monoBadge.copyWith(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  offer.code,
                                  style: AppTypography.monoBadge.copyWith(
                                    color: const Color(0xFFFDE68A),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              offer.description,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.copy_rounded, color: Colors.white70, size: 16),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildToggleChip(
            label: 'Pure Veg',
            isSelected: _vegOnly,
            activeColor: const Color(0xFF16A34A),
            icon: Icons.eco_rounded,
            onTap: () => setState(() => _vegOnly = !_vegOnly),
          ),
          const SizedBox(width: 8),
          _buildToggleChip(
            label: 'Open Now',
            isSelected: _openNowOnly,
            activeColor: AppColors.zomatoRed,
            icon: Icons.bolt_rounded,
            onTap: () => setState(() => _openNowOnly = !_openNowOnly),
          ),
          const SizedBox(width: 8),
          ...[
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
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
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
          }),
        ],
      ),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.charcoalBorder,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? activeColor : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 32, color: AppColors.textSubtle),
          const SizedBox(height: 6),
          Text(
            text,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
