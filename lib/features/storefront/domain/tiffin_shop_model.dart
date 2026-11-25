import 'tiffin_item_model.dart';

/// Operational status of a partner tiffin shop
enum ShopStatus {
  open,
  closedToday,
  closedTemporary,
  permanentlyClosed,
}

extension ShopStatusExtension on ShopStatus {
  String get displayName {
    switch (this) {
      case ShopStatus.open:
        return 'Open for Drops';
      case ShopStatus.closedToday:
        return 'Closed Today';
      case ShopStatus.closedTemporary:
        return 'Closed Temporarily';
      case ShopStatus.permanentlyClosed:
        return 'Permanently Closed';
    }
  }

  bool get canAcceptOrders => this == ShopStatus.open;
}

/// Domain model representing a partner Tiffin Kitchen/Shop in Khammam
class TiffinShop {
  final String id;
  final String name;
  final String tagline;
  final String zone; // e.g., 'Khammam North', 'Khammam South', etc.
  final String address;
  final double rating;
  final int totalReviews;
  final String deliveryWindow;
  final bool isPureVeg;
  final List<String> carouselImages;
  final List<String> specialties;
  final ShopStatus status;
  final String? closureReason;
  final String? reopenDate;
  final List<TiffinItem> menuItems;
  final bool isPromoted;
  final String? discountLabel;

  const TiffinShop({
    required this.id,
    required this.name,
    required this.tagline,
    required this.zone,
    required this.address,
    required this.rating,
    required this.totalReviews,
    this.deliveryWindow = 'Gate drop by 7:30 AM',
    this.isPureVeg = true,
    required this.carouselImages,
    required this.specialties,
    this.status = ShopStatus.open,
    this.closureReason,
    this.reopenDate,
    required this.menuItems,
    this.isPromoted = false,
    this.discountLabel,
  });

  bool get isOpen => status == ShopStatus.open;

  TiffinShop copyWith({
    String? id,
    String? name,
    String? tagline,
    String? zone,
    String? address,
    double? rating,
    int? totalReviews,
    String? deliveryWindow,
    bool? isPureVeg,
    List<String>? carouselImages,
    List<String>? specialties,
    ShopStatus? status,
    String? closureReason,
    String? reopenDate,
    List<TiffinItem>? menuItems,
    bool? isPromoted,
    String? discountLabel,
  }) {
    return TiffinShop(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      zone: zone ?? this.zone,
      address: address ?? this.address,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      deliveryWindow: deliveryWindow ?? this.deliveryWindow,
      isPureVeg: isPureVeg ?? this.isPureVeg,
      carouselImages: carouselImages ?? this.carouselImages,
      specialties: specialties ?? this.specialties,
      status: status ?? this.status,
      closureReason: closureReason ?? this.closureReason,
      reopenDate: reopenDate ?? this.reopenDate,
      menuItems: menuItems ?? this.menuItems,
      isPromoted: isPromoted ?? this.isPromoted,
      discountLabel: discountLabel ?? this.discountLabel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'zone': zone,
      'address': address,
      'rating': rating,
      'totalReviews': totalReviews,
      'deliveryWindow': deliveryWindow,
      'isPureVeg': isPureVeg,
      'carouselImages': carouselImages,
      'specialties': specialties,
      'status': status.name,
      'closureReason': closureReason,
      'reopenDate': reopenDate,
      'menuItems': menuItems.map((e) => e.toMap()).toList(),
      'isPromoted': isPromoted,
      'discountLabel': discountLabel,
    };
  }

