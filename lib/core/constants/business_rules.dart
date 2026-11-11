/// Core Business Rules & Operational Thresholds for Hungr
/// Governs kitchen capacity, 21:00 cutoff lock, pass ceilings, and pricing.
class BusinessRules {
  BusinessRules._();

  // Kitchen & Capacity
  static const int totalDailyCapacity = 100;
  static const int aunty1Capacity = 50; // Kitchen Unit 1
  static const int aunty2Capacity = 50; // Kitchen Unit 2

  // Cutoff Timings (IST)
  static const int cutoffHour = 21; // 9:00 PM
  static const int cutoffMinute = 0;
  static const int warningThresholdMinutes = 30; // 8:30 PM begins Crimson state
  static const int kitchenSplitMinute = 1; // 21:01 IST Kitchen assignment trigger

  // Delivery Window (Morning Tiffin)
  static const String deliveryWindow = '07:30 AM – 08:30 AM';
  static const String kitchenPrepStartTime = '06:30 AM';
  static const String consumptionNoticeWindow = 'Consume within 90 minutes';

  // Pass Tiers Specifications
  // 3-Day Trial Pass
  static const String pass3DayId = 'pass_3_day';
  static const String pass3DayTitle = '3-Day Trial Pass';
  static const int pass3DayMeals = 3;
  static const int pass3DayPrice = 165;
  static const int pass3DayEffectivePricePerMeal = 55;
  static const int pass3DayExpiryDays = 5; // Hard expiry ceiling: 5 days

  // 7-Day Routine Pass
  static const String pass7DayId = 'pass_7_day';
  static const String pass7DayTitle = '7-Day Routine Pass';
  static const int pass7DayMeals = 7;
  static const int pass7DayPrice = 350;
  static const int pass7DayEffectivePricePerMeal = 50;
  static const int pass7DayExpiryDays = 10; // Hard expiry ceiling: 10 days

  // 15-Day Power Pass
  static const String pass15DayId = 'pass_15_day';
  static const String pass15DayTitle = '15-Day Power Pass';
  static const int pass15DayMeals = 15;
  static const int pass15DayPrice = 720;
  static const int pass15DayEffectivePricePerMeal = 48;
  static const int pass15DayExpiryDays = 20; // Hard expiry ceiling: 20 days

  // High-Margin Morning Add-ons ('Country Delight' play)
  static const String addonBoiledEggsId = 'addon_boiled_eggs';
  static const String addonBoiledEggsTitle = 'Boiled Eggs (2 Pack)';
  static const int addonBoiledEggsPrice = 20;
  static const int addonBoiledEggsCost = 11;

  static const String addonFilterCoffeeId = 'addon_filter_coffee';
  static const String addonFilterCoffeeTitle = 'Filter Coffee Flask Pouch';
  static const int addonFilterCoffeePrice = 25;
  static const int addonFilterCoffeeCost = 12;

  static const String addonBadamMilkId = 'addon_badam_milk';
  static const String addonBadamMilkTitle = 'Hot Badam Milk Flask Pouch';
  static const int addonBadamMilkPrice = 25;
  static const int addonBadamMilkCost = 12;

  // Packaging SOP Spec
  static const double innerWrapCost = 0.60; // Perforated Butter Paper
  static const double outerCoverCost = 1.00; // Silver Foil Pouch
  static const double pouchChutneySambarCost = 0.60; // 2 Heat-sealed LDPE pouches
  static const double targetTotalPackagingCost = 2.20; // Sub-₹2.20 per packet
}
