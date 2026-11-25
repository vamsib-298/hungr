import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/cluster_model.dart';

final clusterRepositoryProvider = Provider<ClusterRepository>((ref) {
  return ClusterRepository();
});

final selectedClusterProvider = StateProvider<DeliveryCluster?>((ref) => null);

class ClusterRepository {
  static List<DeliveryCluster> _clusters = [
    // Zone 1: Khammam North (Bypass Road & Collectorate)
    const DeliveryCluster(
      id: 'cluster_01',
      name: 'Sri Sai Boys Hostel Main Gate',
      addressZone: 'Bypass Road, Khammam',
      landmark: 'Near New Collectorate Arch',
      currentSubscribers: 38,
      maxCapacity: 50,
      latitude: 17.2473,
      longitude: 80.1514,
    ),
    const DeliveryCluster(
      id: 'cluster_north_02',
      name: 'Kakatiya Girls PG Watchman Desk',
      addressZone: 'Bypass Road, Khammam',
      landmark: 'Beside Kakatiya Junior College',
      currentSubscribers: 29,
      maxCapacity: 50,
      latitude: 17.2490,
      longitude: 80.1530,
    ),
    const DeliveryCluster(
      id: 'cluster_north_03',
      name: 'Collectorate Officers Quarters Gate',
      addressZone: 'Collectorate Circle, Bypass Road',
      landmark: 'Gate 1 Security Cabin',
      currentSubscribers: 18,
      maxCapacity: 50,
      latitude: 17.2520,
      longitude: 80.1560,
    ),
    const DeliveryCluster(
      id: 'cluster_north_04',
      name: 'Mamatha Medical Campus Hostels',
      addressZone: 'Mamatha Bypass Road',
      landmark: 'Main Student Entry Security Gate',
      currentSubscribers: 44,
      maxCapacity: 60,
      latitude: 17.2550,
      longitude: 80.1590,
    ),

    // Zone 2: Khammam South (Wyra Road & Mamillagudem)
    const DeliveryCluster(
      id: 'cluster_02',
      name: 'Green Valley Apartments Watchman Desk',
      addressZone: 'Wyra Road, Khammam',
      landmark: 'Opposite Collectorate Lane, Gate 2',
      currentSubscribers: 24,
      maxCapacity: 50,
      latitude: 17.2510,
      longitude: 80.1580,
    ),
    const DeliveryCluster(
      id: 'cluster_south_02',
      name: 'Sri Chaitanya Boys Gate',
      addressZone: 'Mamillagudem Main Road',
      landmark: 'Near Hanuman Temple Arch',
      currentSubscribers: 36,
      maxCapacity: 50,
      latitude: 17.2480,
      longitude: 80.1540,
    ),
    const DeliveryCluster(
      id: 'cluster_south_03',
      name: 'Vijaya Towers Reception Gate',
      addressZone: 'Wyra Road, Khammam',
      landmark: 'Near Mamillagudem Flyover',
      currentSubscribers: 31,
      maxCapacity: 50,
      latitude: 17.2460,
      longitude: 80.1520,
    ),
    const DeliveryCluster(
      id: 'cluster_south_04',
      name: 'NSP Camp Block 3 Security Desk',
      addressZone: 'NSP Colony, Khammam',
      landmark: 'Beside Irrigation Office',
      currentSubscribers: 19,
      maxCapacity: 40,
      latitude: 17.2430,
      longitude: 80.1490,
    ),

    // Zone 3: Khammam East (Bus Stand & Station Road)
    const DeliveryCluster(
      id: 'cluster_east_01',
      name: 'Sri Krishna Residency Main Gate',
      addressZone: 'Near RTC New Bus Stand',
      landmark: 'Opposite RTC Complex Parking Gate',
      currentSubscribers: 41,
      maxCapacity: 50,
      latitude: 17.2465,
      longitude: 80.1450,
    ),
    const DeliveryCluster(
      id: 'cluster_east_02',
      name: 'Mamata Doctors Quarters Block A',
      addressZone: 'Station Road Area',
      landmark: 'Opposite Railway Quarters Gate',
      currentSubscribers: 28,
      maxCapacity: 40,
      latitude: 17.2495,
      longitude: 80.1480,
    ),
    const DeliveryCluster(
      id: 'cluster_east_03',
      name: 'RTC Colony Staff Quarters Watchman Desk',
      addressZone: 'RTC Colony, Khammam',
      landmark: 'Near Mother Dairy Booth',
      currentSubscribers: 22,
      maxCapacity: 40,
      latitude: 17.2450,
      longitude: 80.1460,
    ),

    // Zone 4: Khammam West (Gandhi Chowk & Old Town)
    const DeliveryCluster(
      id: 'cluster_03',
      name: 'Gayatri Towers Reception Gate',
      addressZone: 'Mamillaguda Area',
      landmark: 'Behind SBI Main Branch',
      currentSubscribers: 42,
      maxCapacity: 50,
      latitude: 17.2440,
      longitude: 80.1420,
    ),
    const DeliveryCluster(
      id: 'cluster_west_02',
      name: 'Mayuri Centre Apartments Main Entrance',
      addressZone: 'Gandhi Chowk Road',
      landmark: 'Beside Mayuri Cinema Theatre',
      currentSubscribers: 33,
      maxCapacity: 50,
      latitude: 17.2410,
      longitude: 80.1380,
    ),
    const DeliveryCluster(
      id: 'cluster_west_03',
      name: 'Rotary Nagar Security Cabin',
      addressZone: 'Rotary Nagar, Khammam',
      landmark: 'Near Community Hall Gate',
      currentSubscribers: 25,
      maxCapacity: 40,
      latitude: 17.2380,
      longitude: 80.1350,
    ),
    const DeliveryCluster(
      id: 'cluster_05',
      name: 'Balaji Residency Watchman Desk',
      addressZone: 'Trunk Road Area',
      landmark: 'Near Municipal Park',
      currentSubscribers: 27,
      maxCapacity: 50,
      latitude: 17.2390,
      longitude: 80.1490,
    ),
  ];

