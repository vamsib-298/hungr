import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/animations/fluid_gesture_dismissible.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../../../../core/widgets/confetti_burst_overlay.dart';
import '../../../subscription/presentation/viewmodels/subscription_history_viewmodel.dart';
import '../../../subscription/presentation/viewmodels/referral_viewmodel.dart';
import '../../domain/tiffin_item_model.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import '../widgets/pass_card_3d.dart';

/// Flagship Dedicated Checkout Screen
/// Supports both Single-Day Tiffin Ordering and Subscription Pass Purchasing
/// with real-time bill breakdown, coupon applications, and UPI / Cash-on-Drop payments.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final GlobalKey<ConfettiBurstOverlayState> _confettiKey = GlobalKey();
  bool _isPlacingOrder = false;
  String? _couponError;

  @override
  void dispose() {
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final cartNotifier = ref.read(cartViewModelProvider.notifier);
    final success = cartNotifier.applyCoupon(code);
    setState(() {
      if (success) {
        _couponError = null;
        HapticFeedback.lightImpact();
      } else {
        _couponError = 'Invalid promo code. Try FIRST50 or HUNGRFREE';
        HapticFeedback.vibrate();
      }
    });
  }

  Future<void> _handlePlaceOrder(CustomerDashboardState customerState, CartState cartState) async {
    if (_isPlacingOrder) return;
    setState(() => _isPlacingOrder = true);
    HapticFeedback.mediumImpact();

    // Simulate payment intent processing
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    // Trigger celebratory confetti
    _confettiKey.currentState?.burstAtCenter();

    final isSingleDay = cartState.orderMode == OrderMode.singleDay;
    final bagToken = DateTimeUtils.generateBagToken(customerState.selectedCluster.name, 4);
    final targetDateLabel = DateTimeUtils.targetDeliveryLabel();

    if (isSingleDay) {
      // Single-Day Tiffin Order: Create a fresh single-day ticket in the dashboard
      final selectedItems = cartState.itemQuantities.keys.toList();
      ref.read(customerDashboardProvider.notifier).activateNewPass(
            tier: PassTierType.trial3Day,
            combo: 'A',
            addons: selectedItems.toSet(),
            companionMeals: cartState.roommateMealCount,
            bagToken: bagToken,
          );
    } else {
      // Pass Order: Activate Pass in Dashboard
      final tier = cartState.selectedPassTier ?? PassTierType.routine7Day;
      ref.read(customerDashboardProvider.notifier).activateNewPass(
            tier: tier,
            combo: 'A',
            addons: cartState.itemQuantities.keys.toSet(),
            autoRotateSpecialties: cartState.autoRotatePassMenu,
            companionMeals: cartState.roommateMealCount,
            bagToken: bagToken,
          );

      // Record in Subscription History
      ref.read(subscriptionHistoryProvider.notifier).addSubscription(
            tier: tier,
            combo: 'A',
            addons: cartState.itemQuantities.keys.toSet(),
            totalAmount: cartState.totalPayable,
            clusterName: customerState.selectedCluster.name,
          );
    }

    // Reset Cart
    ref.read(cartViewModelProvider.notifier).reset();

    // Show Confirmation Dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.neonMint, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              isSingleDay ? 'Morning Drop Confirmed!' : 'Pass Activated Successfully!',
              style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Parcel Bag Token Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: Column(
                children: [
                  Text(
                    'YOUR PARCEL BAG TOKEN',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF1D4ED8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bagToken,
                    style: AppTypography.headlineLarge.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your breakfast arrives on $targetDateLabel at ${cartState.selectedDeliverySlot} at ${customerState.selectedCluster.name}.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // WhatsApp Gate Drop Alert Pill
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_chat_unread_rounded, size: 16, color: Color(0xFF16A34A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Automated WhatsApp Drop Alert will ping you the moment Bag $bagToken is placed at the gate security desk.',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF15803D),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  context.go(RouteNames.ticketCalendar);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.zomatoRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('View Morning Ticket ➔', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );

    setState(() => _isPlacingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    final customerState = ref.watch(customerDashboardProvider);
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartViewModelProvider.notifier);

    final bool isSingleDay = cartState.orderMode == OrderMode.singleDay;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.storefront);
        }
      },
      child: ConfettiBurstOverlay(
        key: _confettiKey,
        child: FluidGestureDismissible(
          onDismiss: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.storefront);
            }
          },
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
                    context.go(RouteNames.storefront);
                  }
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSingleDay ? 'Checkout • Single-Day Drop' : 'Checkout • Morning Pass',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Delivering to ${customerState.selectedCluster.name}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.urgentCrimson),
                  tooltip: 'Clear Cart',
                  onPressed: () {
                    cartNotifier.clearCart();
                    context.pop();
                  },
                ),
              ],
            ),
            body: cartState.isEmpty
                ? _buildEmptyState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Delivery Gate Location Card (Slot 1: 0ms)
                        _buildGateLocationCard(customerState)
                            .animate()
                            .fadeIn(duration: 200.ms)
                            .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 2. Delivery Slot Picker (Slot 2: 50ms)
                        _buildSlotSelector(cartState, cartNotifier)
                            .animate()
                            .fadeIn(delay: 50.ms, duration: 220.ms)
                            .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 3. Order Items Summary Card (Slot 3: 100ms)
                        _buildOrderSummaryCard(cartState, cartNotifier)
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 240.ms)
                            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 4. Quick Add-ons Upsell (Slot 4: 140ms)
                        if (isSingleDay) ...[
                          _buildAddonsUpsell(cartState, cartNotifier)
                              .animate()
                              .fadeIn(delay: 140.ms, duration: 250.ms)
                              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                          const SizedBox(height: 12),
                        ],

                        // 4B. Roommate Split & Save Companion Drop (Slot 4B: 160ms)
                        _buildRoommateCompanionCard(cartState, cartNotifier)
                            .animate()
                            .fadeIn(delay: 160.ms, duration: 250.ms)
                            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 5. Promo Code & Offers (Slot 5: 180ms)
                        _buildPromoSection(cartState, cartNotifier)
                            .animate()
                            .fadeIn(delay: 180.ms, duration: 260.ms)
                            .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 6. Delivery Instructions (Slot 6: 220ms)
                        _buildInstructionsCard()
                            .animate()
                            .fadeIn(delay: 220.ms, duration: 270.ms)
                            .slideY(begin: 0.07, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 7. Payment Method Selector (Slot 7: 260ms)
                        _buildPaymentSelector(cartState, cartNotifier)
                            .animate()
                            .fadeIn(delay: 260.ms, duration: 280.ms)
                            .slideY(begin: 0.07, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 12),

                        // 8. Detailed Bill Breakdown (Slot 8: 300ms)
                        _buildBillSummary(cartState)
                            .animate()
                            .fadeIn(delay: 300.ms, duration: 300.ms)
                            .slideY(begin: 0.07, end: 0, curve: Curves.easeOutCubic),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
            bottomSheet: cartState.isEmpty
                ? null
                : _buildStickyPayBar(customerState, cartState)
                    .animate()
                    .fadeIn(delay: 180.ms, duration: 320.ms)
                    .slideY(begin: 0.20, end: 0, curve: Curves.fastLinearToSlowEaseIn),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 54, color: AppColors.textSubtle),
            ),
            const SizedBox(height: 16),
            Text(
              'Your breakfast cart is empty',
              style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Select hot South Indian tiffin items or choose a weekly pass to save up to ₹360.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.zomatoRed,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Browse Morning Menu', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateLocationCard(CustomerDashboardState customerState) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.zomatoRedSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.zomatoRed, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'HOSTEL GATE DROP',
                      style: AppTypography.monoBadge.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.zomatoRed,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FREE DROP',
                        style: AppTypography.caption.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonMint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        DateTimeUtils.generateBagToken(customerState.selectedCluster.name, 4),
                        style: AppTypography.monoBadge.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  customerState.selectedCluster.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${customerState.selectedCluster.addressZone} • ${customerState.selectedCluster.landmark}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF2563EB)),
                      const SizedBox(width: 4),
                      Text(
                        'Security Desk Drop Only • No floor delivery',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF1E40AF),
                          fontWeight: FontWeight.bold,
                          fontSize: 9.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(RouteNames.clusterSelection),
            child: Text(
              'Change',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.zomatoRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelector(CartState cartState, CartViewModel cartNotifier) {
    const slots = ['07:30 AM – 08:00 AM', '08:00 AM – 08:30 AM'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.goldenAmber),
                  const SizedBox(width: 6),
                  Text(
                    'Select Morning Delivery Slot',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  DateTimeUtils.targetDeliveryLabel(),
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9.5,
                    color: AppColors.zomatoRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: slots.map((slot) {
              final isSelected = cartState.selectedDeliverySlot == slot;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    cartNotifier.selectDeliverySlot(slot);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: slot == slots.first ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.zomatoRedSurface : const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        slot,
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.zomatoRed : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartState cartState, CartViewModel cartNotifier) {
    final isSingleDay = cartState.orderMode == OrderMode.singleDay;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSingleDay ? 'Selected Items' : 'Selected Subscription Plan',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                isSingleDay ? '${cartState.totalItemCount} items' : 'Flexible Rollover',
                style: AppTypography.caption.copyWith(color: AppColors.neonMint, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.charcoalBorder),

          if (isSingleDay) ...[
            ...cartState.itemQuantities.entries.map((entry) {
              final item = TiffinItem.findById(entry.key);
              if (item == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.isVeg ? AppColors.neonMint : AppColors.urgentCrimson,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '₹${item.price} each',
                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Quantity adjustments
                    Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.zomatoRedSurface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.zomatoRedBorder),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              cartNotifier.removeItem(item.id);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.remove, size: 14, color: AppColors.zomatoRed),
                            ),
                          ),
                          Text(
                            '${entry.value}',
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.zomatoRed,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              cartNotifier.addItem(item.id);
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.add, size: 14, color: AppColors.zomatoRed),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '₹${item.price * entry.value}',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ] else ...[
            // Pass Tier Display
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.goldenAmberSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.card_membership_rounded, color: AppColors.goldenAmber, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cartState.selectedPassTier == PassTierType.trial3Day
                            ? '3-Day Starter Pass'
                            : (cartState.selectedPassTier == PassTierType.power15Day
                                ? '15-Day Power Pass'
                                : '7-Day Routine Pass'),
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${cartState.selectedPassDays} Breakfast Meals • Pause anytime before 9 PM',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${cartState.passSubtotal}',
                  style: AppTypography.monoPrice.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (cartState.selectedPassTier == PassTierType.trial3Day) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push(RouteNames.referral);
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ref.watch(referralProvider).isRewardUnlocked
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: ref.watch(referralProvider).isRewardUnlocked
                          ? const Color(0xFFA7F3D0)
                          : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 16,
                        color: ref.watch(referralProvider).isRewardUnlocked
                            ? AppColors.neonMint
                            : AppColors.goldenAmber,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ref.watch(referralProvider).isRewardUnlocked
                              ? '3 Referrals Completed! Claim this 3-Day Pass for ₹0 ➔'
                              : 'Want this pass for FREE? Refer 3 friends who order to unlock for ₹0 (${ref.watch(referralProvider).qualifiedOrderCount}/3) ➔',
                          style: AppTypography.caption.copyWith(
                            color: ref.watch(referralProvider).isRewardUnlocked
                                ? AppColors.neonMint
                                : const Color(0xFF92400E),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            // 1-Tap Smart Pass Menu Auto-Rotation
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.charcoalBorder),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: cartState.autoRotatePassMenu,
                    activeColor: AppColors.zomatoRed,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      cartNotifier.toggleAutoRotatePassMenu(val ?? true);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Rotate Authentic Khammam Variety',
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Mon: Set Dosa • Tue: Thatte Idli • Wed: Poori • Thu: Pesarattu • Fri: Bonda • Sat: Udupi Dosa',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddonsUpsell(CartState cartState, CartViewModel cartNotifier) {
    final addons = [
      TiffinItem.findById('addon_filter_coffee'),
      TiffinItem.findById('addon_boiled_eggs'),
      TiffinItem.findById('addon_badam_milk'),
    ].whereType<TiffinItem>().toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Amber-50 Soft Morning Glow
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_cafe_rounded, size: 16, color: AppColors.goldenAmber),
              const SizedBox(width: 6),
              Text(
                'Complete Your Morning Breakfast',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: addons.map((addon) {
                final int qty = cartState.itemQuantities[addon.id] ?? 0;
                final bool isAdded = qty > 0;

                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isAdded ? AppColors.zomatoRed : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.name,
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${addon.price}',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (isAdded) {
                              cartNotifier.removeItem(addon.id);
                            } else {
                              cartNotifier.addItem(addon.id);
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isAdded ? AppColors.zomatoRedSurface : Colors.white,
                            side: BorderSide(
                              color: isAdded ? AppColors.zomatoRed : AppColors.charcoalBorder,
                            ),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            isAdded ? 'ADDED ($qty)' : '+ ADD',
                            style: AppTypography.caption.copyWith(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: isAdded ? AppColors.zomatoRed : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoommateCompanionCard(CartState cartState, CartViewModel cartNotifier) {
    final bool hasCompanion = cartState.roommateMealCount > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasCompanion ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(
          color: hasCompanion ? const Color(0xFF93C5FD) : AppColors.charcoalBorder,
          width: hasCompanion ? 1.4 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.people_alt_rounded, size: 20, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Roommate Split & Save',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'SAVE ₹14',
                        style: AppTypography.caption.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Add roommate breakfast for +₹45 (instead of ₹59) • Packed in same gate bag',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!hasCompanion)
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                cartNotifier.addRoommateMeal();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.zomatoRed,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                '+ Add (₹45)',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            )
          else
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cartNotifier.removeRoommateMeal();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.remove, size: 14, color: Color(0xFF1D4ED8)),
                    ),
                  ),
                  Text(
                    '${cartState.roommateMealCount}',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cartNotifier.addRoommateMeal();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.add, size: 14, color: Color(0xFF1D4ED8)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromoSection(CartState cartState, CartViewModel cartNotifier) {
    final bool hasCoupon = cartState.appliedCoupon != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer_outlined, size: 16, color: AppColors.zomatoRed),
              const SizedBox(width: 6),
              Text(
                'Coupons & Discounts',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (hasCoupon) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.neonMint, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${cartState.appliedCoupon} Applied (₹${cartState.discountAmount} SAVED)',
                        style: AppTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonMint,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      cartNotifier.removeCoupon();
                    },
                    child: Text(
                      'Remove',
                      style: AppTypography.caption.copyWith(color: AppColors.urgentCrimson, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon (e.g. FIRST50)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      isDense: true,
                      fillColor: const Color(0xFFF9FAFB),
                      hintStyle: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('APPLY', style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (_couponError != null) ...[
              const SizedBox(height: 6),
              Text(
                _couponError!,
                style: AppTypography.caption.copyWith(color: AppColors.urgentCrimson, fontSize: 11),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '💡 Tip: Use FIRST50 for ₹50 off on first orders, or HUNGRFREE for ₹25 off',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.note_alt_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Gate Drop Instructions',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'e.g. Leave at security desk, hostel block B, call on drop...',
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
              hintStyle: AppTypography.caption.copyWith(color: AppColors.textSubtle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSelector(CartState cartState, CartViewModel cartNotifier) {
    final activeMethods = [
      {'name': 'Google Pay', 'icon': Icons.account_balance_wallet_rounded, 'tag': 'RECOMMENDED (UPI)'},
      {'name': 'PhonePe', 'icon': Icons.payment_rounded, 'tag': 'UPI'},
      {'name': 'Paytm', 'icon': Icons.qr_code_scanner_rounded, 'tag': 'UPI / WALLET'},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.credit_card_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Payment Method',
                style: AppTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '100% PRE-PAID SECURE',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.neonMint,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Active UPI Methods
          ...activeMethods.map((m) {
            final String name = m['name'] as String;
            final IconData icon = m['icon'] as IconData;
            final String tag = m['tag'] as String;
            final isSelected = cartState.paymentMethod == name;

            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                cartNotifier.setPaymentMethod(name);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.zomatoRedSurface : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                    width: isSelected ? 1.4 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 20, color: isSelected ? AppColors.zomatoRed : AppColors.textSecondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            name,
                            style: AppTypography.labelLarge.copyWith(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.zomatoRed : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.zomatoRed.withOpacity(0.12) : const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tag,
                              style: AppTypography.monoBadge.copyWith(
                                color: isSelected ? AppColors.zomatoRed : AppColors.textSecondary,
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: name,
                      groupValue: cartState.paymentMethod,
                      activeColor: AppColors.zomatoRed,
                      onChanged: (val) {
                        if (val != null) cartNotifier.setPaymentMethod(val);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),

          // Disabled Cash on Delivery Option (Requirement 1)
          InkWell(
            onTap: () {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.urgentCrimson,
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    'Cash on Delivery is NOT available for 7:30 AM drops. All morning tiffins are prepaid via UPI to guarantee zero-contact 2-minute gate drops.',
                    style: AppTypography.labelLarge.copyWith(color: Colors.white, fontSize: 12),
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.money_off_rounded, size: 20, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              'Cash on Delivery',
                              style: AppTypography.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'NOT AVAILABLE',
                                style: AppTypography.monoBadge.copyWith(
                                  color: AppColors.urgentCrimson,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Radio<String>(
                        value: 'Cash on Delivery',
                        groupValue: null,
                        onChanged: null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      'Disabled for morning gate drops to prevent delivery bottlenecks. Hostel security guards will not accept unpaid parcels.',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 10,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary(CartState cartState) {
    final isSingleDay = cartState.orderMode == OrderMode.singleDay;
    final int subtotal = isSingleDay ? cartState.itemsSubtotal : cartState.passSubtotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: AppColors.charcoalBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isSingleDay ? 'Item Total' : 'Pass Subscription Fee',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                '₹$subtotal',
                style: AppTypography.titleSmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Gate Drop Delivery', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 13)),
              Row(
                children: [
                  Text('₹30', style: AppTypography.caption.copyWith(decoration: TextDecoration.lineThrough, color: AppColors.textSubtle)),
                  const SizedBox(width: 4),
                  Text('FREE', style: AppTypography.caption.copyWith(color: AppColors.neonMint, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Eco-Friendly Steam Packaging', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 13)),
              Text('FREE', style: AppTypography.caption.copyWith(color: AppColors.neonMint, fontWeight: FontWeight.bold)),
            ],
          ),
          if (cartState.roommateMealCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Roommate Companion (${cartState.roommateMealCount}x)',
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF1D4ED8), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(₹45/meal)',
                      style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10),
                    ),
                  ],
                ),
                Text(
                  '+₹${cartState.roommateSubtotal}',
                  style: AppTypography.titleSmall.copyWith(color: const Color(0xFF1D4ED8), fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Roommate Split Savings',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.neonMint, fontSize: 13),
                ),
                Text(
                  '-₹${cartState.roommateMealCount * 14}',
                  style: AppTypography.titleSmall.copyWith(color: AppColors.neonMint, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coupon Discount (${cartState.appliedCoupon})', style: AppTypography.bodySmall.copyWith(color: AppColors.neonMint, fontSize: 13)),
                Text('-₹${cartState.discountAmount}', style: AppTypography.titleSmall.copyWith(color: AppColors.neonMint, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          const Divider(height: 24, color: AppColors.charcoalBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'To Pay',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Inclusive of all taxes',
                    style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10),
                  ),
                ],
              ),
              Text(
                '₹${cartState.totalPayable}',
                style: AppTypography.monoPrice.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.zomatoRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyPayBar(CustomerDashboardState customerState, CartState cartState) {
    final bool isCod = cartState.paymentMethod == 'Cash on Delivery';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.charcoalBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL PAYABLE',
                  style: AppTypography.monoBadge.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '₹${cartState.totalPayable}',
                  style: AppTypography.monoPrice.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: (_isPlacingOrder || isCod) ? null : () => _handlePlaceOrder(customerState, cartState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCod ? const Color(0xFFE5E7EB) : AppColors.zomatoRed,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    elevation: isCod ? 0 : 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isPlacingOrder
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isCod ? 'COD Not Available • Select UPI' : 'Pay ₹${cartState.totalPayable}',
                              style: AppTypography.labelLarge.copyWith(
                                color: isCod ? const Color(0xFF6B7280) : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            if (!isCod) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
