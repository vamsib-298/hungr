import '../constants/business_rules.dart';

/// IST (UTC+5:30) Date and Time Utilities for 9:00 PM Cutoff & Lifecycle Tracking
class DateTimeUtils {
  DateTimeUtils._();

  /// Returns current Indian Standard Time (UTC+5:30)
  static DateTime nowIst() {
    return DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  }

  /// Calculates the next 9:00 PM IST cutoff timestamp
  static DateTime nextCutoffIst() {
    final now = nowIst();
    var cutoffToday = DateTime.utc(
      now.year,
      now.month,
      now.day,
      BusinessRules.cutoffHour, // 21
      BusinessRules.cutoffMinute, // 0
    );

    if (now.isAfter(cutoffToday)) {
      // If past 9:00 PM today, next cutoff is 9:00 PM tomorrow
      cutoffToday = cutoffToday.add(const Duration(days: 1));
    }
    return cutoffToday;
  }

  /// Returns duration remaining until the upcoming 9:00 PM IST cutoff
  static Duration timeRemainingUntilCutoff() {
    final now = nowIst();
    final cutoff = nextCutoffIst();
    final diff = cutoff.difference(now);
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Checks if current time is in the final 30 minutes before 9:00 PM (8:30 PM - 9:00 PM IST)
  static bool isCutoffUrgent() {
    final remaining = timeRemainingUntilCutoff();
    return remaining.inMinutes <= BusinessRules.warningThresholdMinutes &&
        remaining > Duration.zero;
  }

  /// Verifies if a meal ticket for tomorrow can still be skipped or modified
  /// Server/Client gate: hard lock at 21:00:00 IST
  static bool canModifyTomorrowMeal() {
    final now = nowIst();
    final cutoffToday = DateTime.utc(
      now.year,
      now.month,
      now.day,
      BusinessRules.cutoffHour,
      BusinessRules.cutoffMinute,
    );
    return now.isBefore(cutoffToday);
  }

  /// Whether current time is past 9:00 PM today (tomorrow's batch is locked for woodfire prep)
  static bool isAfterCutoffToday() {
    return !canModifyTomorrowMeal();
  }

  /// Calculates the next guaranteed delivery date:
  /// - Before 9:00 PM IST: Tomorrow Morning
  /// - After 9:00 PM IST: Next-to-Next Day Morning (Day + 2)
  static DateTime targetDeliveryDate() {
    final now = nowIst();
    if (isAfterCutoffToday()) {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    } else {
      return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    }
  }

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Human-readable target delivery day label
  static String targetDeliveryLabel() {
    final target = targetDeliveryDate();
    final now = nowIst();
    final tomorrow = now.add(const Duration(days: 1));
    final dayStr = _dayNames[target.weekday - 1];
    final monthStr = _monthNames[target.month - 1];

    if (target.day == tomorrow.day && target.month == tomorrow.month) {
      return 'Tomorrow Morning ($dayStr, ${target.day} $monthStr)';
    } else {
      return '$dayStr Morning (${target.day} $monthStr)';
    }
  }

  /// Generates a deterministic 4-character parcel bag token (#SS-04)
  /// Used by security guards and hostel students to identify bags instantly.
  static String generateBagToken(String clusterName, [int seed = 4]) {
    final words = clusterName.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    String prefix = 'TS';
    if (words.length >= 2) {
      prefix = '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty && words[0].length >= 2) {
      prefix = words[0].substring(0, 2).toUpperCase();
    }
    final numStr = (seed % 99 + 1).toString().padLeft(2, '0');
    return '#$prefix-$numStr';
  }
}
