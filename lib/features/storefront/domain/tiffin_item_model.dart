/// Model representing a Tiffin breakfast dish, add-on, or beverage in Hungr.
class TiffinItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final int originalPrice;
  final int calories;
  final double proteinGrams;
  final bool isVeg;
  final String tag;
  final String? icon;
  final String? imageRef;
  final String category;
  final bool isAvailable;
  final String? shopId;
  final String? shopName;

  const TiffinItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.calories,
    required this.proteinGrams,
    required this.isVeg,
    required this.tag,
    this.icon,
    this.imageRef,
    required this.category,
    this.isAvailable = true,
    this.shopId,
    this.shopName,
  });

  /// Category constants
  static const String categoryDailyBreakfast = 'Daily Breakfast';
  static const String categoryMorningAddons = 'Morning Addons';
  static const String categoryBeverages = 'Beverages';

  /// Standard tags
  static const String tagBestseller = 'Bestseller';
  static const String tagChefSpecial = 'Chef Special';
  static const String tagLightAndHealthy = 'Light & Healthy';
  static const String tagPopular = 'Popular';
  static const String tagHighProtein = 'High Protein';
  static const String tagMustTry = 'Must Try';
  static const String tagImmunity = 'Immunity';

  /// Calculated discount percentage
  int get discountPercent =>
      originalPrice > price ? (((originalPrice - price) / originalPrice) * 100).round() : 0;

  /// Rupee savings per unit compared to original price
  int get savingsAmount => originalPrice > price ? originalPrice - price : 0;

  TiffinItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    int? originalPrice,
    int? calories,
    double? proteinGrams,
    bool? isVeg,
    String? tag,
    String? icon,
    String? imageRef,
    String? category,
    bool? isAvailable,
    String? shopId,
    String? shopName,
  }) {
    return TiffinItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      isVeg: isVeg ?? this.isVeg,
      tag: tag ?? this.tag,
      icon: icon ?? this.icon,
      imageRef: imageRef ?? this.imageRef,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'isVeg': isVeg,
      'tag': tag,
      'icon': icon,
      'imageRef': imageRef,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  /// Null-safe parser supporting both rich item payloads and minimal web_admin dish objects
  factory TiffinItem.fromMap(
    Map<String, dynamic> map, {
    String? shopId,
    String? shopName,
  }) {
    final id = (map['id'] as String?)?.trim().isNotEmpty == true
        ? (map['id'] as String).trim()
        : 'dish_${DateTime.now().millisecondsSinceEpoch}';
    final template = findById(id);
    final rawName = (map['name'] as String?)?.trim() ?? template?.name ?? 'Fresh Morning Tiffin';
    final lowerName = rawName.toLowerCase();
    final price = (map['price'] as num?)?.toInt() ?? template?.price ?? 49;
    final originalPrice = (map['originalPrice'] as num?)?.toInt() ??
        template?.originalPrice ??
        (price + 15);

    String inferredCategory = template?.category ?? categoryDailyBreakfast;
    if (map['category'] is String && (map['category'] as String).isNotEmpty) {
      inferredCategory = map['category'] as String;
    } else if (lowerName.contains('coffee') || lowerName.contains('milk') || lowerName.contains('tea') || lowerName.contains('chai')) {
      inferredCategory = categoryBeverages;
    } else if (lowerName.contains('egg')) {
      inferredCategory = categoryMorningAddons;
    }

    final bool inferredVeg = map['isVeg'] as bool? ??
        template?.isVeg ??
        (!lowerName.contains('egg') && !lowerName.contains('chicken') && !lowerName.contains('non-veg'));

    return TiffinItem(
      id: id,
      name: rawName,
      description: (map['description'] as String?)?.trim().isNotEmpty == true
          ? map['description'] as String
          : (template?.description ?? 'Prepared fresh every morning with traditional chutneys and piping sambar'),
      price: price,
      originalPrice: originalPrice > price ? originalPrice : price + 10,
      calories: (map['calories'] as num?)?.toInt() ?? template?.calories ?? 310,
      proteinGrams: (map['proteinGrams'] as num?)?.toDouble() ?? template?.proteinGrams ?? 8.0,
      isVeg: inferredVeg,
      tag: (map['tag'] as String?)?.trim().isNotEmpty == true
          ? map['tag'] as String
          : (template?.tag ?? tagPopular),
      icon: map['icon'] as String? ?? template?.icon,
      imageRef: (map['imageRef'] as String?)?.trim().isNotEmpty == true
          ? map['imageRef'] as String
          : template?.imageRef,
      category: inferredCategory,
      isAvailable: map['isAvailable'] as bool? ?? true,
      shopId: shopId ?? map['shopId'] as String?,
      shopName: shopName ?? map['shopName'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TiffinItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Predefined standard menu items for Hungr Storefront
  static List<TiffinItem> get standardMenu => standardMenuItems;
  static const List<TiffinItem> standardMenuItems = [
    TiffinItem(
      id: 'item_set_dosa',
      name: 'Rayalaseema Set Dosa (3 Pcs)',
      description:
          'Fluffy spongy dosas served with spicy Allam (ginger) chutney & fresh peanut chutney',
      price: 49,
      originalPrice: 65,
      calories: 310,
      proteinGrams: 7.0,
      isVeg: true,
      tag: tagBestseller,
      icon: 'breakfast_dining',
      imageRef: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
      category: categoryDailyBreakfast,
    ),
    TiffinItem(
      id: 'item_idli_vada',
      name: 'Steaming Ghee Idlis (4 Pcs) + Medu Vada (1 Pc)',
      description:
          'Melt-in-mouth steamed idlis drizzled with pure cow ghee + 1 crisp golden vada, served with drumstick sambar',
      price: 49,
      originalPrice: 65,
      calories: 290,
      proteinGrams: 9.0,
      isVeg: true,
      tag: tagBestseller,
      icon: 'rice_bowl',
      imageRef: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
      category: categoryDailyBreakfast,
    ),
    TiffinItem(
      id: 'item_poori_masala',
      name: 'Homestyle Poori Masala (3 Pcs)',
      description:
          'Puffed golden pooris with homestyle potato kurma & onion tomato relish',
      price: 55,
      originalPrice: 70,
      calories: 380,
      proteinGrams: 6.0,
      isVeg: true,
      tag: tagChefSpecial,
      icon: 'bakery_dining',
      imageRef: 'https://images.unsplash.com/photo-1626777552726-4a6b54c97e46?w=800&auto=format&fit=crop&q=80',
      category: categoryDailyBreakfast,
    ),
    TiffinItem(
      id: 'item_mysore_bonda',
      name: 'Crisp Mysore Bonda (4 Pcs)',
      description:
          'Crispy exterior with pillowy interior, infused with jeera & ginger, served with coconut chutney',
      price: 45,
      originalPrice: 60,
      calories: 320,
      proteinGrams: 5.0,
      isVeg: true,
      tag: tagPopular,
      icon: 'circle',
      imageRef: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=800&auto=format&fit=crop&q=80',
      category: categoryDailyBreakfast,
    ),
    TiffinItem(
      id: 'item_upma_pesarattu',
      name: 'MLA Pesarattu Upma',
      description:
          'High-protein whole green gram dosa stuffed with hot roasted sooji upma and ginger chutney',
      price: 55,
      originalPrice: 75,
      calories: 340,
      proteinGrams: 12.0,
      isVeg: true,
      tag: tagHighProtein,
      icon: 'dinner_dining',
      imageRef: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?w=800&auto=format&fit=crop&q=80',
      category: categoryDailyBreakfast,
    ),
    TiffinItem(
      id: 'addon_boiled_eggs',
      name: 'Farm Boiled Eggs (2 Pcs)',
      description:
          'Farm-fresh hard-boiled eggs with black pepper & rock salt sachet',
      price: 20,
      originalPrice: 25,
      calories: 155,
      proteinGrams: 13.0,
      isVeg: false,
      tag: tagHighProtein,
      icon: 'egg',
      imageRef: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=800&auto=format&fit=crop&q=80',
      category: categoryMorningAddons,
    ),
    TiffinItem(
      id: 'addon_filter_coffee',
      name: 'Kumbakonam Degree Filter Coffee (200ml)',
      description:
          'Freshly brewed chicory blend in heat-retentive flask pouch',
      price: 25,
      originalPrice: 35,
      calories: 85,
      proteinGrams: 3.0,
      isVeg: true,
      tag: tagMustTry,
      icon: 'coffee',
      imageRef: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80',
      category: categoryBeverages,
    ),
    TiffinItem(
      id: 'addon_badam_milk',
      name: 'Steaming Kesari Badam Milk (200ml)',
      description:
          'Warm saffron & crushed almond milk, natural morning immunity booster',
      price: 25,
      originalPrice: 35,
      calories: 140,
      proteinGrams: 5.0,
      isVeg: true,
      tag: tagImmunity,
      icon: 'local_drink',
      imageRef: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop&q=80',
      category: categoryBeverages,
    ),
  ];

  /// Lookup map by item ID
  static final Map<String, TiffinItem> itemMap = {
    for (final item in standardMenuItems) item.id: item,
  };

  /// Find item by ID helper
  static TiffinItem? findById(String id) => itemMap[id];
}
