import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/business_rules.dart';
import '../../domain/tiffin_item_model.dart';
import '../widgets/pass_card_3d.dart';

/// Enum distinguishing between a daily one-off meal purchase and a multi-day pass
enum OrderMode {
  singleDay,
  subscriptionPass,
}

/// Immutable state holding the customer's cart configuration and selections
class CartState {
  final OrderMode orderMode;
  final PassTierType? selectedPassTier;
  final int selectedPassDays;
  final Map<String, int> itemQuantities;
  final String selectedDeliverySlot;
  final String? appliedCoupon;
  final int discountAmount;
  final String deliveryInstructions;
  final String paymentMethod;
  final int roommateMealCount; // +₹45 Companion Meal (Same Gate Bag)
  final bool autoRotatePassMenu; // Auto-rotate 6 authentic Khammam specialties

  const CartState({
    this.orderMode = OrderMode.singleDay,
    this.selectedPassTier = PassTierType.routine7Day,
    this.selectedPassDays = 7,
    this.itemQuantities = const {},
    this.selectedDeliverySlot = '07:30 AM – 08:00 AM',
    this.appliedCoupon,
    this.discountAmount = 0,
    this.deliveryInstructions = '',
    this.paymentMethod = 'Google Pay',
    this.roommateMealCount = 0,
    this.autoRotatePassMenu = true,
  });

  factory CartState.initial() => const CartState();

  /// Total cost of companion roommate meals (₹45 each, instead of ₹59)
  int get roommateSubtotal => roommateMealCount * 45;

  /// Subtotal for individual single-day menu items & addons
  int get itemsSubtotal {
    int sum = 0;
    for (final entry in itemQuantities.entries) {
      final item = TiffinItem.findById(entry.key);
      if (item != null) {
        sum += item.price * entry.value;
      }
    }
    return sum + roommateSubtotal;
  }

  /// Price of selected subscription pass tier
  int get passSubtotal {
    if (selectedPassTier == null) return 0;
    switch (selectedPassTier!) {
      case PassTierType.trial3Day:
        return BusinessRules.pass3DayPrice; // 165
      case PassTierType.routine7Day:
        return BusinessRules.pass7DayPrice; // 350
      case PassTierType.power15Day:
        return BusinessRules.pass15DayPrice; // 720
    }
  }

  /// Total customer savings including item discounts, pass subsidies, and coupons
  int get savingsAmount {
    int itemSavings = 0;
    for (final entry in itemQuantities.entries) {
      final item = TiffinItem.findById(entry.key);
      if (item != null && item.originalPrice > item.price) {
        itemSavings += (item.originalPrice - item.price) * entry.value;
      }
    }

    int passSavings = 0;
    if (orderMode == OrderMode.subscriptionPass && selectedPassTier != null) {
      const standardMealRefPrice = 65;
      final nominalValue = selectedPassDays * standardMealRefPrice;
      if (nominalValue > passSubtotal) {
        passSavings = nominalValue - passSubtotal;
      }
    }

    // Companion meal discount savings (₹59 regular vs ₹45 roommate meal)
    final roommateSavings = roommateMealCount * 14;

    return itemSavings + passSavings + discountAmount + roommateSavings;
  }

  /// Final payable amount after deducting active coupon discounts
  int get totalPayable {
    final baseAmount = orderMode == OrderMode.subscriptionPass
        ? passSubtotal + itemsSubtotal
        : itemsSubtotal;

    final payable = baseAmount - discountAmount;
    return payable > 0 ? payable : 0;
  }

  /// Total count of individual items selected in the cart
  int get totalItemCount {
    return itemQuantities.values.fold(0, (sum, qty) => sum + qty) + roommateMealCount;
  }

  /// Whether cart currently has any items or a valid pass configured
  bool get isEmpty {
    if (orderMode == OrderMode.subscriptionPass) {
      return selectedPassTier == null && itemQuantities.isEmpty && roommateMealCount == 0;
    }
    return itemQuantities.isEmpty && roommateMealCount == 0;
  }

  CartState copyWith({
    OrderMode? orderMode,
    PassTierType? selectedPassTier,
    bool clearPassTier = false,
    int? selectedPassDays,
    Map<String, int>? itemQuantities,
    String? selectedDeliverySlot,
    String? appliedCoupon,
    bool clearCoupon = false,
    int? discountAmount,
    String? deliveryInstructions,
    String? paymentMethod,
    int? roommateMealCount,
    bool? autoRotatePassMenu,
  }) {
    return CartState(
      orderMode: orderMode ?? this.orderMode,
      selectedPassTier:
          clearPassTier ? null : (selectedPassTier ?? this.selectedPassTier),
      selectedPassDays: selectedPassDays ?? this.selectedPassDays,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      selectedDeliverySlot:
          selectedDeliverySlot ?? this.selectedDeliverySlot,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryInstructions:
          deliveryInstructions ?? this.deliveryInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      roommateMealCount: roommateMealCount ?? this.roommateMealCount,
      autoRotatePassMenu: autoRotatePassMenu ?? this.autoRotatePassMenu,
    );
  }
}

