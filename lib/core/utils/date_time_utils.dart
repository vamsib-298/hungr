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
}
