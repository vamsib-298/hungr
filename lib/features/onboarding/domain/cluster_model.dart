class DeliveryCluster {
  final String id;
  final String name;
  final String addressZone;
  final String landmark;
  final int currentSubscribers;
  final int maxCapacity;
  final double latitude;
  final double longitude;

  const DeliveryCluster({
    required this.id,
    required this.name,
    required this.addressZone,
    required this.landmark,
    required this.currentSubscribers,
    this.maxCapacity = 50,
    required this.latitude,
    required this.longitude,
  });

  bool get isFull => currentSubscribers >= maxCapacity;
  int get remainingSlots => maxCapacity - currentSubscribers;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'addressZone': addressZone,
      'landmark': landmark,
      'currentSubscribers': currentSubscribers,
      'maxCapacity': maxCapacity,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryCluster.fromMap(Map<String, dynamic> map) {
    return DeliveryCluster(
      id: map['id'] as String,
      name: map['name'] as String,
      addressZone: map['addressZone'] as String,
      landmark: map['landmark'] as String,
      currentSubscribers: (map['currentSubscribers'] as num?)?.toInt() ?? 0,
      maxCapacity: (map['maxCapacity'] as num?)?.toInt() ?? 50,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
