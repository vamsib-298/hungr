import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/tiffin_shop_model.dart';
import '../domain/tiffin_item_model.dart';
import '../presentation/viewmodels/tiffin_shops_viewmodel.dart';

/// Event model representing real-time operational updates from Web Admin
enum OpsSyncAction {
  statusChange,
  priceChange,
  newKitchenOnboarded,
  refreshAll,
}

class OpsSyncEvent {
  final OpsSyncAction action;
  final String shopId;
  final String shopName;
  final String description;
  final DateTime timestamp;

  const OpsSyncEvent({
    required this.action,
    required this.shopId,
    required this.shopName,
    required this.description,
    required this.timestamp,
  });
}

/// Riverpod provider for the OpsSyncService
final shopSyncServiceProvider = Provider<ShopSyncService>((ref) {
  final service = ShopSyncService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Riverpod stream provider for live ops update events
final liveOpsEventStreamProvider = StreamProvider<OpsSyncEvent>((ref) {
  final service = ref.watch(shopSyncServiceProvider);
  return service.eventStream;
});

/// Service responsible for real-time synchronization between
/// Web Admin operations command portal and customer-facing mobile apps.
class ShopSyncService {
  final Ref _ref;
  final StreamController<OpsSyncEvent> _eventController =
      StreamController<OpsSyncEvent>.broadcast();

  ShopSyncService(this._ref);

  Stream<OpsSyncEvent> get eventStream => _eventController.stream;

  /// Apply a status change broadcast from operations desk
  void applyShopStatusUpdate({
    required String shopId,
    required ShopStatus status,
    String? closureReason,
    String? reopenDate,
  }) {
    final viewModel = _ref.read(tiffinShopsProvider.notifier);
    final currentShop = viewModel.getShopById(shopId);
    final shopName = currentShop?.name ?? 'Kitchen #$shopId';

    viewModel.updateShopStatus(
      shopId: shopId,
      status: status,
      closureReason: closureReason,
      reopenDate: reopenDate,
    );

    final event = OpsSyncEvent(
      action: OpsSyncAction.statusChange,
      shopId: shopId,
      shopName: shopName,
      description: status == ShopStatus.open
          ? '$shopName is now Open for Morning Drops!'
          : '$shopName marked ${status.displayName}: ${closureReason ?? "Maintenance"}',
      timestamp: DateTime.now(),
    );

    _eventController.add(event);
    debugPrint('🔔 [Hungr Live Sync] $shopName status changed to ${status.name}');
  }

  /// Apply dish price update broadcast from kitchen partner
  void applyDishPriceUpdate({
    required String shopId,
    required String itemId,
    required int newPrice,
  }) {
    final viewModel = _ref.read(tiffinShopsProvider.notifier);
    final currentShop = viewModel.getShopById(shopId);
    final shopName = currentShop?.name ?? 'Kitchen #$shopId';

    viewModel.updateMenuItemPrice(
      shopId: shopId,
      itemId: itemId,
      newPrice: newPrice,
    );

    final event = OpsSyncEvent(
      action: OpsSyncAction.priceChange,
      shopId: shopId,
      shopName: shopName,
      description: 'Price adjusted for menu item in $shopName to ₹$newPrice',
      timestamp: DateTime.now(),
    );

    _eventController.add(event);
    debugPrint('🔔 [Hungr Live Sync] $shopName item $itemId updated to ₹$newPrice');
  }

  /// Onboard a newly partnered kitchen live without requiring app restart
  void onboardPartnerKitchen({
    required String id,
    required String name,
    required String tagline,
    required String zone,
    required String address,
    required List<TiffinItem> menuItems,
  }) {
    final newShop = TiffinShop(
      id: id,
      name: name,
      tagline: tagline,
      zone: zone,
      address: address,
      rating: 4.8,
      totalReviews: 24,
      deliveryWindow: 'Drop at gate by 7:30 AM',
      carouselImages: const [
        'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?w=800&auto=format&fit=crop&q=80',
        'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=800&auto=format&fit=crop&q=80',
      ],
      specialties: const ['Woodfire Ghee Roast', 'Spongy Thatte Idli'],
      status: ShopStatus.open,
      menuItems: menuItems,
      isPromoted: true,
      discountLabel: 'NEW KITCHEN PARTNER',
    );

    _ref.read(tiffinShopsProvider.notifier).addShop(newShop);

    final event = OpsSyncEvent(
      action: OpsSyncAction.newKitchenOnboarded,
      shopId: id,
      shopName: name,
      description: 'New legendary tiffin partner "$name" ($zone) is now live on Hungr!',
      timestamp: DateTime.now(),
    );

    _eventController.add(event);
    debugPrint('🔔 [Hungr Live Sync] New kitchen onboarded: $name');
  }

  /// Quick test / simulated sync trigger for instant QA and verification
  void triggerSimulatedOpsSync() {
    final shops = _ref.read(tiffinShopsProvider);
    if (shops.isEmpty) return;

    // Toggle status of Bala Tiffin Corner or first closed shop
    final targetShop = shops.firstWhere(
      (s) => s.id == 'shop_bala_corner',
      orElse: () => shops.first,
    );

    if (targetShop.isOpen) {
      applyShopStatusUpdate(
        shopId: targetShop.id,
        status: ShopStatus.closedToday,
        closureReason: 'Woodfire chimney maintenance in progress',
        reopenDate: 'Tomorrow at 6:00 AM',
      );
    } else {
      applyShopStatusUpdate(
        shopId: targetShop.id,
        status: ShopStatus.open,
        closureReason: null,
        reopenDate: null,
      );
    }
  }

  void dispose() {
    _eventController.close();
  }
}
