import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/dark_shimmer.dart';
import '../../domain/khammam_zone_model.dart';
import '../../domain/manifest_stop_model.dart';
import '../viewmodels/driver_manifest_viewmodel.dart';
import '../../../../core/utils/whatsapp_link_helper.dart';

class DriverManifestScreen extends ConsumerStatefulWidget {
  const DriverManifestScreen({super.key});

  @override
  ConsumerState<DriverManifestScreen> createState() => _DriverManifestScreenState();
}

class _DriverManifestScreenState extends ConsumerState<DriverManifestScreen> {
  KhammamZoneId _selectedZoneId = KhammamZoneId.north;

  void _onBroadcast(ManifestStop stop) async {
    HapticFeedback.mediumImpact();
    final success = await ref
        .read(driverManifestViewModelProvider.notifier)
        .sendBatchBroadcast(stop.clusterId);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.electricSaffron,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Batch Arrival Broadcast Sent! Alerted ${stop.totalUnits} students at ${stop.clusterName}.',
            style: AppTypography.labelLarge.copyWith(color: AppColors.textDark),
          ),
        ),
      );
    }
  }

  void _showProofUploadSheet(ManifestStop stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Gate Drop Proof',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: AppDimensions.radius12,
                  border: Border.all(color: AppColors.charcoalBorder),
                ),
                child: Text(
                  '⚡ 2-Minute Gate Drop Protocol: Place ${stop.totalUnits} food packets at the reception / watchman desk, photograph the cluster packages, and proceed immediately. Zero waiting for sleepy students.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              // Simulated Photo Capture Preview
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: AppDimensions.radius16,
                  border: Border.all(color: AppColors.zomatoRed, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_rounded, color: AppColors.zomatoRed, size: 44),
                    const SizedBox(height: 8),
                    Text(
                      'Photo of food packets at Watchman Desk',
                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Timestamp & Geo-Stamp: 07:42 AM IST (Khammam)',
                      style: AppTypography.monoBadge.copyWith(color: const Color(0xFF16A34A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Confirm Drop & Mark Delivered'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(context).pop();
                    HapticFeedback.heavyImpact();
                    await ref
                        .read(driverManifestViewModelProvider.notifier)
                        .completeStopWithProof(
                          clusterId: stop.clusterId,
                          proofPhotoUrl: 'https://hungr.storage/proofs/${stop.clusterId}.jpg',
                        );
                    if (mounted) {
                      messenger.showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF16A34A),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                          content: Row(
                            children: [
                              const Icon(Icons.mark_chat_unread_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Delivered at Gate! 🔔 Automated WhatsApp Alert dispatched to ${stop.customers.length} students with Bag Tokens.',
                                  style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFailureReasonDialog(ManifestStop stop) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.zomatoRed, size: 24),
              const SizedBox(width: 8),
              Text('Mark Delivery Failed', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select the verified reason why ${stop.clusterName} could not be delivered:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ...DeliveryFailureReason.values.map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.of(context).pop();
                      HapticFeedback.mediumImpact();
                      await ref
                          .read(driverManifestViewModelProvider.notifier)
                          .markDeliveryFailed(clusterId: stop.clusterId, reason: reason);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.zomatoRed,
                            behavior: SnackBarBehavior.floating,
                            content: Text('Delivery marked as failed: ${reason.explanation}'),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        reason.explanation,
                        style: AppTypography.labelLarge.copyWith(
                          color: const Color(0xFF991B1B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _callCustomer(CustomerDropDetail customer) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: customer.phoneNumber));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 8),
              Text('Contact Customer', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${customer.customerName}', style: AppTypography.labelLarge),
              const SizedBox(height: 4),
              Text('Room / Unit: ${customer.roomOrFloor}', style: AppTypography.bodySmall),
              const SizedBox(height: 4),
              Text('Dish: ${customer.itemSummary}', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customer.phoneNumber,
                      style: AppTypography.monoPrice.copyWith(fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const Icon(Icons.copy_rounded, size: 16, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Phone number copied to clipboard! You can dial directly.',
                style: AppTypography.caption.copyWith(color: const Color(0xFF16A34A), fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    final msg = WhatsAppLinkHelper.formatGateDropMessage(
                      customerName: customer.customerName,
                      bagToken: customer.bagToken ?? '#SS-04',
                      clusterName: 'Hostel Gate Security Desk',
                      ticketId: customer.ticketId ?? 'tkt_${customer.userId}',
                    );
                    WhatsAppLinkHelper.copyAlertToClipboard(msg);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Color(0xFF15803D),
                        behavior: SnackBarBehavior.floating,
                        content: Text('WhatsApp Gate Drop message copied! Paste directly into customer chat.'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mark_chat_unread_rounded, size: 16, color: Color(0xFF16A34A)),
                  label: const Text('Copy 1-Tap WhatsApp Alert', style: TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF86EFAC)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final manifestAsync = ref.watch(driverManifestViewModelProvider);
    final zones = KhammamZone.defaultZones;
    final currentZone = zones.firstWhere((z) => z.id == _selectedZoneId);

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
            'Khammam Dispatch Hub',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
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
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: AppDimensions.radius8,
                border: Border.all(color: const Color(0xFF16A34A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.two_wheeler, color: Color(0xFF16A34A), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '4 ZONES ACTIVE',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF16A34A),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: manifestAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.p16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: AppDimensions.p16),
            itemBuilder: (_, __) => const DarkShimmer(width: double.infinity, height: 160),
          ),
          error: (err, _) => Center(
            child: Text('Error loading route: $err', style: AppTypography.bodyMedium),
          ),
          data: (List<ManifestStop> stops) {
            // Filter stops matching the selected zone
            final zoneStops = stops.where((s) => s.zoneName.contains(currentZone.name.split(' ').first)).toList();
            final displayedStops = zoneStops.isEmpty ? stops : zoneStops;

            final totalMeals = displayedStops.fold<int>(0, (int sum, ManifestStop s) => sum + s.totalUnits);
            final completedCount = displayedStops.where((s) => s.status == DropStatus.deliveredAtGate).length;
            final failedCount = displayedStops.where((s) => s.status == DropStatus.deliveryFailed).length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Strict Gate Drop Policy Notice
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: AppDimensions.radius12,
                            border: Border.all(color: const Color(0xFFFCD34D)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.security_rounded, color: Color(0xFFB45309), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Gate Drop Policy: Deliver strictly to Security Desk / Main Entrance by 7:30 AM. Floor-by-floor delivery is strictly prohibited.',
                                  style: AppTypography.caption.copyWith(
                                    color: const Color(0xFF92400E),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 2. Khammam 4-Zone Partition Selector (Requirement 6)
                        Text(
                          'Khammam Route Consolidation (4 Zones)',
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hyper-batched morning deliveries to optimize fuel and guarantee sub-2-minute gate drops.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 10),

                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: zones.map((z) {
                              final isSelected = z.id == _selectedZoneId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    setState(() => _selectedZoneId = z.id);
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.zomatoRed : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                                      ),
                                      boxShadow: isSelected
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x33E23744),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          z.name.split(' (').first,
                                          style: AppTypography.labelLarge.copyWith(
                                            color: isSelected ? Colors.white : AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${z.totalOrders} Orders • ${z.fuelSavedLitres}L saved',
                                          style: AppTypography.caption.copyWith(
                                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                                            fontSize: 9.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // 3. Active Zone Overview & Assigned Driver Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDimensions.radius16,
                            border: Border.all(color: AppColors.charcoalBorder),
                            boxShadow: const [
                              BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2)),
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
                                      const CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Color(0xFFFEE2E2),
                                        child: Icon(Icons.person, color: AppColors.zomatoRed, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Assigned: ${currentZone.assignedDriver.name}',
                                            style: AppTypography.labelLarge.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          Text(
                                            currentZone.assignedDriver.vehicleInfo,
                                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(ClipboardData(text: currentZone.assignedDriver.phone));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Driver phone copied: ${currentZone.assignedDriver.phone}'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone, size: 12, color: AppColors.textPrimary),
                                          const SizedBox(width: 4),
                                          Text(
                                            'CALL DRIVER',
                                            style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.textPrimary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1, color: Color(0xFFF3F4F6)),
                              const SizedBox(height: 10),
                              // Route density & Fuel metrics
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('TOTAL UNITS', '$totalMeals Meals'),
                                  _buildStatItem('DELIVERED', '$completedCount / ${displayedStops.length}'),
                                  _buildStatItem('FAILURES', '$failedCount', isWarning: failedCount > 0),
                                  _buildStatItem('FUEL SAVED', '${currentZone.fuelSavedLitres} L', isSuccess: true),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text('Cluster Gate Stops for ${currentZone.name.split(' (').first}', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                // 4. Sequential Stops List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final stop = displayedStops[index];
                        final bool isDelivered = stop.status == DropStatus.deliveredAtGate;
                        final bool isFailed = stop.status == DropStatus.deliveryFailed;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppDimensions.radius16,
                            border: Border.all(
                              color: isDelivered
                                  ? const Color(0xFF86EFAC)
                                  : (isFailed ? const Color(0xFFFCA5A5) : AppColors.charcoalBorder),
                              width: 1.2,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Stop number + Cluster Name + Status Pill
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'STOP ${stop.stopSequence}',
                                            style: AppTypography.monoBadge.copyWith(
                                              color: AppColors.textPrimary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 160),
                                          child: Text(
                                            stop.clusterName,
                                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDelivered
                                            ? const Color(0xFFDCFCE7)
                                            : (isFailed ? const Color(0xFFFEE2E2) : const Color(0xFFF3F4F6)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isDelivered
                                            ? 'DELIVERED AT GATE'
                                            : (isFailed ? 'DELIVERY FAILED' : '${stop.totalUnits} UNITS'),
                                        style: AppTypography.monoBadge.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isDelivered
                                              ? const Color(0xFF16A34A)
                                              : (isFailed ? const Color(0xFFDC2626) : AppColors.textPrimary),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.place_outlined, size: 14, color: AppColors.textSubtle),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        stop.dropPointAddress,
                                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Failure explanation if failed
                                if (isFailed && stop.failureReason != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFFCA5A5)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.error_outline, size: 14, color: Color(0xFFDC2626)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Reason: ${stop.failureReason!.explanation}',
                                            style: AppTypography.caption.copyWith(
                                              color: const Color(0xFF991B1B),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],

                                // Package Units Breakdown Chips
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE5E7EB)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildSmallUnitChip('Dosa', stop.optionACount),
                                      _buildSmallUnitChip('Idli/Vada', stop.optionBCount),
                                      _buildSmallUnitChip('Eggs', stop.boiledEggsCount),
                                      _buildSmallUnitChip('Coffee', stop.filterCoffeeCount),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Recipient Customer List with 1-tap Call (Requirement 6)
                                if (stop.customers.isNotEmpty) ...[
                                  Text(
                                    'Recipients (${stop.customers.length}):',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  ...stop.customers.map((c) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_pin_circle_outlined, size: 16, color: AppColors.zomatoRed),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  c.customerName,
                                                  style: AppTypography.labelSmall.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                Text(
                                                  c.itemSummary,
                                                  style: AppTypography.caption.copyWith(
                                                    color: AppColors.textSecondary,
                                                    fontSize: 9.5,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 1-Tap Call Customer Button (Requirement 6)
                                          ElevatedButton.icon(
                                            onPressed: () => _callCustomer(c),
                                            icon: const Icon(Icons.phone, size: 12),
                                            label: const Text('Call'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF16A34A),
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              textStyle: AppTypography.monoBadge.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 10),
                                ],

                                // Driver Action Buttons (Requirement 5)
                                if (!isDelivered && !isFailed) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          icon: Icon(
                                            stop.isBroadcastSent ? Icons.check : Icons.notification_add_outlined,
                                            size: 14,
                                            color: stop.isBroadcastSent ? const Color(0xFF16A34A) : AppColors.textPrimary,
                                          ),
                                          label: Text(
                                            stop.isBroadcastSent ? 'Notified' : 'Arrived at Gate',
                                            style: AppTypography.labelSmall.copyWith(
                                              fontSize: 11,
                                              color: stop.isBroadcastSent ? const Color(0xFF16A34A) : AppColors.textPrimary,
                                            ),
                                          ),
                                          onPressed: stop.isBroadcastSent ? null : () => _onBroadcast(stop),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.camera_alt_outlined, size: 14),
                                          label: const Text('Drop & Proof'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF16A34A),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => _showProofUploadSheet(stop),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.report_problem_outlined, color: AppColors.zomatoRed, size: 20),
                                        tooltip: 'Mark Delivery Failed',
                                        onPressed: () => _showFailureReasonDialog(stop),
                                      ),
                                    ],
                                  ),
                                ] else if (isFailed) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.zomatoRed),
                                      label: Text('Re-attempt Gate Drop', style: AppTypography.labelLarge.copyWith(color: AppColors.zomatoRed)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: AppColors.zomatoRed),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () async {
                                        HapticFeedback.mediumImpact();
                                        await ref
                                            .read(driverManifestViewModelProvider.notifier)
                                            .reAttemptDelivery(stop.clusterId);
                                      },
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0FDF4),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Gate drop confirmed with photo proof.',
                                          style: AppTypography.caption.copyWith(
                                            color: const Color(0xFF16A34A),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: displayedStops.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isWarning = false, bool isSuccess = false}) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.monoPrice.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isWarning
                ? AppColors.zomatoRed
                : (isSuccess ? const Color(0xFF16A34A) : AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 8.5, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSmallUnitChip(String label, int count) {
    return Column(
      children: [
        Text(count.toString(), style: AppTypography.monoPrice.copyWith(fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: AppTypography.caption.copyWith(fontSize: 8.5, color: AppColors.textSecondary)),
      ],
    );
  }
}
