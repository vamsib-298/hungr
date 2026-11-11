import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/dark_shimmer.dart';
import '../../domain/cluster_model.dart';
import '../../data/cluster_repository.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';

/// Clean Morning White Gate Selection Screen
/// Allows students and residents anywhere across Khammam to select an existing cluster
/// or enter their own custom hostel/apartment gate.
class ClusterSelectionScreen extends ConsumerStatefulWidget {
  const ClusterSelectionScreen({super.key});

  @override
  ConsumerState<ClusterSelectionScreen> createState() => _ClusterSelectionScreenState();
}

class _ClusterSelectionScreenState extends ConsumerState<ClusterSelectionScreen> {
  DeliveryCluster? _selectedCluster;
  List<DeliveryCluster> _allClusters = [];
  String _searchQuery = '';
  String _selectedSector = 'All Khammam';
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClusters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClusters() async {
    final repo = ref.read(clusterRepositoryProvider);
    final clusters = await repo.fetchActiveClusters();
    if (mounted) {
      setState(() {
        _allClusters = clusters;
        _isLoading = false;
        final currentSelected = ref.read(customerDashboardProvider).selectedCluster;
        _selectedCluster = clusters.firstWhere(
          (c) => c.id == currentSelected.id,
          orElse: () => clusters.first,
        );
      });
    }
  }

  void _showAddCustomLocationDialog() {
    final buildingController = TextEditingController();
    final areaController = TextEditingController();
    final landmarkController = TextEditingController();

    // Snap-Point Bottom Sheet (eds2002 Coordinated Scroll Sheet)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.68,
          minChildSize: 0.42,
          maxChildSize: 0.94,
          snap: true,
          snapSizes: const [0.68, 0.94],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 24,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top Drag Pill Indicator
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_location_alt_rounded, color: AppColors.zomatoRed, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Any Khammam Location',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Hostel, PG, Apartment, or Colony Gate',
                                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: AppColors.charcoalBorder),

