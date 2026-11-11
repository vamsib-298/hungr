import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Inspired by react-native-screen-transitions (eds2002):
/// High-performance, physics-driven screen transitions designed for Flutter Impeller.
/// Provides:
/// 1. Shared-element / Bounds Zoom Transition
/// 2. Modal Sheet Bottom-Up Spring Transition (e.g. Checkout / Cart)
/// 3. Predictive Card-Stack Push/Pop (Parallax + subtle scale)
/// 4. Fade-Through Shared Axis
class SmoothTransitions {
  SmoothTransitions._();

  /// 1. Modal Sheet Slide & Scale Transition (eds2002 Sheet Preset)
  /// Used for Checkout and Order Sheets where the screen slides up from the
  /// floating cart bar while the background smoothly dims.
  static CustomTransitionPage<T> modalSheet<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 340),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fast-linear to slow-ease curve for natural spring feel
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 2. Bounds Zoom & Morph Transition (eds2002 Bounds API)
  /// Used for Card -> Shop Details Screen navigation. The target screen
  /// scales up smoothly from 0.94 to 1.0 with subtle opacity cross-fade.
  static CustomTransitionPage<T> sharedBoundsZoom<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 320),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuart,
          reverseCurve: Curves.easeInQuad,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 3. Card-Stack Slide & Parallax Transition (eds2002 Stack Push)
  /// Used for Profile, Referral, Calendar, and Policy screens with smooth
  /// horizontal slide and subtle parallax depth.
  static CustomTransitionPage<T> stackSlide<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.06, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// 4. Shared Element Flight Shuttle & Arc Tween (eds2002 Bounds API)
  /// Coordinates the exact geometry morph between list card thumbnail
  /// and destination full-screen header.
  static Tween<Rect?> createArcTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  static Widget heroFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final curved = Curves.easeOutCubic.transform(animation.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(16 * (1.0 - curved)),
          child: toHeroContext.widget,
        );
      },
    );
  }
}
