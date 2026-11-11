import 'package:flutter/material.dart';

/// Layout metrics, padding, border radii, and elevation constants
class AppDimensions {
  AppDimensions._();

  // Spacing & Padding
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p6 = 6.0;
  static const double p8 = 8.0;
  static const double p10 = 10.0;
  static const double p12 = 12.0;

  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;

  // Border Radii
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double r28 = 28.0;
  static const double rCircle = 999.0;

  static const BorderRadius radius8 = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius radius12 = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius radius16 = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius radius20 = BorderRadius.all(Radius.circular(r20));
  static const BorderRadius radius24 = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius radius28 = BorderRadius.all(Radius.circular(r28));
  static const BorderRadius radiusCircle = BorderRadius.all(Radius.circular(rCircle));

  // Card Borders & Heights
  static const double cardBorderWidth = 1.0;
  static const double flipClockHeight = 84.0;
  static const double passCardHeight = 82.0;
  static const double slideToUnlockHeight = 64.0;
}
