import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungr/core/utils/date_time_utils.dart';
import 'package:hungr/core/utils/whatsapp_link_helper.dart';
import 'package:hungr/features/storefront/presentation/viewmodels/cart_viewmodel.dart';
import 'package:hungr/features/storefront/presentation/viewmodels/tiffin_shops_viewmodel.dart';
import 'package:hungr/features/storefront/domain/tiffin_shop_model.dart';
import 'package:hungr/features/storefront/data/shop_sync_service.dart';

void main() {
  group('1. Cutoff Rollover Engine & Bag Token Generator', () {
    test('targetDeliveryDate rolls over past 21:00 IST cutoff', () {
      final beforeCutoff = DateTime(2026, 11, 12, 18, 0); // 6:00 PM
      final afterCutoff = DateTime(2026, 11, 12, 21, 15); // 9:15 PM

      expect(DateTimeUtils.isAfterCutoffToday(testTime: beforeCutoff), isFalse);
      expect(DateTimeUtils.isAfterCutoffToday(testTime: afterCutoff), isTrue);

      final targetBefore = DateTimeUtils.targetDeliveryDate(testTime: beforeCutoff);
      expect(targetBefore.day, equals(13)); // Tomorrow

      final targetAfter = DateTimeUtils.targetDeliveryDate(testTime: afterCutoff);
      expect(targetAfter.day, equals(14)); // Day after tomorrow rollover
    });

    test('generateBagToken generates 4-6 char token with cluster prefix', () {
      final tokenSai = DateTimeUtils.generateBagToken(clusterName: 'Sri Sai PG', orderId: 'ord_12345');
      expect(tokenSai.startsWith('#SS-'), isTrue);

      final tokenKakatiya = DateTimeUtils.generateBagToken(clusterName: 'Kakatiya Girls Hostel', orderId: 'ord_98765');
      expect(tokenKakatiya.startsWith('#KG-'), isTrue);
    });
  });

  group('2. WhatsApp Deep Link & Gate Alert Formatter', () {
    test('generateTicketDeepLink and generateDropDeepLink format valid custom schemes', () {
      final ticketLink = WhatsAppLinkHelper.generateTicketDeepLink('tkt_999');
      expect(ticketLink, equals('hungr://ticket/tkt_999'));

      final dropLink = WhatsAppLinkHelper.generateDropDeepLink('#SS-04');
      expect(dropLink, equals('hungr://drop/SS-04'));
    });

    test('generateGateDropWhatsAppMessage includes bag token, location, and deep link', () {
      final message = WhatsAppLinkHelper.generateGateDropWhatsAppMessage(
        customerName: 'Rahul',
        bagToken: '#SS-04',
        clusterName: 'Sri Sai PG Watchman Desk',
        driverName: 'Ramesh Goud',
        ticketId: 'tkt_12345',
      );

      expect(message.contains('#SS-04'), isTrue);
      expect(message.contains('Sri Sai PG Watchman Desk'), isTrue);
      expect(message.contains('Ramesh Goud'), isTrue);
      expect(message.contains('hungr://ticket/tkt_12345'), isTrue);
    });
  });

  group('3. Cart & Roommate Companion Meal Engine', () {
    test('companion meal additions update total and calculate fuel-consolidation savings', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartViewModelProvider.notifier);
      expect(container.read(cartProvider).roommateMealCount, equals(0));

      cartNotifier.setRoommateMeals(2);
      final state = container.read(cartProvider);
      expect(state.roommateMealCount, equals(2));
      expect(state.roommateCompanionTotal, equals(90)); // 2 * 45
      expect(state.roommateCompanionSavings, equals(28)); // 2 * 14
    });

    test('toggleAutoRotatePassMenu updates state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartViewModelProvider.notifier);
      expect(container.read(cartProvider).autoRotatePassMenu, isTrue);

      cartNotifier.toggleAutoRotatePassMenu(false);
      expect(container.read(cartProvider).autoRotatePassMenu, isFalse);

      cartNotifier.toggleAutoRotatePassMenu(true);
      expect(container.read(cartProvider).autoRotatePassMenu, isTrue);
    });
  });

  group('4. Real-time Live Sync (Web Admin ⇄ Mobile App)', () {
    test('ShopSyncService updates shop status and emits live ops event', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final syncService = container.read(shopSyncServiceProvider);
      final events = <OpsSyncEvent>[];
      final subscription = syncService.eventStream.listen(events.add);
      addTearDown(subscription.cancel);

      // Verify initial state
      final shopsInitial = container.read(tiffinShopsProvider);
      final balaCorner = shopsInitial.firstWhere((s) => s.id == 'shop_bala_corner');
      expect(balaCorner.status, equals(ShopStatus.closedToday));

      // Ops Admin marks shop OPEN
      syncService.applyShopStatusUpdate(
        shopId: 'shop_bala_corner',
        status: ShopStatus.open,
      );

      final shopsUpdated = container.read(tiffinShopsProvider);
      final balaUpdated = shopsUpdated.firstWhere((s) => s.id == 'shop_bala_corner');
      expect(balaUpdated.status, equals(ShopStatus.open));
      expect(balaUpdated.isOpen, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(events.length, equals(1));
      expect(events.first.action, equals(OpsSyncAction.statusChange));
      expect(events.first.description.contains('Open'), isTrue);
    });

    test('ShopSyncService updates item price dynamically', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final syncService = container.read(shopSyncServiceProvider);
      syncService.applyDishPriceUpdate(
        shopId: 'shop_venkateshwara',
        itemId: 'item_set_dosa',
        newPrice: 55,
      );

      final shops = container.read(tiffinShopsProvider);
      final venkateshwara = shops.firstWhere((s) => s.id == 'shop_venkateshwara');
      final setDosa = venkateshwara.menuItems.firstWhere((i) => i.id == 'item_set_dosa');
      expect(setDosa.price, equals(55));
    });
  });
}