/// StateNotifier orchestrating cart operations, item quantities, coupons, and checkout setup
class CartViewModel extends StateNotifier<CartState> {
  CartViewModel() : super(CartState.initial());

  /// Increase roommate companion meal count (+₹45, same bag drop)
  void addRoommateMeal() {
    state = state.copyWith(roommateMealCount: state.roommateMealCount + 1);
  }

  /// Decrease roommate companion meal count
  void removeRoommateMeal() {
    if (state.roommateMealCount > 0) {
      state = state.copyWith(roommateMealCount: state.roommateMealCount - 1);
    }
  }

  /// Toggle smart pass menu auto-rotation
  void toggleAutoRotatePassMenu(bool value) {
    state = state.copyWith(autoRotatePassMenu: value);
  }

  /// Increase item quantity by 1
  void addItem(String itemId) {
    final updated = Map<String, int>.from(state.itemQuantities);
    updated[itemId] = (updated[itemId] ?? 0) + 1;
    state = state.copyWith(itemQuantities: updated);
  }

  /// Decrease item quantity by 1, removing from cart when quantity drops to 0
  void removeItem(String itemId) {
    final updated = Map<String, int>.from(state.itemQuantities);
    if (!updated.containsKey(itemId)) return;

    final currentQty = updated[itemId]!;
    if (currentQty <= 1) {
      updated.remove(itemId);
    } else {
      updated[itemId] = currentQty - 1;
    }
    state = state.copyWith(itemQuantities: updated);
  }

  /// Explicitly set item quantity (removes item if quantity <= 0)
  void setItemQuantity(String itemId, int quantity) {
    final updated = Map<String, int>.from(state.itemQuantities);
    if (quantity <= 0) {
      updated.remove(itemId);
    } else {
      updated[itemId] = quantity;
    }
    state = state.copyWith(itemQuantities: updated);
  }

  /// Clear all selected items from the cart
  void clearCart() {
    state = state.copyWith(itemQuantities: const {});
  }

  /// Switch between Single Day Tiffin and Subscription Pass order modes
  void setOrderMode(OrderMode mode) {
    state = state.copyWith(orderMode: mode);
  }

  /// Select a subscription pass tier and update corresponding meal days count
  void selectPassTier(PassTierType tier) {
    int days = 7;
    switch (tier) {
      case PassTierType.trial3Day:
        days = BusinessRules.pass3DayMeals;
        break;
      case PassTierType.routine7Day:
        days = BusinessRules.pass7DayMeals;
        break;
      case PassTierType.power15Day:
        days = BusinessRules.pass15DayMeals;
        break;
    }

    state = state.copyWith(
      selectedPassTier: tier,
      selectedPassDays: days,
    );
  }

  /// Choose morning delivery time window ('07:30 AM – 08:00 AM' or '08:00 AM – 08:30 AM')
  void selectDeliverySlot(String slot) {
    state = state.copyWith(selectedDeliverySlot: slot);
  }

  /// Apply promo coupons:
  /// - 'FIRST50' = ₹50 off
  /// - 'HUNGRFREE' = ₹25 off
  /// Returns `true` if valid coupon was applied, `false` otherwise.
  bool applyCoupon(String code) {
    final normalized = code.trim().toUpperCase();
    if (normalized == 'FIRST50') {
      state = state.copyWith(
        appliedCoupon: 'FIRST50',
        discountAmount: 50,
      );
      return true;
    } else if (normalized == 'HUNGRFREE') {
      state = state.copyWith(
        appliedCoupon: 'HUNGRFREE',
        discountAmount: 25,
      );
      return true;
    }
    return false;
  }

  /// Remove currently applied coupon and reset discount to 0
  void removeCoupon() {
    state = state.copyWith(
      clearCoupon: true,
      discountAmount: 0,
    );
  }

  /// Update payment gateway or method selection
  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  /// Set optional delivery notes or hostel gate directions
  void setDeliveryInstructions(String instructions) {
    state = state.copyWith(deliveryInstructions: instructions);
  }

  /// Reset the cart to initial state
  void reset() {
    state = CartState.initial();
  }
}

/// Provider for accessing and modifying Hungr's shopping cart state
final cartViewModelProvider =
    StateNotifierProvider<CartViewModel, CartState>((ref) {
  return CartViewModel();
});

/// Convenient alias for storefront screens
final cartProvider = cartViewModelProvider;
