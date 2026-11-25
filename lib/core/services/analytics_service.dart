import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Production Funnel & Conversion Analytics Wrapper (Firebase Analytics)
class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  FirebaseAnalytics? _analytics;

  void init() {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('⚠️ [AnalyticsService] Init notice: $e');
    }
  }

  Future<void> logLogin() async {
    try {
      await _analytics?.logLogin(loginMethod: 'phone_otp');
    } catch (_) {}
  }

  Future<void> logAddToCart({required String itemId, required String itemName, required int price}) async {
    try {
      await _analytics?.logAddToCart(
        currency: 'INR',
        value: price.toDouble(),
        items: [
          AnalyticsEventItem(itemId: itemId, itemName: itemName, price: price.toDouble(), quantity: 1),
        ],
      );
    } catch (_) {}
  }

  Future<void> logBeginCheckout({required int totalPayable, required String mode}) async {
    try {
      await _analytics?.logBeginCheckout(
        currency: 'INR',
        value: totalPayable.toDouble(),
        coupon: mode,
      );
    } catch (_) {}
  }

  Future<void> logPurchase({required String orderId, required int totalPayable}) async {
    try {
      await _analytics?.logPurchase(
        transactionId: orderId,
        currency: 'INR',
        value: totalPayable.toDouble(),
      );
    } catch (_) {}
  }
}
