import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/tiffin_shop_model.dart';

final tiffinShopsProvider =
    StateNotifierProvider<TiffinShopsViewModel, List<TiffinShop>>((ref) {
  return TiffinShopsViewModel();
});

class TiffinShopsViewModel extends StateNotifier<List<TiffinShop>> {
  TiffinShopsViewModel() : super(TiffinShop.standardShops);

  /// Update shop status, optional closure reason and reopen date
  void updateShopStatus({
    required String shopId,
    required ShopStatus status,
    String? closureReason,
    String? reopenDate,
  }) {
    state = state.map((shop) {
      if (shop.id == shopId) {
        return shop.copyWith(
          status: status,
          closureReason: closureReason,
          reopenDate: reopenDate,
        );
      }
      return shop;
    }).toList();
  }

  /// Update shop menu item price or availability
  void updateMenuItemPrice({
    required String shopId,
    required String itemId,
    required int newPrice,
  }) {
    state = state.map((shop) {
      if (shop.id == shopId) {
        final updatedItems = shop.menuItems.map((item) {
          if (item.id == itemId) {
            return item.copyWith(price: newPrice);
          }
          return item;
        }).toList();
        return shop.copyWith(menuItems: updatedItems);
      }
      return shop;
    }).toList();
  }

  /// Add a new shop listing (from web dashboard)
  void addShop(TiffinShop newShop) {
    state = [...state, newShop];
  }

  /// Get shop by ID
  TiffinShop? getShopById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}
