import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/business_rules.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/offer_model.dart';
import '../../domain/tiffin_item_model.dart';
import '../widgets/pass_card_3d.dart';

/// Enum distinguishing between a daily one-off meal purchase and a multi-day pass
enum OrderMode {
  singleDay,
  subscriptionPass,
}

/// Immutable state holding the customer's cart configuration and live resolved items
class CartState {
  final OrderMode orderMode;
  final PassTierType? selectedPassTier;
  final int selectedPassDays;
  final String? activeKitchenId;
  final String? activeKitchenName;
  final Map<String, int> itemQuantities;
  final Map<String, TiffinItem> itemDetails;
  final String selectedDeliverySlot;
  final String? appliedCoupon;
  final int discountAmount;
  final String deliveryInstructions;
  final String paymentMethod;
  final int roommateMealCount; // +₹45 Companion Meal (Same Gate Bag)
  final bool autoRotatePassMenu;

  const CartState({
    this.orderMode = OrderMode.singleDay,
    this.selectedPassTier = PassTierType.routine7Day,
    this.selectedPassDays = 7,
    this.activeKitchenId,
    this.activeKitchenName,
    this.itemQuantities = const {},
    this.itemDetails = const {},
    this.selectedDeliverySlot = '07:30 AM – 08:00 AM',
    this.appliedCoupon,
    this.discountAmount = 0,
    this.deliveryInstructions = '',
    this.paymentMethod = 'Google Pay',
    this.roommateMealCount = 0,
    this.autoRotatePassMenu = true,
  });

  factory CartState.initial() => const CartState();

  /// Resolve item metadata from live catalog map or standard menu fallback
  TiffinItem? resolveItem(String itemId) {
    return itemDetails[itemId] ?? TiffinItem.findById(itemId);
  }

  /// Total cost of companion roommate meals (₹45 each, instead of ₹59)
  int get roommateSubtotal => roommateMealCount * 45;

  /// Subtotal for individual single-day menu items & addons
  int get itemsSubtotal {
    int sum = 0;
    for (final entry in itemQuantities.entries) {
      final item = resolveItem(entry.key);
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
        return BusinessRules.pass3DayPrice;
      case PassTierType.routine7Day:
        return BusinessRules.pass7DayPrice;
      case PassTierType.power15Day:
        return BusinessRules.pass15DayPrice;
    }
  }

  /// Total customer savings including item discounts, pass subsidies, and coupons
  int get savingsAmount {
    int itemSavings = 0;
    for (final entry in itemQuantities.entries) {
      final item = resolveItem(entry.key);
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
    String? activeKitchenId,
    String? activeKitchenName,
    bool clearKitchen = false,
    Map<String, int>? itemQuantities,
    Map<String, TiffinItem>? itemDetails,
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
      selectedPassTier: clearPassTier ? null : (selectedPassTier ?? this.selectedPassTier),
      selectedPassDays: selectedPassDays ?? this.selectedPassDays,
      activeKitchenId: clearKitchen ? null : (activeKitchenId ?? this.activeKitchenId),
      activeKitchenName: clearKitchen ? null : (activeKitchenName ?? this.activeKitchenName),
      itemQuantities: itemQuantities ?? this.itemQuantities,
      itemDetails: itemDetails ?? this.itemDetails,
      selectedDeliverySlot: selectedDeliverySlot ?? this.selectedDeliverySlot,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: discountAmount ?? this.discountAmount,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      roommateMealCount: roommateMealCount ?? this.roommateMealCount,
      autoRotatePassMenu: autoRotatePassMenu ?? this.autoRotatePassMenu,
    );
  }
}

/// StateNotifier orchestrating cart operations, kitchen conflict guards, live coupons, and checkout setup
class CartViewModel extends StateNotifier<CartState> {
  CartViewModel() : super(CartState.initial());

  /// Returns true if adding [item] conflicts with an existing different kitchen in cart
  bool hasKitchenConflict(TiffinItem item) {
    if (state.orderMode == OrderMode.subscriptionPass) return false;
    if (state.itemQuantities.isEmpty || state.activeKitchenId == null) return false;
    final incomingKitchen = item.shopId;
    if (incomingKitchen == null || incomingKitchen.isEmpty) return false;
    return state.activeKitchenId != incomingKitchen;
  }

  /// Replaces cart with new kitchen & item (Swiggy-style "Replace cart?" flow)
  void replaceCartWithItem(TiffinItem item) {
    state = CartState.initial().copyWith(
      orderMode: OrderMode.singleDay,
      activeKitchenId: item.shopId,
      activeKitchenName: item.shopName,
      itemQuantities: {item.id: 1},
      itemDetails: {item.id: item},
    );
    _syncCartTracking();
  }