                  // Coordinated Scrollable Form Body
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.charcoalBorder),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, color: AppColors.goldenAmber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Hungr delivers across all 4 sectors of Khammam! We drop food at your watchman desk by 7:30 AM.',
                                  style: AppTypography.caption.copyWith(color: AppColors.textPrimary, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        TextField(
                          controller: buildingController,
                          decoration: InputDecoration(
                            labelText: 'Hostel / Apartment / Society Name *',
                            hintText: 'e.g. Sri Balaji PG, Kakatiya Residency',
                            fillColor: const Color(0xFFF9FAFB),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: areaController,
                          decoration: InputDecoration(
                            labelText: 'Area / Road in Khammam *',
                            hintText: 'e.g. Rotary Nagar, Wyra Road, Mamillagudem',
                            fillColor: const Color(0xFFF9FAFB),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: landmarkController,
                          decoration: InputDecoration(
                            labelText: 'Gate Drop Note (Watchman Desk / Table)',
                            hintText: 'e.g. Ground floor reception, Block B security',
                            fillColor: const Color(0xFFF9FAFB),
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.zomatoRed,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (buildingController.text.trim().isEmpty) return;
                              final messenger = ScaffoldMessenger.of(context);
                              Navigator.of(ctx).pop();
                              HapticFeedback.mediumImpact();

                              final repo = ref.read(clusterRepositoryProvider);
                              final newCluster = await repo.addCustomLocation(
                                buildingName: buildingController.text.trim(),
                                addressZone: areaController.text.trim().isEmpty ? 'Khammam Central' : areaController.text.trim(),
                                landmark: landmarkController.text.trim(),
                              );

                              setState(() {
                                _allClusters = [newCluster, ..._allClusters];
                                _selectedCluster = newCluster;
                              });

                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    backgroundColor: const Color(0xFF16A34A),
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('Added & Selected: ${newCluster.name}!'),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Set as My Morning Delivery Gate',
                                  style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter clusters by sector and search query
    final filteredClusters = _allClusters.where((cluster) {
      final matchesQuery = _searchQuery.isEmpty ||
          cluster.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cluster.addressZone.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cluster.landmark.toLowerCase().contains(_searchQuery.toLowerCase());

      if (!matchesQuery) return false;

      if (_selectedSector == 'All Khammam') return true;
      if (_selectedSector == 'North (Bypass)' && cluster.addressZone.contains('Bypass')) return true;
      if (_selectedSector == 'South (Wyra)' && (cluster.addressZone.contains('Wyra') || cluster.addressZone.contains('Mamillagudem') || cluster.addressZone.contains('NSP'))) return true;
      if (_selectedSector == 'East (Bus Stand)' && (cluster.addressZone.contains('Bus Stand') || cluster.addressZone.contains('Station') || cluster.addressZone.contains('RTC'))) return true;
      if (_selectedSector == 'West (Gandhi Chowk)' && (cluster.addressZone.contains('Gandhi') || cluster.addressZone.contains('Rotary') || cluster.addressZone.contains('Trunk') || cluster.addressZone.contains('Mamillaguda'))) return true;

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
            'Select Delivery Gate in Khammam',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16.5,
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
            TextButton.icon(
              onPressed: _showAddCustomLocationDialog,
              icon: const Icon(Icons.add, size: 16, color: AppColors.zomatoRed),
              label: Text(
                'Custom Gate',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.zomatoRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Search Bar & Khammam Sector Filters
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search hostel, apartment, PG in Khammam...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        fillColor: const Color(0xFFF9FAFB),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.charcoalBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.charcoalBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.zomatoRed, width: 1.5),
                        ),
                        hintStyle: AppTypography.bodySmall.copyWith(color: AppColors.textSubtle),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sector Filter Pills (4 Zones of Khammam)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All Khammam',
                          'North (Bypass)',
                          'South (Wyra)',
                          'East (Bus Stand)',
                          'West (Gandhi Chowk)',
                        ].map((sector) {
                          final isSelected = _selectedSector == sector;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedSector = sector);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.zomatoRed : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                                  ),
                                ),
                                child: Text(
                                  sector,
                                  style: AppTypography.caption.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Gate Drop Policy Reminder
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Deliveries dropped strictly at Ground Floor Security Desk by 7:30 AM.',
                        style: AppTypography.caption.copyWith(
                          color: const Color(0xFF1E40AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Cluster Gates List
              Expanded(
                child: _isLoading
                    ? ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, __) => const DarkShimmer(width: double.infinity, height: 75),
                      )
                    : filteredClusters.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_off_rounded, size: 40, color: AppColors.textSubtle),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No matching gates in $_selectedSector',
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'You can add any building or hostel gate in Khammam below!',
                                    style: AppTypography.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: _showAddCustomLocationDialog,
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Add My Gate'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.zomatoRed,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                            itemCount: filteredClusters.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final cluster = filteredClusters[index];
                              final isSelected = _selectedCluster?.id == cluster.id;

                              return InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  setState(() => _selectedCluster = cluster);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected ? AppColors.zomatoRed : AppColors.charcoalBorder,
                                      width: isSelected ? 1.6 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? const [
                                            BoxShadow(color: Color(0x1FDE2030), blurRadius: 10, offset: Offset(0, 3)),
                                          ]
                                        : const [
                                            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                        color: isSelected ? AppColors.zomatoRed : AppColors.textSubtle,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cluster.name,
                                              style: AppTypography.titleMedium.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: isSelected ? AppColors.zomatoRed : AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${cluster.addressZone} • ${cluster.landmark}',
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: cluster.isFull
                                                        ? const Color(0xFFFEE2E2)
                                                        : const Color(0xFFECFDF5),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '${cluster.currentSubscribers}/${cluster.maxCapacity} FILLED',
                                                    style: AppTypography.monoBadge.copyWith(
                                                      fontSize: 8.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: cluster.isFull
                                                          ? AppColors.urgentCrimson
                                                          : const Color(0xFF16A34A),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  '${cluster.remainingSlots} spots left for 7:30 AM',
                                                  style: AppTypography.caption.copyWith(
                                                    fontSize: 10,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),

              // 4. Sticky Bottom Confirm Bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.charcoalBorder)),
                  boxShadow: [
                    BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, -3)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedCluster == null
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            ref.read(selectedClusterProvider.notifier).state = _selectedCluster;
                            ref.read(customerDashboardProvider.notifier).updateCluster(_selectedCluster!);
                            context.go(RouteNames.storefront);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.zomatoRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedCluster == null
                          ? 'Select a Gate'
                          : 'Deliver to ${_selectedCluster!.name.split(' ').take(3).join(' ')} ➔',
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
