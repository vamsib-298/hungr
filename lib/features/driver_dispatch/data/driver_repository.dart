import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/manifest_stop_model.dart';

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  return DriverRepository();
});

class DriverRepository {
  List<ManifestStop>? _cachedStops;

  Future<List<ManifestStop>> fetchTodayManifest(String driverId) async {
    if (_cachedStops != null) return _cachedStops!;

    await Future.delayed(const Duration(milliseconds: 300));
    _cachedStops = [
      // Zone 1: North (Bypass Road)
      const ManifestStop(
        stopSequence: 1,
        clusterId: 'cluster_01',
        clusterName: 'Sri Sai PG Gate',
        dropPointAddress: 'Main Security Desk, Bypass Road',
        zoneName: 'Khammam North (Bypass Road)',
        totalUnits: 12,
        optionACount: 8,
        optionBCount: 4,
        boiledEggsCount: 6,
        filterCoffeeCount: 5,
        recipientUserIds: ['u_101', 'u_102', 'u_103', 'u_104'],
        customers: [
          CustomerDropDetail(
            userId: 'u_101',
            customerName: 'Sai Teja (Room 204)',
            phoneNumber: '+91 98480 11990',
            roomOrFloor: 'Room 204',
            itemSummary: 'Set Dosa (3 pcs) + Degree Filter Coffee',
          ),
          CustomerDropDetail(
            userId: 'u_102',
            customerName: 'Kiran Reddy (Room 302)',
            phoneNumber: '+91 98480 22881',
            roomOrFloor: 'Room 302',
            itemSummary: 'Ghee Idli Vada + 2 Boiled Eggs',
          ),
          CustomerDropDetail(
            userId: 'u_103',
            customerName: 'Venkatesh P (Room 105)',
            phoneNumber: '+91 98480 33772',
            roomOrFloor: 'Room 105',
            itemSummary: 'Poori Masala + Kesari Badam Milk',
          ),
          CustomerDropDetail(
            userId: 'u_104',
            customerName: 'Sanjay Kumar (Room 401)',
            phoneNumber: '+91 98480 44663',
            roomOrFloor: 'Room 401',
            itemSummary: 'Set Dosa (3 pcs)',
          ),
        ],
        isBroadcastSent: false,
        isCompleted: false,
        status: DropStatus.outForDelivery,
      ),
      // Zone 2: South (Wyra Road)
      const ManifestStop(
        stopSequence: 2,
        clusterId: 'cluster_02',
        clusterName: 'Green Valley Watchman Desk',
        dropPointAddress: 'Gate 2 Watchman Station, Wyra Road',
        zoneName: 'Khammam South (Wyra Road)',
        totalUnits: 9,
        optionACount: 5,
        optionBCount: 4,
        boiledEggsCount: 4,
        filterCoffeeCount: 3,
        recipientUserIds: ['u_201', 'u_202', 'u_203'],
        customers: [
          CustomerDropDetail(
            userId: 'u_201',
            customerName: 'Ananya Rao (Flat 3B)',
            phoneNumber: '+91 98480 55554',
            roomOrFloor: 'Flat 3B',
            itemSummary: 'MLA Pesarattu Upma + Filter Coffee',
          ),
          CustomerDropDetail(
            userId: 'u_202',
            customerName: 'Praneeth G (Flat 1A)',
            phoneNumber: '+91 98480 66445',
            roomOrFloor: 'Flat 1A',
            itemSummary: 'Ghee Idli Vada (4 pcs)',
          ),
          CustomerDropDetail(
            userId: 'u_203',
            customerName: 'Rajesh Sharma (Flat 5C)',
            phoneNumber: '+91 98480 77336',
            roomOrFloor: 'Flat 5C',
            itemSummary: 'Rayalaseema Set Dosa',
          ),
        ],
        isBroadcastSent: false,
        isCompleted: false,
        status: DropStatus.pending,
      ),
      // Zone 3: East (Bus Stand / Station)
      const ManifestStop(
        stopSequence: 3,
        clusterId: 'cluster_03',
        clusterName: 'Sri Krishna Residency Gate',
        dropPointAddress: 'Main Entrance Security, Near RTC New Bus Stand',
        zoneName: 'Khammam East (Bus Stand & Station)',
        totalUnits: 14,
        optionACount: 9,
        optionBCount: 5,
        boiledEggsCount: 8,
        filterCoffeeCount: 6,
        recipientUserIds: ['u_301', 'u_302', 'u_303'],
        customers: [
          CustomerDropDetail(
            userId: 'u_301',
            customerName: 'Dr. Rahul Varma (Block A)',
            phoneNumber: '+91 98480 88227',
            roomOrFloor: 'Block A 201',
            itemSummary: 'Ghee Thatte Idli + 2 Boiled Eggs',
          ),
          CustomerDropDetail(
            userId: 'u_302',
            customerName: 'Divya M (Block B)',
            phoneNumber: '+91 98480 99118',
            roomOrFloor: 'Block B 104',
            itemSummary: 'Rayalaseema Set Dosa',
          ),
        ],
        isBroadcastSent: false,
        isCompleted: false,
        status: DropStatus.pending,
      ),
      // Zone 4: West (Gandhi Chowk / Old Town)
      const ManifestStop(
        stopSequence: 4,
        clusterId: 'cluster_04',
        clusterName: 'Mayuri Centre Apartments Gate',
        dropPointAddress: 'Security Booth, Mayuri Centre, Gandhi Chowk Road',
        zoneName: 'Khammam West (Gandhi Chowk & Old Town)',
        totalUnits: 10,
        optionACount: 6,
        optionBCount: 4,
        boiledEggsCount: 5,
        filterCoffeeCount: 4,
        recipientUserIds: ['u_401', 'u_402'],
        customers: [
          CustomerDropDetail(
            userId: 'u_401',
            customerName: 'Manojbabu (Flat 202)',
            phoneNumber: '+91 98480 12340',
            roomOrFloor: 'Flat 202',
            itemSummary: 'Crisp Mysore Bonda + Filter Coffee',
          ),
        ],
        isBroadcastSent: false,
        isCompleted: false,
        status: DropStatus.pending,
      ),
    ];

    return _cachedStops!;
  }

  /// Sends concurrent batch push notification to cluster recipients
  Future<bool> broadcastBatchArrival(String clusterId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  /// Completes the drop with photo proof
  Future<ManifestStop> completeStopWithPhotoProof({
    required ManifestStop stop,
    required String photoUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return stop.copyWith(
      isCompleted: true,
      status: DropStatus.deliveredAtGate,
      proofPhotoUrl: photoUrl,
      completedAt: DateTime.now(),
    );
  }

  /// Mark stop as out for delivery
  Future<ManifestStop> markOutForDelivery(ManifestStop stop) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return stop.copyWith(status: DropStatus.outForDelivery);
  }

  /// Mark delivery as failed with specific reason
  Future<ManifestStop> markDeliveryFailed({
    required ManifestStop stop,
    required DeliveryFailureReason reason,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return stop.copyWith(
      status: DropStatus.deliveryFailed,
      failureReason: reason,
      isCompleted: false,
    );
  }

  /// Re-attempt a previously failed delivery
  Future<ManifestStop> reAttemptDelivery(ManifestStop stop) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return stop.copyWith(
      status: DropStatus.outForDelivery,
      failureReason: null,
      isCompleted: false,
    );
  }
}
