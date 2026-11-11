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
import '../../domain/subscription_order_model.dart';
import '../viewmodels/subscription_history_viewmodel.dart';

class SubscriptionHistoryScreen extends ConsumerStatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  ConsumerState<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends ConsumerState<SubscriptionHistoryScreen> {
  int _selectedFilter = 0; // 0: All, 1: Active, 2: Completed

  void _showInvoiceSheet(SubscriptionOrder order) {
    HapticFeedback.lightImpact();
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.matteCharcoal,
      isScrollControlled: true,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subscription Receipt', style: AppTypography.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textCrispWhite, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.obsidianBackground,
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Order ID', order.id),
                    const Divider(height: 16, color: AppColors.surfaceHighlight),
                    _buildReceiptRow('Pass Plan', order.passTitle),
                    const Divider(height: 16, color: AppColors.surfaceHighlight),
                    _buildReceiptRow('Drop Point', order.clusterName),
                    const Divider(height: 16, color: AppColors.surfaceHighlight),
                    _buildReceiptRow('Purchased On', dateFormat.format(order.purchaseDate)),
                    const Divider(height: 16, color: AppColors.surfaceHighlight),
                    _buildReceiptRow('Payment Mode', order.paymentMethod),
                    const Divider(height: 16, color: AppColors.surfaceHighlight),
                    _buildReceiptRow('Transaction ID', order.transactionId),
                    const Divider(height: 20, color: AppColors.zomatoRed),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Paid', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          '₹${order.amountPaid}',
                          style: AppTypography.monoPrice.copyWith(
                            color: AppColors.electricSaffron,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceHighlight,
                    foregroundColor: AppColors.textCrispWhite,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppDimensions.radius12,
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.neonMint),
                  label: const Text('Payment Confirmed via Razorpay UPI'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle)),
        Flexible(
          child: Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textCrispWhite,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(subscriptionHistoryProvider);
    final allOrders = historyState.orders;

    final filteredOrders = allOrders.where((order) {
      if (_selectedFilter == 1) return order.status == SubscriptionStatus.active;
      if (_selectedFilter == 2) return order.status == SubscriptionStatus.completed;
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
            'Subscription & Orders',
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
          // Filter Tabs Pill
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All Passes (${allOrders.length})', 0),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Active (${allOrders.where((o) => o.status == SubscriptionStatus.active).length})',
                      1,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'Past (${allOrders.where((o) => o.status == SubscriptionStatus.completed).length})',
                      2,
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (filteredOrders.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.textSubtle),
                    const SizedBox(height: 12),
                    Text('No subscriptions found', style: AppTypography.titleMedium),
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
                    final order = filteredOrders[index];
                    final isActive = order.status == SubscriptionStatus.active;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ObsidianCard(
                        borderColor: isActive ? AppColors.zomatoRed.withOpacity(0.5) : AppColors.charcoalBorder,
                        borderWidth: isActive ? 1.4 : 1.0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        onTap: () => _showInvoiceSheet(order),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    order.passTitle,
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700, fontSize: 14.5),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.neonMint.withOpacity(0.15)
                                        : AppColors.surfaceHighlight,
                                    borderRadius: AppDimensions.radius8,
                                    border: Border.all(
                                      color: isActive ? AppColors.neonMint : AppColors.charcoalBorder,
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    isActive ? 'ACTIVE PASS' : 'COMPLETED',
                                    style: AppTypography.monoBadge.copyWith(
                                      color: isActive ? AppColors.neonMint : AppColors.textSubtle,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Drop Gate: ${order.clusterName}',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedSlate, fontSize: 11),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${order.amountPaid}',
                                  style: AppTypography.monoPrice.copyWith(
                                    color: AppColors.electricSaffron,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'View Receipt',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.zomatoRedLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: AppColors.zomatoRedLight),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredOrders.length,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = index);
      },
      borderRadius: AppDimensions.radiusCircle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.zomatoRed : AppColors.matteCharcoal,
          borderRadius: AppDimensions.radiusCircle,
          border: Border.all(
            color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textMutedSlate,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