  factory TiffinShop.fromMap(Map<String, dynamic> map, {String? docId}) {
    ShopStatus parseStatus(String? val) {
      switch (val) {
        case 'closedToday':
          return ShopStatus.closedToday;
        case 'closedTemporary':
          return ShopStatus.closedTemporary;
        case 'permanentlyClosed':
          return ShopStatus.permanentlyClosed;
        default:
          return ShopStatus.open;
      }
    }

    final resolvedId = docId ?? map['id'] as String? ?? 'shop_${DateTime.now().millisecondsSinceEpoch}';
    final resolvedName = map['name'] as String? ?? 'Khammam Tiffin Hub';

    List<TiffinItem> items = [];
    if (map['menuItems'] is List) {
      items = (map['menuItems'] as List)
          .map((e) => TiffinItem.fromMap(
                Map<String, dynamic>.from(e as Map),
                shopId: resolvedId,
                shopName: resolvedName,
              ))
          .toList();
    } else if (map['dishes'] is List) {
      items = (map['dishes'] as List)
          .map((e) => TiffinItem.fromMap(
                Map<String, dynamic>.from(e as Map),
                shopId: resolvedId,
                shopName: resolvedName,
              ))
          .toList();
    }

    return TiffinShop(
      id: resolvedId,
      name: resolvedName,
      tagline: map['tagline'] as String? ?? 'Hot fresh morning breakfast delivered to gate',
      zone: map['zone'] as String? ?? 'Khammam Central',
      address: map['address'] as String? ?? 'Khammam, Telangana',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? (map['reviews'] as num?)?.toInt() ?? 120,
      deliveryWindow: map['deliveryWindow'] as String? ?? 'Drop at gate by 7:30 AM',
      isPureVeg: map['isPureVeg'] as bool? ?? true,
      carouselImages: (map['carouselImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: (map['specialties'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['Ghee Thatte Idli', 'Rayalaseema Karam Dosa'],
      status: parseStatus(map['status'] as String?),
      closureReason: map['closureReason'] as String?,
      reopenDate: map['reopenDate'] as String?,
      menuItems: items.isNotEmpty
          ? items
          : TiffinItem.standardMenuItems
              .take(4)
              .map((e) => e.copyWith(shopId: resolvedId, shopName: resolvedName))
              .toList(),
      isPromoted: map['isPromoted'] as bool? ?? false,
      discountLabel: map['discountLabel'] as String?,
    );
  }

  /// Default Khammam partner kitchens (fallback before Firestore connects)
  static List<TiffinShop> get standardShops => [
    TiffinShop(
      id: 'shop_venkateshwara',
      name: 'Sri Venkateshwara Tiffin Hub',
      tagline: 'Khammam\'s Famous Woodfire Ghee Dosa & Spongy Thatte Idli',
      zone: 'Khammam North (Bypass Road)',
      address: 'Near Old Collectorate Circle, Bypass Road, Khammam',
      rating: 4.8,
      totalReviews: 2450,
      deliveryWindow: 'Drop at gate by 7:30 AM',
      isPureVeg: true,
      carouselImages: const [
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: const ['Ghee Thatte Idli', 'Rayalaseema Karam Dosa', 'Piping Sambar'],
      status: ShopStatus.open,
      menuItems: [
        TiffinItem.standardMenuItems[0].copyWith(shopId: 'shop_venkateshwara', shopName: 'Sri Venkateshwara Tiffin Hub'),
        TiffinItem.standardMenuItems[1].copyWith(shopId: 'shop_venkateshwara', shopName: 'Sri Venkateshwara Tiffin Hub'),
        TiffinItem.standardMenuItems[3].copyWith(shopId: 'shop_venkateshwara', shopName: 'Sri Venkateshwara Tiffin Hub'),
        TiffinItem.standardMenuItems[6].copyWith(shopId: 'shop_venkateshwara', shopName: 'Sri Venkateshwara Tiffin Hub'),
      ],
      isPromoted: true,
      discountLabel: 'FLAT ₹20 OFF • BESTSELLER',
    ),
    TiffinShop(
      id: 'shop_amma_chethi',
      name: 'Amma Chethi Vanta',
      tagline: 'Authentic Andhra Homestyle Breakfast prepared with pure cow ghee',
      zone: 'Khammam South (Wyra Road)',
      address: 'Shop 4, Mamillagudem Main Road, Wyra Road, Khammam',
      rating: 4.9,
      totalReviews: 3120,
      deliveryWindow: 'Drop at gate by 7:30 AM',
      isPureVeg: false,
      carouselImages: const [
        'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: const ['MLA Pesarattu Upma', 'Fluffy Poori Kurma', 'Allam Chutney'],
      status: ShopStatus.open,
      menuItems: [
        TiffinItem.standardMenuItems[2].copyWith(shopId: 'shop_amma_chethi', shopName: 'Amma Chethi Vanta'),
        TiffinItem.standardMenuItems[4].copyWith(shopId: 'shop_amma_chethi', shopName: 'Amma Chethi Vanta'),
        TiffinItem.standardMenuItems[5].copyWith(shopId: 'shop_amma_chethi', shopName: 'Amma Chethi Vanta'),
        TiffinItem.standardMenuItems[7].copyWith(shopId: 'shop_amma_chethi', shopName: 'Amma Chethi Vanta'),
      ],
      isPromoted: true,
      discountLabel: 'CHEF RECOMMENDATION',
    ),
    TiffinShop(
      id: 'shop_bala_corner',
      name: 'Bala Tiffin Corner',
      tagline: 'Crispy hot Mysore Bondas & Vadas since 1994',
      zone: 'Khammam East (Bus Stand)',
      address: 'Opposite RTC New Bus Stand, Khammam',
      rating: 4.7,
      totalReviews: 1890,
      deliveryWindow: 'Drop at gate by 7:30 AM',
      isPureVeg: true,
      carouselImages: const [
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: const ['Crisp Mysore Bonda', 'Medu Vada with Coconut Chutney'],
      status: ShopStatus.open,
      menuItems: [
        TiffinItem.standardMenuItems[1].copyWith(shopId: 'shop_bala_corner', shopName: 'Bala Tiffin Corner'),
        TiffinItem.standardMenuItems[3].copyWith(shopId: 'shop_bala_corner', shopName: 'Bala Tiffin Corner'),
        TiffinItem.standardMenuItems[6].copyWith(shopId: 'shop_bala_corner', shopName: 'Bala Tiffin Corner'),
      ],
      discountLabel: 'LOCAL FAVORITE',
    ),
    TiffinShop(
      id: 'shop_sai_udupi',
      name: 'Sri Sai Udupi Upahar',
      tagline: 'Traditional Karnataka Udupi breakfast with rich drumstick sambar',
      zone: 'Khammam West (Gandhi Chowk)',
      address: 'Near Clock Tower, Gandhi Chowk, Khammam',
      rating: 4.6,
      totalReviews: 980,
      deliveryWindow: 'Drop at gate by 7:30 AM',
      isPureVeg: true,
      carouselImages: const [
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: const ['Udupi Thatte Idli', 'Filter Coffee', 'Crisp Vada'],
      status: ShopStatus.closedTemporary,
      closureReason: 'Closed briefly for kitchen deep-cleaning',
      reopenDate: 'Reopening tomorrow morning',
      menuItems: [
        TiffinItem.standardMenuItems[0].copyWith(shopId: 'shop_sai_udupi', shopName: 'Sri Sai Udupi Upahar'),
        TiffinItem.standardMenuItems[1].copyWith(shopId: 'shop_sai_udupi', shopName: 'Sri Sai Udupi Upahar'),
        TiffinItem.standardMenuItems[7].copyWith(shopId: 'shop_sai_udupi', shopName: 'Sri Sai Udupi Upahar'),
      ],
    ),
  ];
}
