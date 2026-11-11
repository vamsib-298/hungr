/// Detailed recipient information for individual tiffin drops at a cluster
class CustomerDropDetail {
  final String userId;
  final String customerName;
  final String phoneNumber;
  final String roomOrFloor;
  final String itemSummary;
  final int units;
  final bool isDelivered;

  const CustomerDropDetail({
    required this.userId,
    required this.customerName,
    required this.phoneNumber,
    required this.roomOrFloor,
    required this.itemSummary,
    this.units = 1,
    this.isDelivered = false,
  });

  CustomerDropDetail copyWith({bool? isDelivered}) {
    return CustomerDropDetail(
      userId: userId,
      customerName: customerName,
      phoneNumber: phoneNumber,
      roomOrFloor: roomOrFloor,
      itemSummary: itemSummary,
      units: units,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }
}

/// Delivery status for batched cluster gate drops
enum DropStatus {
  pending,
  outForDelivery,
  deliveredAtGate,
  deliveryFailed,
}

extension DropStatusExtension on DropStatus {
  String get displayName {
    switch (this) {
      case DropStatus.pending:
        return 'Pending Dispatch';
      case DropStatus.outForDelivery:
        return 'Out For Delivery';
      case DropStatus.deliveredAtGate:
        return 'Delivered at Gate';
      case DropStatus.deliveryFailed:
        return 'Delivery Failed';
    }
  }
}

/// Reasons when a morning gate drop cannot be completed
enum DeliveryFailureReason {
  gateLocked,
  customerUnreachable,
  guardRefused,
  incorrectLocation,
}

extension FailureReasonExtension on DeliveryFailureReason {
  String get explanation {
    switch (this) {
      case DeliveryFailureReason.gateLocked:
        return 'Hostel gate locked / Security absent';
      case DeliveryFailureReason.customerUnreachable:
        return 'Customer phone unreachable / switched off';
      case DeliveryFailureReason.guardRefused:
        return 'Security guard / warden refused drop';
      case DeliveryFailureReason.incorrectLocation:
        return 'Wrong building / cluster address';
    }
  }
}

class ManifestStop {
  final int stopSequence;
  final String clusterId;
  final String clusterName;
  final String dropPointAddress;
  final String zoneName;
  final int totalUnits;
  final int optionACount; // Dosa
  final int optionBCount; // Idli/Vada
  final int boiledEggsCount;
  final int filterCoffeeCount;
  final List<String> recipientUserIds;
  final List<CustomerDropDetail> customers;
  final bool isBroadcastSent;
  final bool isCompleted;
  final DropStatus status;
  final DeliveryFailureReason? failureReason;
  final String? proofPhotoUrl;
  final DateTime? completedAt;

  const ManifestStop({
    required this.stopSequence,
    required this.clusterId,
    required this.clusterName,
    required this.dropPointAddress,
    this.zoneName = 'Khammam North (Bypass Road)',
    required this.totalUnits,
    required this.optionACount,
    required this.optionBCount,
    this.boiledEggsCount = 0,
    this.filterCoffeeCount = 0,
    required this.recipientUserIds,
    this.customers = const [],
    this.isBroadcastSent = false,
    this.isCompleted = false,
    this.status = DropStatus.pending,
    this.failureReason,
    this.proofPhotoUrl,
    this.completedAt,
  });

  ManifestStop copyWith({
    bool? isBroadcastSent,
    bool? isCompleted,
    DropStatus? status,
    DeliveryFailureReason? failureReason,
    String? proofPhotoUrl,
    DateTime? completedAt,
    List<CustomerDropDetail>? customers,
  }) {
    return ManifestStop(
      stopSequence: stopSequence,
      clusterId: clusterId,
      clusterName: clusterName,
      dropPointAddress: dropPointAddress,
      zoneName: zoneName,
      totalUnits: totalUnits,
      optionACount: optionACount,
      optionBCount: optionBCount,
      boiledEggsCount: boiledEggsCount,
      filterCoffeeCount: filterCoffeeCount,
      recipientUserIds: recipientUserIds,
      customers: customers ?? this.customers,
      isBroadcastSent: isBroadcastSent ?? this.isBroadcastSent,
      isCompleted: isCompleted ?? this.isCompleted,
      status: status ?? this.status,
      failureReason: failureReason ?? this.failureReason,
      proofPhotoUrl: proofPhotoUrl ?? this.proofPhotoUrl,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
