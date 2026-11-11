import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';

class LegalPolicyScreen extends StatelessWidget {
  const LegalPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Legal Terms & Privacy',
            style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
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
            Text('Terms of Service', style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Governing hyper-batched morning tiffin subscriptions in Khammam clusters.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimensions.p16),

            _buildClauseCard(
              title: '1. 9:00 PM Hard Cutoff Rule',
              content:
                  'All order modifications, combo switches, and skips close strictly at 21:00:00 IST the night prior. '
                  'Unskipped meals are automatically locked, assigned to kitchen units, and deducted from your active pass balance.',
            ),
            const SizedBox(height: AppDimensions.p12),

            _buildClauseCard(
              title: '2. Pass Validity & Non-Refundability',
              content:
                  'Subscription passes (3-Day, 7-Day, 15-Day) are non-refundable to bank or UPI accounts. '
                  'Skipped meals extend your delivery schedule up to the hard expiry ceiling (5, 10, or 20 calendar days). '
                  'Unused tickets past the ceiling are forfeited.',
            ),
            const SizedBox(height: AppDimensions.p12),

            _buildClauseCard(
              title: '3. Gate Drop & Transfer of Risk',
              content:
                  'Deliveries are executed between 07:30 AM and 08:30 AM at your registered cluster drop point (hostel gate or watchman desk). '
                  'Photo upload by our route driver constitutes conclusive proof of delivery. '
                  'Hungr is not responsible for lost packages left unattended past the 2-minute gate drop.',
            ),
            const SizedBox(height: AppDimensions.p12),

            _buildClauseCard(
              title: '4. Allergy & Consumption Notice',
              content:
                  'Food items are packaged in food-grade breathable covers and may contain nuts (groundnut chutney), peanuts, gluten, and dairy. '
                  'Tiffins must be consumed within 90 minutes of delivery.',
            ),

            const SizedBox(height: AppDimensions.p24),
            Text('Privacy Policy (DPDP Act)', style: AppTypography.displayMedium),
            const SizedBox(height: 8),
            Text(
              'In full compliance with India’s Digital Personal Data Protection (DPDP) Act and Google Play Store policies.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppDimensions.p16),

            _buildClauseCard(
              title: 'Data Collection Scope',
              content:
                  'Hungr collects only minimal essential data: your Name, Phone Number, and Delivery Cluster Gate. '
                  'We do not track continuous GPS location or require exact apartment door numbers.',
            ),
            const SizedBox(height: AppDimensions.p12),

            _buildClauseCard(
              title: 'Payment Data Handling',
              content:
                  'Payments are processed via RBI-compliant UPI intent gateways (Razorpay). '
                  'Hungr never stores, views, or logs bank account, UPI PIN, or credit/debit card information.',
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildClauseCard({required String title, required String content}) {
    return ObsidianCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.electricSaffron)),
          const SizedBox(height: 6),
          Text(content, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