  /// Increase item quantity by 1 (prefer passing full TiffinItem so live admin dishes/prices work)
  void addTiffinItem(TiffinItem item) {
    final updatedQty = Map<String, int>.from(state.itemQuantities);
    updatedQty[item.id] = (updatedQty[item.id] ?? 0) + 1;

    final updatedDetails = Map<String, TiffinItem>.from(state.itemDetails);
    updatedDetails[item.id] = item;

    state = state.copyWith(
      orderMode: state.orderMode == OrderMode.subscriptionPass && updatedQty.length == 1
          ? OrderMode.singleDay
          : state.orderMode,
      activeKitchenId: state.activeKitchenId ?? item.shopId,
      activeKitchenName: state.activeKitchenName ?? item.shopName,
      itemQuantities: updatedQty,
      itemDetails: updatedDetails,
    );
    _syncCartTracking();
  }

  /// Backwards-compatible add by itemId (falls back to standard menu if item not in details map)
  void addItem(String itemId) {
    final existing = state.resolveItem(itemId);
    if (existing != null) {
      addTiffinItem(existing);
      return;
    }
    final updated = Map<String, int>.from(state.itemQuantities);
    updated[itemId] = (updated[itemId] ?? 0) + 1;
    state = state.copyWith(itemQuantities: updated);
    _syncCartTracking();
  }

  /// Decrease item quantity by 1, clearing kitchen lock when cart empties
  void removeItem(String itemId) {
    final updated = Map<String, int>.from(state.itemQuantities);
    if (!updated.containsKey(itemId)) return;

    final currentQty = updated[itemId]!;
    if (currentQty <= 1) {
      updated.remove(itemId);
    } else {
      updated[itemId] = currentQty - 1;
    }

    final updatedDetails = Map<String, TiffinItem>.from(state.itemDetails);
    if (!updated.containsKey(itemId)) {
      updatedDetails.remove(itemId);
    }

    state = state.copyWith(
      itemQuantities: updated,
      itemDetails: updatedDetails,
      clearKitchen: updated.isEmpty,
    );
    _syncCartTracking();
  }

  void addRoommateMeal() {
    state = state.copyWith(roommateMealCount: state.roommateMealCount + 1);
  }

  void removeRoommateMeal() {
    if (state.roommateMealCount > 0) {
      state = state.copyWith(roommateMealCount: state.roommateMealCount - 1);
    }
  }

  void toggleAutoRotatePassMenu(bool value) {
    state = state.copyWith(autoRotatePassMenu: value);
  }

  void _syncCartTracking() {
    try {
      final phone = FirebaseService.instance.currentUser?.phoneNumber;
      if (phone == null || phone.isEmpty) return;
      FirebaseService.instance.trackAbandonedCart(
        phone: phone,
        items: state.itemQuantities,
        subtotal: state.itemsSubtotal,
      );
    } catch (_) {}
  }

  void clearCart() {
    state = state.copyWith(
      itemQuantities: const {},
      itemDetails: const {},
      clearKitchen: true,
      clearCoupon: true,
      discountAmount: 0,
      roommateMealCount: 0,
    );
    _syncCartTracking();
  }

  void setOrderMode(OrderMode mode) {
    state = state.copyWith(orderMode: mode);
  }

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

  void selectDeliverySlot(String slot) {
    state = state.copyWith(selectedDeliverySlot: slot);
  }

  /// Apply coupon against live Firestore offers (and return error message if invalid / below minOrder)
  String? applyCoupon(String code, {List<OfferModel> availableOffers = const []}) {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return 'Enter a promo code.';

    final allOffers = availableOffers.isNotEmpty ? availableOffers : OfferModel.defaultOffers;
    final matched = allOffers.where((o) => o.code == normalized && o.isActive).toList();

    if (matched.isEmpty) {
      return 'Promo code "$normalized" is invalid or expired.';
    }

    final offer = matched.first;
    final baseAmount = state.orderMode == OrderMode.subscriptionPass
        ? state.passSubtotal + state.itemsSubtotal
        : state.itemsSubtotal;

    if (baseAmount < offer.minOrder) {
      return 'Minimum order of ₹${offer.minOrder} required for ${offer.code}.';
    }

    final discount = offer.computeDiscount(baseAmount);
    state = state.copyWith(
      appliedCoupon: offer.code,
      discountAmount: discount,
    );
    return null; // null = success
  }

  void removeCoupon() {
    state = state.copyWith(
      clearCoupon: true,
      discountAmount: 0,
    );
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setDeliveryInstructions(String instructions) {
    state = state.copyWith(deliveryInstructions: instructions);
  }

  void reset() {
    state = CartState.initial();
  }
}

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>((ref) {
  return CartViewModel();
});

final cartProvider = Provider<CartState>((ref) {
  return ref.watch(cartViewModelProvider);
});
