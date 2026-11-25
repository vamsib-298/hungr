import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../../../subscription/domain/subscription_order_model.dart';
import '../../../subscription/presentation/viewmodels/subscription_history_viewmodel.dart';
import '../../../ticket_calendar/domain/meal_ticket_model.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';
import 'gate_heat_preservation_card.dart';
import 'pass_card_3d.dart';

/// Unified Swiggy-style Orders & Meal Schedule Tab
class OrdersTabView extends ConsumerStatefulWidget {
  final VoidCallback onExploreMenu;

  const OrdersTabView({
    super.key,
    required this.onExploreMenu,
  });

  @override
  ConsumerState<OrdersTabView> createState() => _OrdersTabViewState();
}

class _OrdersTabViewState extends ConsumerState<OrdersTabView> {
  int _segment = 0; // 0: Upcoming Meals, 1: Order History

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(customerDashboardProvider);
    final historyState = ref.watch(subscriptionHistoryProvider);
    final tickets = dashboardState.tickets;
    final orders = historyState.orders;

    // Only show heat preservation card when an actual meal is delivered today
    final deliveredToday = tickets.where((t) {
      if (t.status != TicketStatusType.delivered || t.deliveredAt == null) return false;
      final now = DateTime.now();
      return t.deliveredAt!.year == now.year &&
          t.deliveredAt!.month == now.month &&
          t.deliveredAt!.day == now.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.obsidianBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Orders & Schedule',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Track drops, pause meals, or view receipts',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Segmented Toggle Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildSegmentBtn('Upcoming (${tickets.length})', 0),
                  _buildSegmentBtn('Order History (${orders.length})', 1),
                ],
              ),
            ),
          ),

          Expanded(
            child: _segment == 0
                ? _buildUpcomingTab(dashboardState, tickets, deliveredToday)
                : _buildOrderHistoryTab(historyState, orders),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBtn(String label, int index) {
    final active = _segment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _segment = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? const [BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? AppColors.zomatoRed : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingTab(
    CustomerDashboardState dashboardState,
    List<MealTicket> tickets,
    List<MealTicket> deliveredToday,
  ) {
    if (tickets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.breakfast_dining_outlined,
        title: 'No Upcoming Morning Meals',
        subtitle: 'Order a fresh South Indian breakfast or activate a routine pass for 7:30 AM gate delivery.',
        ctaLabel: 'Browse Breakfast Menu',
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        if (dashboardState.hasActivePass) ...[
          ObsidianCard(
            borderColor: AppColors.zomatoRed.withOpacity(0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dashboardState.activeTier.displayName,
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.zomatoRedSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${dashboardState.mealsRemaining} / ${dashboardState.totalMeals} LEFT',
                        style: AppTypography.monoBadge.copyWith(
                          color: AppColors.zomatoRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Drop Gate: ${dashboardState.selectedCluster.name}',
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: AppDimensions.radiusCircle,
                  child: LinearProgressIndicator(
                    value: dashboardState.totalMeals > 0
                        ? dashboardState.mealsRemaining / dashboardState.totalMeals
                        : 0,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.zomatoRed),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Only show live Heat Preservation card when an actual meal is delivered today
        if (deliveredToday.isNotEmpty) ...[
          GateHeatPreservationCard(
            bagToken: deliveredToday.first.bagToken,
            clusterName: deliveredToday.first.clusterName,
            droppedAt: deliveredToday.first.deliveredAt!,
          ),
          const SizedBox(height: 8),
        ],

        ...List.generate(tickets.length, (index) {
          final ticket = tickets[index];
          final isSkipped = ticket.status == TicketStatusType.skipped;
          final dateStr = DateFormat('EEE, dd MMM yyyy').format(ticket.deliveryDate);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ObsidianCard(
              borderColor: isSkipped
                  ? AppColors.urgentCrimson.withOpacity(0.35)
                  : (index == 0 ? AppColors.zomatoRed.withOpacity(0.6) : AppColors.charcoalBorder),
              backgroundColor: isSkipped ? AppColors.urgentCrimsonSurface : Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.bagToken,
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF1D4ED8),
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateStr,
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSkipped ? const Color(0xFFFEE2E2) : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isSkipped ? 'PAUSED' : 'CONFIRMED',
                          style: AppTypography.monoBadge.copyWith(
                            color: isSkipped ? AppColors.urgentCrimson : AppColors.neonMint,
                            fontWeight: FontWeight.bold,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.specialtyName ??
                                  (ticket.comboSelection == 'A'
                                      ? 'Option A: Hot Set Dosa'
                                      : 'Option B: Steamed Idli & Vada'),
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: isSkipped ? TextDecoration.lineThrough : null,
                                color: isSkipped ? AppColors.textSubtle : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isSkipped
                                  ? 'Paused • Meal credit preserved'
                                  : '07:30 AM • ${ticket.clusterName}',
                              style: AppTypography.caption.copyWith(
                                color: isSkipped ? AppColors.urgentCrimson : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isSkipped) ...[
                        OutlinedButton(
                          onPressed: () => _showSwitchComboDialog(ticket),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            side: const BorderSide(color: AppColors.charcoalBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Swap', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref.read(customerDashboardProvider.notifier).togglePauseTicket(ticket.ticketId);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            side: BorderSide(color: AppColors.urgentCrimson.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Pause', style: TextStyle(fontSize: 11, color: AppColors.urgentCrimson)),
                        ),
                      ] else
                        OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ref.read(customerDashboardProvider.notifier).togglePauseTicket(ticket.ticketId);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            side: const BorderSide(color: AppColors.neonMint),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Resume', style: TextStyle(fontSize: 11, color: AppColors.neonMint)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOrderHistoryTab(SubscriptionHistoryState historyState, List<SubscriptionOrder> orders) {
    if (historyState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.zomatoRed));
    }
    if (orders.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No Orders Yet',
        subtitle: 'Your single-day tiffin orders and meal pass receipts will appear here.',
        ctaLabel: 'Order Breakfast Now',
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final isActive = order.status == SubscriptionStatus.active;
        final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(order.purchaseDate);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ObsidianCard(
            borderColor: isActive ? AppColors.zomatoRed.withOpacity(0.45) : AppColors.charcoalBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order.passTitle,
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      '₹${order.amountPaid}',
                      style: AppTypography.monoPrice.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  order.selectedCombo,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$dateStr • Bag ${order.transactionId}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10.5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        isActive ? 'CONFIRMED' : 'DELIVERED',
                        style: AppTypography.monoBadge.copyWith(
                          color: isActive ? AppColors.neonMint : AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String ctaLabel,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: AppColors.zomatoRed),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onExploreMenu,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.zomatoRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(ctaLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitchComboDialog(MealTicket ticket) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Swap Tomorrow\'s Meal', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.breakfast_dining, color: AppColors.zomatoRed),
              title: const Text('Option A: Hot Set Dosa (2 Pcs) + Sambar'),
              trailing: ticket.comboSelection == 'A' ? const Icon(Icons.check_circle, color: AppColors.zomatoRed) : null,
              onTap: () {
                ref.read(customerDashboardProvider.notifier).switchTicketCombo(ticket.ticketId, 'A');
                Navigator.of(ctx).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dinner_dining, color: AppColors.zomatoRed),
              title: const Text('Option B: Steamed Idlis (4 Pcs) + Vada'),
              trailing: ticket.comboSelection == 'B' ? const Icon(Icons.check_circle, color: AppColors.zomatoRed) : null,
              onTap: () {
                ref.read(customerDashboardProvider.notifier).switchTicketCombo(ticket.ticketId, 'B');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
