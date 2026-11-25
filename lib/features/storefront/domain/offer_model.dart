/// Domain model for promotional coupons & banners configured in Admin Web Command
class OfferModel {
  final String id;
  final String code;
  final String description;
  final String type; // 'flat', 'percentage', 'freeDrop'
  final int value;
  final int minOrder;
  final bool isActive;

  const OfferModel({
    required this.id,
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    required this.minOrder,
    this.isActive = true,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return OfferModel(
      id: docId ?? (map['id'] as String?) ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      code: ((map['code'] as String?) ?? '').trim().toUpperCase(),
      description: (map['description'] as String?) ?? 'Special morning breakfast offer',
      type: (map['type'] as String?) ?? 'flat',
      value: (map['value'] as num?)?.toInt() ?? 0,
      minOrder: (map['minOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Calculates rupee discount for a given order subtotal
  int computeDiscount(int orderTotal) {
    if (!isActive || orderTotal < minOrder) return 0;
    if (type == 'percentage') {
      final raw = ((orderTotal * value) / 100).round();
      return raw > orderTotal ? orderTotal : raw;
    }
    if (type == 'flat') {
      return value > orderTotal ? orderTotal : value;
    }
    return value;
  }

  String get badgeText {
    if (type == 'percentage') return '$value% OFF';
    if (type == 'freeDrop') return 'FREE DROP';
    return '₹$value OFF';
  }

  static const List<OfferModel> defaultOffers = [
    OfferModel(
      id: 'default_first50',
      code: 'FIRST50',
      description: 'Flat ₹50 OFF on your first morning breakfast order',
      type: 'flat',
      value: 50,
      minOrder: 99,
      isActive: true,
    ),
    OfferModel(
      id: 'default_hungrfree',
      code: 'HUNGRFREE',
      description: 'Save ₹25 on daily breakfast & morning passes',
      type: 'flat',
      value: 25,
      minOrder: 49,
      isActive: true,
    ),
  ];
}
