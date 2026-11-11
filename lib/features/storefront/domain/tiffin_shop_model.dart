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

  /// Default Khammam partner kitchens
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
      carouselImages: [
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: ['Ghee Thatte Idli', 'Rayalaseema Karam Dosa', 'Piping Sambar'],
      status: ShopStatus.open,
      menuItems: [
        TiffinItem.standardMenuItems[0], // Set Dosa
        TiffinItem.standardMenuItems[1], // Idli Vada
        TiffinItem.standardMenuItems[3], // Mysore Bonda
        TiffinItem.standardMenuItems[6], // Filter Coffee
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
      isPureVeg: true,
      carouselImages: [
        'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: ['MLA Pesarattu Upma', 'Fluffy Poori Kurma', 'Allam Chutney'],
      status: ShopStatus.open,
      menuItems: [
        TiffinItem.standardMenuItems[2], // Poori Masala
        TiffinItem.standardMenuItems[4], // MLA Pesarattu Upma
        TiffinItem.standardMenuItems[5], // Boiled Eggs
        TiffinItem.standardMenuItems[7], // Kesari Badam Milk
      ],
      isPromoted: true,
      discountLabel: 'CHEFS RECOMMENDATION',
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
      carouselImages: [
        'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: ['Crisp Mysore Bonda', 'Medu Vada with Coconut Chutney'],
      status: ShopStatus.closedToday,
      closureReason: 'Kitchen equipment maintenance today',
      reopenDate: 'Tomorrow at 6:00 AM',
      menuItems: [
        TiffinItem.standardMenuItems[1],
        TiffinItem.standardMenuItems[3],
        TiffinItem.standardMenuItems[6],
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
      carouselImages: [
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: ['Udupi Thatte Idli', 'Filter Coffee', 'Crisp Vada'],
      status: ShopStatus.closedTemporary,
      closureReason: 'Closed for 2 days due to family temple festival',
      reopenDate: 'Reopens Thursday, 14 Nov',
      menuItems: [
        TiffinItem.standardMenuItems[0],
        TiffinItem.standardMenuItems[1],
        TiffinItem.standardMenuItems[7],
      ],
    ),
  ];
}