  Future<List<DeliveryCluster>> fetchActiveClusters() async {
    try {
      final snapshot = await FirebaseService.instance.firestore.collection('clusters').get();
      if (snapshot.docs.isNotEmpty) {
        final remote = snapshot.docs.map((doc) {
          final d = doc.data();
          return DeliveryCluster(
            id: doc.id,
            name: (d['name'] as String?) ?? 'Khammam Gate',
            addressZone: (d['addressZone'] as String?) ?? 'Khammam',
            landmark: (d['landmark'] as String?) ?? 'Main Gate',
            currentSubscribers: (d['currentSubscribers'] as num?)?.toInt() ?? 10,
            maxCapacity: (d['maxCapacity'] as num?)?.toInt() ?? 50,
            latitude: (d['latitude'] as num?)?.toDouble() ?? 17.2473,
            longitude: (d['longitude'] as num?)?.toDouble() ?? 80.1514,
          );
        }).toList();
        return [...remote, ..._clusters.where((c) => !remote.any((r) => r.id == c.id))];
      }
    } catch (_) {}
    return _clusters;
  }

  /// Allows a user to book from any location in Khammam by registering their building/hostel gate
  Future<DeliveryCluster> addCustomLocation({
    required String buildingName,
    required String addressZone,
    required String landmark,
  }) async {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final resolvedZone = addressZone.contains('Khammam') ? addressZone : '$addressZone, Khammam';
    final resolvedLandmark = landmark.isEmpty ? 'Main Entrance Security Desk' : landmark;

    final newCluster = DeliveryCluster(
      id: id,
      name: '$buildingName Gate',
      addressZone: resolvedZone,
      landmark: resolvedLandmark,
      currentSubscribers: 1,
      maxCapacity: 30,
      latitude: 17.2470,
      longitude: 80.1510,
    );
    _clusters = [newCluster, ..._clusters];

    try {
      await FirebaseService.instance.firestore.collection('clusters').doc(id).set({
        'id': id,
        'name': newCluster.name,
        'addressZone': resolvedZone,
        'landmark': resolvedLandmark,
        'currentSubscribers': 1,
        'maxCapacity': 30,
        'latitude': 17.2470,
        'longitude': 80.1510,
      });
    } catch (_) {}

    return newCluster;
  }
}
