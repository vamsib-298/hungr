/// Delivery zones for Khammam city to consolidate routes, assign 4 dedicated
/// delivery partners, and maximize fuel efficiency with morning batched drops.
enum KhammamZoneId {
  north,
  south,
  east,
  west,
}

class DriverAssignment {
  final String driverId;
  final String name;
  final String phone;
  final String vehicleInfo;
  final String avatarUrl;

  const DriverAssignment({
    required this.driverId,
    required this.name,
    required this.phone,
    required this.vehicleInfo,
    this.avatarUrl = '',
  });
}

class KhammamZone {
  final KhammamZoneId id;
  final String name;
  final String landmarkOverview;
  final List<String> coveredClusters;
  final DriverAssignment assignedDriver;
  final int totalOrders;
  final int totalClusters;
  final double fuelSavedLitres;
  final int estimatedMinutes;
  final String routeSequence;

  const KhammamZone({
    required this.id,
    required this.name,
    required this.landmarkOverview,
    required this.coveredClusters,
    required this.assignedDriver,
    required this.totalOrders,
    required this.totalClusters,
    required this.fuelSavedLitres,
    required this.estimatedMinutes,
    required this.routeSequence,
  });

  /// Standard 4-zone Khammam Partition
  static List<KhammamZone> get defaultZones => const [
    KhammamZone(
      id: KhammamZoneId.north,
      name: 'Khammam North (Bypass Road)',
      landmarkOverview: 'Bypass Road, New Collectorate & Mamatha Circle',
      coveredClusters: [
        'Sri Sai PG Main Gate',
        'Kakatiya Girls Hostel Watchman Desk',
        'Collectorate Quarters Reception',
        'Mamatha Medical Bypass Residency',
      ],
      assignedDriver: DriverAssignment(
        driverId: 'drv_north_01',
        name: 'Ramesh Goud',
        phone: '+91 98480 11223',
        vehicleInfo: 'Honda Activa 6G (TS 04 EA 1234)',
      ),
      totalOrders: 42,
      totalClusters: 4,
      fuelSavedLitres: 2.8,
      estimatedMinutes: 38,
      routeSequence: 'Bypass Hub ➔ Sri Sai PG ➔ Kakatiya Girls ➔ Collectorate Quarters',
    ),
    KhammamZone(
      id: KhammamZoneId.south,
      name: 'Khammam South (Wyra Road)',
      landmarkOverview: 'Wyra Road, Mamillagudem & NSP Colony',
      coveredClusters: [
        'Green Valley Watchman Desk',
        'Sri Chaitanya Junior Boys Gate',
        'Vijaya Towers Reception',
        'NSP Camp Block 3 Gate',
      ],
      assignedDriver: DriverAssignment(
        driverId: 'drv_south_02',
        name: 'Suresh Kumar',
        phone: '+91 98480 22334',
        vehicleInfo: 'Hero Splendor+ (TS 04 EB 5678)',
      ),
      totalOrders: 38,
      totalClusters: 4,
      fuelSavedLitres: 2.3,
      estimatedMinutes: 34,
      routeSequence: 'Wyra Road Hub ➔ Green Valley ➔ Sri Chaitanya ➔ Vijaya Towers',
    ),
    KhammamZone(
      id: KhammamZoneId.east,
      name: 'Khammam East (Bus Stand & Station)',
      landmarkOverview: 'RTC New Bus Stand, Railway Station & Mamata Hospital',
      coveredClusters: [
        'Sri Krishna Residency Gate',
        'Mamata Doctors Quarters Block A',
        'RTC Complex Staff Quarters',
        'Station Road PG Hub',
      ],
      assignedDriver: DriverAssignment(
        driverId: 'drv_east_03',
        name: 'Naresh Babu',
        phone: '+91 98480 33445',
        vehicleInfo: 'TVS Jupiter 125 (TS 04 EC 9012)',
      ),
      totalOrders: 51,
      totalClusters: 4,
      fuelSavedLitres: 3.4,
      estimatedMinutes: 42,
      routeSequence: 'East Hub ➔ Bus Stand Gate ➔ Mamata Quarters ➔ Krishna Residency',
    ),
    KhammamZone(
      id: KhammamZoneId.west,
      name: 'Khammam West (Gandhi Chowk & Old Town)',
      landmarkOverview: 'Gandhi Chowk, Mayuri Centre & Rotary Nagar',
      coveredClusters: [
        'Gayatri Towers Reception Gate',
        'Mayuri Centre Apartments Main Entrance',
        'Rotary Nagar Security Cabin',
        'Gandhi Chowk Old Town Residence',
      ],
      assignedDriver: DriverAssignment(
        driverId: 'drv_west_04',
        name: 'Mahesh Yadav',
        phone: '+91 98480 44556',
        vehicleInfo: 'Bajaj Pulsar 125 (TS 04 ED 3456)',
      ),
      totalOrders: 29,
      totalClusters: 4,
      fuelSavedLitres: 1.9,
      estimatedMinutes: 28,
      routeSequence: 'West Hub ➔ Gayatri Towers ➔ Mayuri Centre ➔ Rotary Nagar',
    ),
  ];
}
