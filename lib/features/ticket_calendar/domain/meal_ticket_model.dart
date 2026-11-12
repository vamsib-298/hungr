enum TicketStatusType {
  scheduled,
  locked,
  skipped,
  delivered,
}

enum MealSlotType {
  morning,
  evening,
}

class MealTicket {
  final String ticketId;
  final String passId;
  final String userId;
  final String clusterId;
  final String clusterName;
  final DateTime deliveryDate;
  final String comboSelection; // 'A' or 'B'
  final List<String> addOns; // ['addon_boiled_eggs', 'addon_filter_coffee']
  final MealSlotType slot;
  final String? assignedVendorId; // 'aunty_1' or 'aunty_2'
  final String? assignedDriverId;
  final TicketStatusType status;
  final String? dropProofImageUrl;
  final DateTime? deliveredAt;
  final String bagToken; // e.g. '#SS-04'
  final String? specialtyName; // e.g. 'Rayalaseema Set Dosa'
  final int companionMeals; // Roommate companion meals

  const MealTicket({
    required this.ticketId,
    required this.passId,
    required this.userId,
    required this.clusterId,
    required this.clusterName,
    required this.deliveryDate,
    required this.comboSelection,
    this.addOns = const [],
    this.slot = MealSlotType.morning,
    this.assignedVendorId,
    this.assignedDriverId,
    this.status = TicketStatusType.scheduled,
    this.dropProofImageUrl,
    this.deliveredAt,
    this.bagToken = '#TS-04',
    this.specialtyName,
    this.companionMeals = 0,
  });

  MealTicket copyWith({
    TicketStatusType? status,
    String? comboSelection,
    List<String>? addOns,
    String? assignedVendorId,
    String? assignedDriverId,
    String? dropProofImageUrl,
    DateTime? deliveredAt,
    String? bagToken,
    String? specialtyName,
    int? companionMeals,
  }) {
    return MealTicket(
      ticketId: ticketId,
      passId: passId,
      userId: userId,
      clusterId: clusterId,
      clusterName: clusterName,
      deliveryDate: deliveryDate,
      comboSelection: comboSelection ?? this.comboSelection,
      addOns: addOns ?? this.addOns,
      slot: slot,
      assignedVendorId: assignedVendorId ?? this.assignedVendorId,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      status: status ?? this.status,
      dropProofImageUrl: dropProofImageUrl ?? this.dropProofImageUrl,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      bagToken: bagToken ?? this.bagToken,
      specialtyName: specialtyName ?? this.specialtyName,
      companionMeals: companionMeals ?? this.companionMeals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'passId': passId,
      'userId': userId,
      'clusterId': clusterId,
      'clusterName': clusterName,
      'deliveryDate': deliveryDate.toIso8601String(),
      'comboSelection': comboSelection,
      'addOns': addOns,
      'slot': slot.name.toUpperCase(),
      'assignedVendorId': assignedVendorId,
      'assignedDriverId': assignedDriverId,
      'status': status.name.toUpperCase(),
      'dropProofImageUrl': dropProofImageUrl,
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  factory MealTicket.fromMap(Map<String, dynamic> map) {
    return MealTicket(
      ticketId: map['ticketId'] as String,
      passId: map['passId'] as String,
      userId: map['userId'] as String,
      clusterId: map['clusterId'] as String,
      clusterName: (map['clusterName'] as String?) ?? 'Cluster Drop Point',
      deliveryDate: DateTime.parse(map['deliveryDate'] as String),
      comboSelection: map['comboSelection'] as String,
      addOns: List<String>.from((map['addOns'] as List<dynamic>?) ?? []),
      slot: (map['slot'] as String?) == 'EVENING' ? MealSlotType.evening : MealSlotType.morning,
      assignedVendorId: map['assignedVendorId'] as String?,
      assignedDriverId: map['assignedDriverId'] as String?,
      status: _parseStatus(map['status'] as String?),
      dropProofImageUrl: map['dropProofImageUrl'] as String?,
      deliveredAt: map['deliveredAt'] != null ? DateTime.parse(map['deliveredAt'] as String) : null,
    );
  }

  static TicketStatusType _parseStatus(String? statusStr) {
    switch (statusStr?.toUpperCase()) {
      case 'LOCKED':
        return TicketStatusType.locked;
      case 'SKIPPED':
        return TicketStatusType.skipped;
      case 'DELIVERED':
        return TicketStatusType.delivered;
      default:
        return TicketStatusType.scheduled;
    }
  }
}
