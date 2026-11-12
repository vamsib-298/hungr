import 'package:flutter/services.dart';

/// Helper to format and dispatch WhatsApp Gate Drop Alerts with 1-Tap Deep Links
class WhatsAppLinkHelper {
  WhatsAppLinkHelper._();

  static const String appScheme = 'hungr';
  static const String webDomain = 'https://hungr.app';

  /// Generates deep link URL for ticket drop proof
  static String getTicketDeepLink(String ticketId) {
    return '$appScheme://ticket/$ticketId';
  }

  /// Generates deep link URL for parcel bag token
  static String getBagTokenDeepLink(String bagToken) {
    final clean = bagToken.replaceAll('#', '');
    return '$appScheme://drop/$clean';
  }

  /// Formats the official customer notification message with parcel token & drop details
  static String formatGateDropMessage({
    required String customerName,
    required String bagToken,
    required String clusterName,
    required String ticketId,
    String deliveryTime = '07:34 AM',
    String shelfDetail = 'Security Desk • Shelf #2',
  }) {
    final deepLink = getTicketDeepLink(ticketId);
    return '''🔔 *HUNGR BREAKFAST DROPPED AT GATE!* 🔔

Hi $customerName, your hot morning tiffin is ready!
🏷️ *Bag Token:* *$bagToken*
📍 *Location:* $clusterName ($shelfDetail)
⏰ *Delivered At:* $deliveryTime IST
♨️ *Heat Freshness:* Best consumed within 30 minutes!

👉 *View Drop Photo & Parcel Details:*
$deepLink

_Hungr strictly delivers to hostel gate / security reception to ensure on-time delivery by 7:30 AM._''';
  }

  /// Returns web WhatsApp URL for browser or web admin
  static String getWhatsAppWebUrl({
    String? phoneNumber,
    required String message,
  }) {
    final encoded = Uri.encodeComponent(message);
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      return 'https://wa.me/$cleanPhone?text=$encoded';
    }
    return 'https://wa.me/?text=$encoded';
  }

  /// Copies WhatsApp alert to clipboard with tactile feedback
  static Future<void> copyAlertToClipboard(String message) async {
    await Clipboard.setData(ClipboardData(text: message));
    HapticFeedback.lightImpact();
  }
}
