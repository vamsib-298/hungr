import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../../../auth/presentation/viewmodels/auth_viewmodel.dart';
import '../../../storefront/presentation/viewmodels/customer_dashboard_viewmodel.dart';
import '../../../subscription/presentation/viewmodels/subscription_history_viewmodel.dart';
import '../../../subscription/presentation/viewmodels/referral_viewmodel.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _deliveryPingEnabled = true;
  String _dietaryPref = 'Vegetarian (Pure)';

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius20,
            side: BorderSide(color: AppColors.charcoalBorder, width: 1.0),
          ),
          title: Text('Sign Out?', style: AppTypography.headlineMedium),
          content: Text(
            'Are you sure you want to sign out? You will need to verify your phone number with OTP to log back in.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentCrimson,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
                ref.read(authProvider.notifier).logout();
                context.go(RouteNames.phoneAuth);
              },
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: AppDimensions.radius20,
            side: BorderSide(color: AppColors.urgentCrimson, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.delete_forever, color: AppColors.urgentCrimson, size: 28),
              const SizedBox(width: 8),
              Text('Delete Account', style: AppTypography.headlineMedium),
            ],
          ),
          content: Text(
            'Under DPDP Act & Google Play policy, this will permanently delete your phone number, pass history, and delivery records. This action cannot be undone.',
            style: AppTypography.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentCrimson,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                HapticFeedback.heavyImpact();
                ref.read(authProvider.notifier).logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.urgentCrimson,
                    content: Text(
                      'Account & personal data deleted successfully.',
                      style: AppTypography.labelLarge,
                    ),
                  ),
                );
                context.go(RouteNames.phoneAuth);
              },
              child: const Text('Delete Permanently'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final historyState = ref.watch(subscriptionHistoryProvider);
    final dashboardState = ref.watch(customerDashboardProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(RouteNames.storefront);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.obsidianBackground,
        appBar: AppBar(
          title: Text(
            'Account & Settings',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 18),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(RouteNames.storefront);
              }
            },
          ),
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            ObsidianCard(
              borderColor: AppColors.zomatoRed.withOpacity(0.4),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.zomatoRedSurface,
                    child: Text(
                      authState.userName.isNotEmpty ? authState.userName[0].toUpperCase() : 'V',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.zomatoRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.p16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authState.userName, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(authState.phoneNumber, style: AppTypography.bodySmall),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppColors.neonMint, size: 14),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonMint.withOpacity(0.15),
                            borderRadius: AppDimensions.radius8,
                          ),
                          child: Text(
                            'STUDENT / RESIDENT VERIFIED',
                            style: AppTypography.monoBadge.copyWith(color: AppColors.neonMint, fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.p16),

            // Active Subscription Quick Banner
            if (dashboardState.hasActivePass)
              ObsidianCard(
                borderColor: AppColors.electricSaffron.withOpacity(0.4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.electricSaffron.withOpacity(0.15),
                        borderRadius: AppDimensions.radius12,
                      ),
                      child: const Icon(Icons.confirmation_number_outlined, color: AppColors.electricSaffron, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Pass', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '${dashboardState.mealsRemaining} of ${dashboardState.totalMeals} meals remaining',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedSlate),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.ticketCalendar),
                      child: const Text('Schedule'),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppDimensions.p20),

            // Subscriptions & Gate Section
            Text('Subscriptions & Delivery', style: AppTypography.titleLarge),
            const SizedBox(height: 8),

            ObsidianCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_rounded, color: AppColors.goldenAmber),
                    title: Text('Refer & Earn Free 3-Day Pass', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text('Invite 3 friends to order & eat free for 3 days (${ref.watch(referralProvider).qualifiedOrderCount}/3 ordered)', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () => context.push(RouteNames.referral),
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.electricSaffron),
                    title: Text('Subscription & Order History', style: AppTypography.titleMedium),
                    subtitle: Text('${historyState.orders.length} passes recorded', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () => context.push(RouteNames.subscriptionHistory),
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.zomatoRed),
                    title: Text('Delivery Drop Point', style: AppTypography.titleMedium),
                    subtitle: Text(dashboardState.selectedCluster.name, style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () => context.push(RouteNames.clusterSelection),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.p20),

            // Preferences
            Text('Preferences', style: AppTypography.titleLarge),
            const SizedBox(height: 8),

            ObsidianCard(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.textCrispWhite),
                    title: Text('WhatsApp 7:00 AM Delivery Ping', style: AppTypography.titleMedium),
                    subtitle: Text('Instant dispatch alert when driver arrives at your gate', style: AppTypography.bodySmall),
                    value: _deliveryPingEnabled,
                    activeColor: AppColors.zomatoRed,
                    onChanged: (val) {
                      setState(() => _deliveryPingEnabled = val);
                      HapticFeedback.selectionClick();
                    },
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.restaurant_menu_outlined, color: AppColors.textCrispWhite),
                    title: Text('Dietary Preference', style: AppTypography.titleMedium),
                    subtitle: Text(_dietaryPref, style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () {
                      setState(() {
                        _dietaryPref = _dietaryPref.contains('Vegetarian')
                            ? 'All Items (Eggs & Veg)'
                            : 'Vegetarian (Pure)';
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.p20),

            // Support & Legal
            Text('Support & Legal', style: AppTypography.titleLarge),
            const SizedBox(height: 8),

            ObsidianCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                    title: Text('WhatsApp Customer Concierge', style: AppTypography.titleMedium),
                    subtitle: Text('Instant help via +91 98765 43210', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF25D366)),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF25D366),
                          content: Text(
                            'Connecting to Hungr WhatsApp Concierge (+91 98765 43210)...',
                            style: AppTypography.labelLarge,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.delivery_dining_outlined, color: AppColors.neonMint),
                    title: Text('Driver Dispatch Portal', style: AppTypography.titleMedium),
                    subtitle: Text('Cluster gate manifest & photo drop', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () => context.push(RouteNames.driverManifest),
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.gavel_outlined, color: AppColors.textPrimary),
                    title: Text('Terms & Privacy Policy', style: AppTypography.titleMedium),
                    subtitle: Text('DPDP Act, 9:00 PM cutoff, Gate drop SOP', style: AppTypography.bodySmall),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSubtle),
                    onTap: () => context.push(RouteNames.legalPolicy),
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.textPrimary),
                    title: Text('Sign Out', style: AppTypography.titleMedium),
                    subtitle: Text('Switch phone number or account', style: AppTypography.bodySmall),
                    onTap: () => _showSignOutDialog(context),
                  ),
                  const Divider(color: AppColors.surfaceHighlight),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.urgentCrimson),
                    title: Text('Delete Account', style: AppTypography.titleMedium.copyWith(color: AppColors.urgentCrimson)),
                    subtitle: Text('Permanent account and data erasure', style: AppTypography.bodySmall),
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Brand Footer
            Center(
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/app_icon_512.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'HUNGR v1.0.7 (Build 8)',
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.textSubtle,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crafted for Khammam • Hyper-Batched Morning Tiffin',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSubtle.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}
}
