import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungr/core/utils/date_time_utils.dart';
import 'package:hungr/core/utils/whatsapp_link_helper.dart';
import 'package:hungr/features/storefront/domain/offer_model.dart';
import 'package:hungr/features/storefront/domain/tiffin_item_model.dart';
import 'package:hungr/features/storefront/presentation/viewmodels/cart_viewmodel.dart';
import 'package:hungr/features/storefront/presentation/viewmodels/tiffin_shops_viewmodel.dart';
import 'package:hungr/features/storefront/domain/tiffin_shop_model.dart';

void main() {
  group('1. Bag Token Generator & Cutoff Utils', () {
    test('generateBagToken generates cluster-prefixed bag token', () {
      final tokenSai = DateTimeUtils.generateBagToken('Sri Sai PG', 4);
      expect(tokenSai.startsWith('#SS-'), isTrue);

      final tokenKakatiya = DateTimeUtils.generateBagToken('Kakatiya Girls Hostel', 9);
      expect(tokenKakatiya.startsWith('#KG-'), isTrue);
    });
  });

  group('2. WhatsApp Deep Link & Alert Formatter', () {
    test('getTicketDeepLink and getBagTokenDeepLink format valid custom schemes', () {
      final ticketLink = WhatsAppLinkHelper.getTicketDeepLink('tkt_999');
      expect(ticketLink, equals('hungr://ticket/tkt_999'));

      final dropLink = WhatsAppLinkHelper.getBagTokenDeepLink('#SS-04');
      expect(dropLink, equals('hungr://drop/SS-04'));
    });

    test('formatGateDropMessage includes bag token, location, and deep link', () {
      final message = WhatsAppLinkHelper.formatGateDropMessage(
        customerName: 'Rahul',
        bagToken: '#SS-04',
        clusterName: 'Sri Sai PG Watchman Desk',
        ticketId: 'tkt_12345',
      );

      expect(message.contains('#SS-04'), isTrue);
      expect(message.contains('Sri Sai PG Watchman Desk'), isTrue);
      expect(message.contains('hungr://ticket/tkt_12345'), isTrue);
    });
  });

  group('3. Live Catalog Parsing, Kitchen Conflict & Delivery Fee Economics', () {
    test('TiffinItem.fromMap safely parses minimal web_admin dish payload', () {
      final item = TiffinItem.fromMap({
        'id': 'custom_dosa_1',
        'name': 'Ghee Karam Dosa',
        'price': 60,
      }, shopId: 'shop_1', shopName: 'Sri Kitchen');

      expect(item.name, equals('Ghee Karam Dosa'));
      expect(item.price, equals(60));
      expect(item.isVeg, isTrue);
      expect(item.shopId, equals('shop_1'));
      expect(item.shopName, equals('Sri Kitchen'));
    });

    test('CartViewModel enforces single-kitchen consistency, delivery fee, and live offers', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartViewModelProvider.notifier);
      final dishA = TiffinItem.standardMenuItems.first.copyWith(
        shopId: 'shop_a',
        shopName: 'Kitchen A',
      );
      final dishB = TiffinItem.standardMenuItems[2].copyWith(
        shopId: 'shop_b',
        shopName: 'Kitchen B',
      );

      // ₹98 single-day order (< ₹149) has ₹15 delivery fee
      cartNotifier.addTiffinItem(dishA);
      cartNotifier.addTiffinItem(dishA);
      expect(container.read(cartProvider).activeKitchenId, equals('shop_a'));
      expect(cartNotifier.hasKitchenConflict(dishB), isTrue);
      expect(container.read(cartProvider).deliveryFee, equals(15));

      // ₹98 < ₹99 minOrder for FIRST50
      final minOrderErr = cartNotifier.applyCoupon(
        'FIRST50',
        availableOffers: OfferModel.defaultOffers,
      );
      expect(minOrderErr, isNotNull);

      // Adding 2 more items brings subtotal to ₹196 (>= ₹149 -> FREE delivery, >= ₹99 -> FIRST50 valid)
      cartNotifier.addTiffinItem(dishA);
      cartNotifier.addTiffinItem(dishA);
      expect(container.read(cartProvider).deliveryFee, equals(0));
      final error = cartNotifier.applyCoupon(
        'FIRST50',
        availableOffers: OfferModel.defaultOffers,
      );
      expect(error, isNull);
      expect(container.read(cartProvider).discountAmount, equals(50));
    });
  });

  group('4. TiffinShopsViewModel Live State', () {
    test('TiffinShopsViewModel updates shop status and dish price', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final vm = container.read(tiffinShopsProvider.notifier);
      vm.updateShopStatus(shopId: 'shop_sai_udupi', status: ShopStatus.open);
      vm.updateMenuItemPrice(shopId: 'shop_venkateshwara', itemId: 'item_set_dosa', newPrice: 55);

      final shops = container.read(tiffinShopsProvider);
      expect(shops.firstWhere((s) => s.id == 'shop_sai_udupi').isOpen, isTrue);
      expect(
        shops
            .firstWhere((s) => s.id == 'shop_venkateshwara')
            .menuItems
            .firstWhere((i) => i.id == 'item_set_dosa')
            .price,
        equals(55),
      );
    });
  });
}
