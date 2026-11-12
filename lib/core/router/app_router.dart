import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../animations/smooth_transitions.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/phone_auth_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/onboarding/presentation/screens/cluster_selection_screen.dart';
import '../../features/storefront/presentation/screens/storefront_screen.dart';
import '../../features/storefront/presentation/screens/shop_details_screen.dart';
import '../../features/storefront/presentation/screens/checkout_screen.dart';
import '../../features/ticket_calendar/presentation/screens/ticket_calendar_screen.dart';
import '../../features/driver_dispatch/presentation/screens/driver_manifest_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/legal_policy_screen.dart';
import '../../features/subscription/presentation/screens/subscription_history_screen.dart';
import '../../features/subscription/presentation/screens/refer_and_earn_screen.dart';


/// GoRouter setup with custom Impeller-friendly transitions:
/// Smooth fade-through and shared-axis slide-ins
class AppRouter {
  AppRouter._();

  static CustomTransitionPage<void> _buildFadeThroughTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => _buildFadeThroughTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.phoneAuth,
        pageBuilder: (context, state) => _buildFadeThroughTransition(
          context: context,
          state: state,
          child: const PhoneAuthScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.clusterSelection,
        pageBuilder: (context, state) => _buildFadeThroughTransition(
          context: context,
          state: state,
          child: const ClusterSelectionScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.storefront,
        pageBuilder: (context, state) => _buildFadeThroughTransition(
          context: context,
          state: state,
          child: const StorefrontScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.shopDetails,
        pageBuilder: (context, state) {
          final shopId = (state.extra as String?) ?? 'shop_venkateshwara';
          return SmoothTransitions.sharedBoundsZoom(
            context: context,
            state: state,
            child: ShopDetailsScreen(shopId: shopId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.passCheckout,
        pageBuilder: (context, state) => SmoothTransitions.modalSheet(
          context: context,
          state: state,
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.ticketCalendar,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const TicketCalendarScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.deepLinkTicket,
        pageBuilder: (context, state) {
          final ticketId = state.pathParameters['id'] ?? 't_001';
          return SmoothTransitions.stackSlide(
            context: context,
            state: state,
            child: TicketCalendarScreen(highlightTicketId: ticketId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.deepLinkDrop,
        pageBuilder: (context, state) {
          final token = state.pathParameters['token'] ?? 'SS-04';
          return SmoothTransitions.stackSlide(
            context: context,
            state: state,
            child: TicketCalendarScreen(highlightToken: token),
          );
        },
      ),
      GoRoute(
        path: RouteNames.driverManifest,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const DriverManifestScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.otpVerify,
        pageBuilder: (context, state) {
          String phone = '+91 98765 43210';
          String name = 'Vamsi Krishna';
          if (state.extra is Map) {
            final map = state.extra as Map;
            phone = (map['phone'] as String?) ?? phone;
            name = (map['name'] as String?) ?? name;
          } else if (state.extra is String) {
            phone = state.extra as String;
          }
          return SmoothTransitions.stackSlide(
            context: context,
            state: state,
            child: OtpVerificationScreen(
              phoneNumber: phone,
              userName: name,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.profile,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.referral,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const ReferAndEarnScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.subscriptionHistory,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const SubscriptionHistoryScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.legalPolicy,
        pageBuilder: (context, state) => SmoothTransitions.stackSlide(
          context: context,
          state: state,
          child: const LegalPolicyScreen(),
        ),
      ),
    ],
  );
}

