import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/fluid_gesture_dismissible.dart';
import '../../../../core/animations/smooth_transitions.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/hungr_network_image.dart';
import '../../domain/tiffin_item_model.dart';
import '../../domain/tiffin_shop_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/tiffin_shops_viewmodel.dart';
import '../widgets/cart_action_helper.dart';
import '../widgets/floating_cart_bar.dart';
import '../widgets/tiffin_item_card.dart';

/// Swiggy / Zomato style Shop Details & Menu Screen.
/// Displays partner shop showcase, real-time closed status alerts,
/// strict gate drop policy, category filters, and interactive dish ordering.
class ShopDetailsScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ShopDetailsScreen({
    super.key,
    required this.shopId,
  });

  @override
  ConsumerState<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends ConsumerState<ShopDetailsScreen> {
  String _selectedCategory = 'All';
  bool _vegOnly = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(tiffinShopsProvider);
    final shop = shops.firstWhere(
      (s) => s.id == widget.shopId,
      orElse: () => shops.first,
    );

    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);
    final bool isClosed = !shop.isOpen;

    // Filter items by availability, veg, search, and category
    final displayedItems = shop.menuItems.where((item) {
      if (!item.isAvailable) return false;
      if (_vegOnly && !item.isVeg) return false;
      if (_selectedCategory != 'All' && item.category != _selectedCategory) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return PopScope(
      canPop: true,
      child: FluidGestureDismissible(
        onDismiss: () => context.pop(),
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.obsidianBackground,
              body: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 1. Swiggy/Zomato Collapsible App Bar with Food Hero (Bounds API Morph)
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 0,
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (shop.carouselImages.isNotEmpty)
                            Hero(
                              tag: 'shop_hero_image_${shop.id}',
                              createRectTween: SmoothTransitions.createArcTween,
                              flightShuttleBuilder: SmoothTransitions.heroFlightShuttle,
                              child: HungrNetworkImage(
                                imageUrl: shop.carouselImages.first,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x66000000),
                                  Colors.transparent,
                                  Color(0xCC000000),
                                ],
                              stops: [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                        // Bottom Shop Name & Zone
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  if (shop.isPureVeg)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'PURE VEG',
                                        style: AppTypography.monoBadge.copyWith(
                                          color: const Color(0xFF16A34A),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF15803D),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${shop.rating}',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(Icons.star_rounded, color: Colors.white, size: 11),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${shop.totalReviews}+ ratings)',
                                    style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                shop.name,
                                style: AppTypography.headlineLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
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

                // 2. Body Details
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Closed Status Alert Banner (if closed)
                        if (isClosed) ...[
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: AppDimensions.radius12,
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.zomatoRed, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.status == ShopStatus.closedToday
                                            ? 'Closed Today for Tomorrow\'s Drop'
                                            : (shop.status == ShopStatus.closedTemporary
                                                ? 'Temporarily Closed (${shop.reopenDate ?? "Back soon"})'
                                                : 'Permanently Closed'),
                                        style: AppTypography.titleSmall.copyWith(
                                          color: AppColors.zomatoRed,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        shop.closureReason ??
                                            'This tiffin center is currently taking a break. You can still view the menu, but orders cannot be placed.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: const Color(0xFF991B1B),
                                          fontSize: 11.5,
                                        ),
                                      ),
                                      if (shop.reopenDate != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Expected Reopening: ${shop.reopenDate}',
                                          style: AppTypography.caption.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Friendly Express Morning Drop Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: AppDimensions.radius12,
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.electric_bolt_rounded, color: Color(0xFF16A34A), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Fresh 7:30 AM Gate Delivery',
                                      style: AppTypography.labelLarge.copyWith(
                                        color: const Color(0xFF15803D),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Order by 9:00 PM tonight for piping-hot delivery straight to your hostel or building gate.',
                                      style: AppTypography.caption.copyWith(
                                        color: const Color(0xFF166534),
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

                        // Shop Address & Tagline Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDimensions.radius12,
                            border: Border.all(color: AppColors.charcoalBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.storefront_rounded, color: AppColors.zomatoRed, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      shop.tagline,
                                      style: AppTypography.bodySmall.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.place_outlined, color: AppColors.textSubtle, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      shop.address,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Menu Search Bar + Pure Veg Toggle (Swiggy Style)
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.charcoalBorder),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Search in ${shop.name}...',
                                    hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.zomatoRed, size: 19),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSubtle),
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() => _searchQuery = '');
                                            },
                                          )
                                        : null,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _vegOnly = !_vegOnly);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                height: 42,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: _vegOnly ? const Color(0xFFECFDF5) : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _vegOnly ? const Color(0xFF16A34A) : AppColors.charcoalBorder,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xFF16A34A), width: 1.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(Icons.circle, size: 6, color: Color(0xFF16A34A)),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Veg',
                                      style: AppTypography.labelSmall.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: _vegOnly ? const Color(0xFF15803D) : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Category Selector Pills
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              TiffinItem.categoryDailyBreakfast,
                              TiffinItem.categoryMorningAddons,
                              TiffinItem.categoryBeverages,
                            ].map((category) {
                              final isSelected = _selectedCategory == category;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selectedCategory = category);
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
                                      category,
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

                        const SizedBox(height: 16),

                        // Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu Items',
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${displayedItems.length} items',
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Items List
                        if (displayedItems.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppDimensions.radius16,
                              border: Border.all(color: AppColors.charcoalBorder),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.no_meals_outlined, color: AppColors.textSubtle, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'No matching dishes found',
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          )
                        else
                          ...displayedItems.map((rawItem) {
                            final item = rawItem.copyWith(shopId: shop.id, shopName: shop.name);
                            final quantity = (cartState.activeKitchenId == null || cartState.activeKitchenId == shop.id)
                                ? (cartState.itemQuantities[item.id] ?? 0)
                                : 0;
                            return isClosed
                                ? Opacity(
                                    opacity: 0.6,
                                    child: TiffinItemCard(
                                      item: item,
                                      quantity: 0,
                                      onAdd: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${shop.name} is currently closed. ${shop.reopenDate ?? ""}',
                                              style: AppTypography.labelLarge.copyWith(color: Colors.white),
                                            ),
                                            backgroundColor: AppColors.zomatoRed,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      onRemove: () {},
                                    ),
                                  )
                                : TiffinItemCard(
                                    item: item,
                                    quantity: quantity,
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
          ),

          // Floating Cart Bar (if user added items)
          const FloatingCartBar(),
        ],
      ),
    ),
  );
}
}
