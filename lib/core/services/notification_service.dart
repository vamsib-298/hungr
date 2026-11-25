import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/router/app_router.dart';
import 'firebase_service.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('🌙 [FCM Background] Message received: ${message.messageId} - ${message.notification?.title}');
}

/// Production Notification & Customer Retention Service for Hungr
/// Implements Swiggy/Zomato style habit loops: 8:15 PM cutoff urgency, 7:15 AM drop alerts,
/// and cart abandonment recovery nudges.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  bool _isInitialized = false;

  /// Initializes FCM, requests runtime notification permissions, and subscribes to core topics
  Future<void> init(BuildContext? context) async {
    if (_isInitialized) return;

    try {
      // 1. Request notification permissions (Android 13+ & iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 [FCM Permission] Authorization Status: ${settings.authorizationStatus}');

      // 2. Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 3. Retrieve device FCM token and register in Firestore
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint('🔑 [FCM Token] $token');
        await FirebaseService.instance.syncFcmToken(token);
      }

      // 4. Listen for token refresh
      _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 [FCM Token Refreshed] $newToken');
        await FirebaseService.instance.syncFcmToken(newToken);
      });

      // 5. Subscribe to core broadcast and retention topics
      await _fcm.subscribeToTopic('all_users');
      await _fcm.subscribeToTopic('daily_cutoff_reminders');
      await _fcm.subscribeToTopic('promotions');
      debugPrint('📡 [FCM] Subscribed to all_users, daily_cutoff_reminders, and promotions');

      // 6. Handle Foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('☀️ [FCM Foreground] Received: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // 7. Handle notification click when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('👆 [FCM Clicked from background]: ${message.data}');
        _handleNotificationNavigation(message.data);
      });

      // 8. Handle cold start from notification (app was terminated)
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 [FCM Cold Start]: ${initialMessage.data}');
        _handleNotificationNavigation(initialMessage.data);
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('⚠️ [NotificationService] Initialization notice: $e');
    }
  }

  /// Displays Swiggy/Zomato style in-app alert banner for foreground notifications
  void _handleForegroundMessage(RemoteMessage message) {
    final String title =
        message.notification?.title ?? message.data['title']?.toString() ?? 'Hungr Breakfast Alert';
    final String body = message.notification?.body ?? message.data['body']?.toString() ?? '';
    final String? route = message.data['route']?.toString();

    final navContext = AppRouter.router.routerDelegate.navigatorKey.currentContext;
    if (navContext == null) return;

    ScaffoldMessenger.of(navContext).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF111827),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.zomatoRed, width: 1.2),
        ),
        duration: const Duration(seconds: 5),
        content: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.zomatoRed.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🍱', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: AppTypography.bodySmall.copyWith(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (route != null && route.isNotEmpty) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.zomatoRed,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(navContext).hideCurrentSnackBar();
                  _handleNotificationNavigation({'route': route});
                },
                child: Text(
                  'VIEW',
                  style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Handles deep link navigation when user taps a push notification
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route != null && route.isNotEmpty) {
      try {
        AppRouter.router.push(route);
      } catch (e) {
        debugPrint('⚠️ [FCM Deep Link error]: $e');
      }
    }
  }

  // ==========================================
  // RETENTION STRATEGIES (SWIGGY / ZOMATO HABITS)
  // ==========================================

  /// Tracks active cart items in Cloud Firestore to enable abandoned cart recovery nudges
  Future<void> trackCartActive({
    required String userPhone,
    required Map<String, int> itemQuantities,
    required int subtotal,
  }) async {
    await FirebaseService.instance.trackAbandonedCart(
      phone: userPhone,
      items: itemQuantities,
      subtotal: subtotal,
    );
  }

  /// Clears abandoned cart record when customer successfully completes checkout
  Future<void> clearCartOnOrderSuccess(String userPhone) async {
    await FirebaseService.instance.clearAbandonedCart(userPhone);
  }
}
