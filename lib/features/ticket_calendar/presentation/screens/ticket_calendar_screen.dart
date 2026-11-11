import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../../domain/meal_ticket_model.dart';

class TicketCalendarScreen extends ConsumerStatefulWidget {
  const TicketCalendarScreen({super.key});

  @override
  ConsumerState<TicketCalendarScreen> createState() => _TicketCalendarScreenState();
}

class _TicketCalendarScreenState extends ConsumerState<TicketCalendarScreen> {
  int _filterIndex = 0; // 0: All, 1: Scheduled, 2: Paused

  void _showPauseConfirmation(MealTicket ticket, int dayIndex) {
    HapticFeedback.lightImpact();
    final dateStr = DateFormat('EEEE, dd MMM').format(ticket.deliveryDate);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.matteCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.urgentCrimson.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pause_circle_outline, color: AppColors.urgentCrimson, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text('Pause Meal on $dateStr?', style: AppTypography.headlineMedium),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '• No meal or money wasted.\n'
                '• 1 replacement ticket will be automatically added to the end of your pass schedule.\n'
                '• You can unpause anytime before 9:00 PM tonight.',
                style: AppTypography.bodyMedium.copyWith(height: 1.6),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Keep Active', style: AppTypography.labelLarge.copyWith(color: AppColors.textSubtle)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.urgentCrimson,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppDimensions.radius12,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        final success = ref.read(customerDashboardProvider.notifier).togglePauseTicket(ticket.ticketId);
                        HapticFeedback.mediumImpact();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.matteCharcoal,
                              content: Text('Meal paused! Replacement ticket added to next week.', style: AppTypography.labelLarge),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: const Text('Confirm Pause'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSwitchComboModal(MealTicket ticket) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.matteCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.charcoalBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Change Meal Option', style: AppTypography.headlineMedium),
              const SizedBox(height: 4),
              Text('Select your preferred tiffin for this date:', style: AppTypography.bodySmall),
              const SizedBox(height: 16),
              ObsidianCard(
                borderColor: ticket.comboSelection == 'A' ? AppColors.zomatoRed : AppColors.charcoalBorder,
                borderWidth: ticket.comboSelection == 'A' ? 1.8 : 1.0,
                onTap: () {
                  ref.read(customerDashboardProvider.notifier).switchTicketCombo(ticket.ticketId, 'A');
                  Navigator.of(context).pop();
                  HapticFeedback.selectionClick();
                },
                child: Row(
                  children: [
                    const Icon(Icons.breakfast_dining, color: AppColors.zomatoRed, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Option A: 2 Hot Set Dosas', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Groundnut & Ginger Chutney + Hot Sambar', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    if (ticket.comboSelection == 'A')
                      const Icon(Icons.check_circle, color: AppColors.zomatoRed, size: 22),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ObsidianCard(
                borderColor: ticket.comboSelection == 'B' ? AppColors.zomatoRed : AppColors.charcoalBorder,
                borderWidth: ticket.comboSelection == 'B' ? 1.8 : 1.0,
                onTap: () {
                  ref.read(customerDashboardProvider.notifier).switchTicketCombo(ticket.ticketId, 'B');
                  Navigator.of(context).pop();
                  HapticFeedback.selectionClick();
                },
                child: Row(
                  children: [
                    const Icon(Icons.dinner_dining, color: AppColors.zomatoRed, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Option B: 4 Steamed Idlis + 1 Vada', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Coconut Chutney + Drumstick Sambar', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    if (ticket.comboSelection == 'B')
                      const Icon(Icons.check_circle, color: AppColors.zomatoRed, size: 22),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(customerDashboardProvider);
    final tickets = dashboardState.tickets;

    final filteredTickets = tickets.where((ticket) {
      if (_filterIndex == 1) return ticket.status == TicketStatusType.scheduled;
      if (_filterIndex == 2) return ticket.status == TicketStatusType.skipped;
      return true;
    }).toList();

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
      child: Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        appBar: AppBar(
          title: Text(
            'Meal Schedule & Tickets',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
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
        ),
      body: CustomScrollView(
        slivers: [
          // Active Pass Overview Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: ObsidianCard(
                borderColor: AppColors.electricSaffron.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Active Pass Schedule', style: AppTypography.headlineMedium),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.electricSaffron.withOpacity(0.18),
                            borderRadius: AppDimensions.radius8,
                          ),
                          child: Text(
                            '${dashboardState.mealsRemaining} / ${dashboardState.totalMeals} MEALS LEFT',
                            style: AppTypography.monoBadge.copyWith(
                              color: AppColors.electricSaffron,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Drop Gate: ${dashboardState.selectedCluster.name}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedSlate),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: AppDimensions.radiusCircle,
                      child: LinearProgressIndicator(
                        value: dashboardState.totalMeals > 0
                            ? (dashboardState.mealsRemaining / dashboardState.totalMeals)
                            : 0,
                        backgroundColor: AppColors.surfaceHighlight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricSaffron),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter Chips (Scrollable to prevent overflow)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterTab('All (${tickets.length})', 0),
                    const SizedBox(width: 8),
                    _buildFilterTab('Scheduled (${tickets.where((t) => t.status == TicketStatusType.scheduled).length})', 1),
                    const SizedBox(width: 8),
                    _buildFilterTab('Paused (${tickets.where((t) => t.status == TicketStatusType.skipped).length})', 2),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Tickets List
          if (filteredTickets.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.event_available_outlined, size: 48, color: AppColors.textSubtle),
                    const SizedBox(height: 12),
                    Text('No tickets in this category', style: AppTypography.titleMedium),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final ticket = filteredTickets[index];
                    final isSkipped = ticket.status == TicketStatusType.skipped;
                    final isTomorrow = index == 0;
                    final dateFormatted = DateFormat('EEE, dd MMM yyyy').format(ticket.deliveryDate);
                    final comboTitle = ticket.comboSelection == 'A'
                        ? 'Option A: 2 Hot Set Dosas'
                        : 'Option B: 4 Idlis + 1 Vada';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ObsidianCard(
                        borderColor: isSkipped
                            ? AppColors.urgentCrimson.withOpacity(0.4)
                            : (isTomorrow ? AppColors.zomatoRed : AppColors.charcoalBorder),
                        borderWidth: isTomorrow ? 1.5 : 1.0,
                        backgroundColor: isSkipped ? AppColors.urgentCrimsonSurface : Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date & Status Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isTomorrow
                                              ? AppColors.zomatoRed.withOpacity(0.2)
                                              : AppColors.surfaceHighlight,
                                          borderRadius: AppDimensions.radius8,
                                          border: Border.all(
                                            color: isTomorrow ? AppColors.zomatoRed : AppColors.charcoalBorder,
                                          ),
                                        ),
                                        child: Text(
                                          isTomorrow ? 'TOMORROW' : 'DAY ${index + 1}',
                                          style: AppTypography.monoBadge.copyWith(
                                            color: isTomorrow ? AppColors.zomatoRedLight : AppColors.textCrispWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          dateFormatted,
                                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isSkipped
                                        ? AppColors.urgentCrimson.withOpacity(0.18)
                                        : AppColors.neonMint.withOpacity(0.15),
                                    borderRadius: AppDimensions.radius8,
                                  ),
                                  child: Text(
                                    isSkipped ? 'PAUSED' : 'CONFIRMED',
                                    style: AppTypography.monoBadge.copyWith(
                                      color: isSkipped ? AppColors.urgentCrimson : AppColors.neonMint,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Combo Details Row
                            Row(
                              children: [
                                Icon(
                                  ticket.comboSelection == 'A' ? Icons.breakfast_dining : Icons.dinner_dining,
                                  color: isSkipped ? AppColors.textSubtle : AppColors.electricSaffron,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comboTitle,
                                        style: AppTypography.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: isSkipped ? AppColors.textSubtle : AppColors.textCrispWhite,
                                          decoration: isSkipped ? TextDecoration.lineThrough : null,
                                        ),
                                      ),
                                      Text(
                                        isSkipped
                                            ? 'Pushed to end of subscription'
                                            : '07:30 AM • ${ticket.clusterName}',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isSkipped ? AppColors.urgentCrimson : AppColors.textMutedSlate,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Action Buttons
                                if (!isSkipped) ...[
                                  InkWell(
                                    onTap: () => _showSwitchComboModal(ticket),
                                    borderRadius: AppDimensions.radius8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.surfaceHighlight,
                                        borderRadius: AppDimensions.radius8,
                                      ),
                                      child: Text(
                                        'Switch',
                                        style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.textCrispWhite),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _showPauseConfirmation(ticket, index),
                                    borderRadius: AppDimensions.radius8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.urgentCrimsonSurface,
                                        borderRadius: AppDimensions.radius8,
                                        border: Border.all(color: AppColors.urgentCrimson.withOpacity(0.4)),
                                      ),
                                      child: Text(
                                        'Pause',
                                        style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.urgentCrimson, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ] else
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      ref.read(customerDashboardProvider.notifier).togglePauseTicket(ticket.ticketId);
                                    },
                                    borderRadius: AppDimensions.radius8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: AppDimensions.radius8,
                                        border: Border.all(color: const Color(0xFFA7F3D0)),
                                      ),
                                      child: Text(
                                        'Resume',
                                        style: AppTypography.labelSmall.copyWith(fontSize: 10, color: AppColors.neonMint, fontWeight: FontWeight.bold),
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
                  childCount: filteredTickets.length,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

  Widget _buildFilterTab(String label, int index) {
    final isSelected = _filterIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filterIndex = index);
      },
      borderRadius: AppDimensions.radiusCircle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.electricSaffron : AppColors.matteCharcoal,
          borderRadius: AppDimensions.radiusCircle,
          border: Border.all(
            color: isSelected ? AppColors.electricSaffron : AppColors.charcoalBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.black : AppColors.textMutedSlate,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
