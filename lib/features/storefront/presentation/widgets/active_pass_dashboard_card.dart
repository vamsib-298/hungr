import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/obsidian_card.dart';
import '../viewmodels/customer_dashboard_viewmodel.dart';

class ActivePassDashboardCard extends ConsumerWidget {
  const ActivePassDashboardCard({super.key});

  void _showSwitchComboSheet(BuildContext context, WidgetRef ref, String currentCombo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.matteCharcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.r24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Switch Tomorrow’s Meal', style: AppTypography.headlineMedium),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textCrispWhite),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Changes permitted until 9:00 PM tonight • Zero penalty',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppDimensions.p16),

              // Combo A Option
              ObsidianCard(
                borderColor: currentCombo == 'A' ? AppColors.zomatoRed : AppColors.charcoalBorder,
                borderWidth: currentCombo == 'A' ? 1.8 : 1.0,
                backgroundColor: currentCombo == 'A' ? AppColors.zomatoRedSurface : Colors.white,
                onTap: () {
                  ref.read(customerDashboardProvider.notifier).switchTomorrowCombo('A');
                  Navigator.of(context).pop();
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.zomatoRed,
                      content: Text('Switched to Combo A (Set Dosa)!', style: AppTypography.labelLarge),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.breakfast_dining, color: AppColors.zomatoRed, size: 28),
                    const SizedBox(width: AppDimensions.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Option A: 2 Hot Set Dosas', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Groundnut & Allam Chutney + Hot Sambar', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    if (currentCombo == 'A')
                      const Icon(Icons.check_circle, color: AppColors.zomatoRed, size: 22),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.p12),

              // Combo B Option
              ObsidianCard(
                borderColor: currentCombo == 'B' ? AppColors.zomatoRed : AppColors.charcoalBorder,
                borderWidth: currentCombo == 'B' ? 1.8 : 1.0,
                backgroundColor: currentCombo == 'B' ? AppColors.zomatoRedSurface : Colors.white,
                onTap: () {
                  ref.read(customerDashboardProvider.notifier).switchTomorrowCombo('B');
                  Navigator.of(context).pop();
                  HapticFeedback.mediumImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.zomatoRed,
                      content: Text('Switched to Combo B (Idli/Vada)!', style: AppTypography.labelLarge),
                    ),
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.dinner_dining, color: AppColors.zomatoRed, size: 28),
                    const SizedBox(width: AppDimensions.p12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Option B: 4 Steamed Idlis + 1 Vada', style: AppTypography.titleMedium),
                          const SizedBox(height: 2),
                          Text('Coconut Chutney + Piping Drumstick Sambar', style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    if (currentCombo == 'B')
                      const Icon(Icons.check_circle, color: AppColors.zomatoRed, size: 22),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.p20),
            ],
          ),
        );
      },
    );
  }

  void _confirmSkipTomorrow(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.event_busy, color: AppColors.urgentCrimson, size: 26),
              const SizedBox(width: 8),
              Text('Skip Tomorrow?', style: AppTypography.headlineMedium.copyWith(color: AppColors.textPrimary)),
            ],
          ),
          content: Text(
            'Your breakfast for tomorrow will be paused.\n\n'
            'Your unused meal ticket moves to the end of your subscription schedule. No meal or money wasted.',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Keep Tomorrow', style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.urgentCrimson,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                final success = ref.read(customerDashboardProvider.notifier).skipTomorrow();
                HapticFeedback.heavyImpact();

                ScaffoldMessenger.of(context).clearSnackBars();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 2200),
                      behavior: SnackBarBehavior.floating,
                      dismissDirection: DismissDirection.horizontal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                      backgroundColor: const Color(0xFF1F2937),
                      content: Text(
                        'Tomorrow Skipped! Replacement ticket added to next week.',
                        style: AppTypography.labelLarge.copyWith(color: Colors.white),
                      ),
                      action: SnackBarAction(
                        label: 'View',
                        textColor: AppColors.zomatoRedLight,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          context.push(RouteNames.ticketCalendar);
                        },
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      backgroundColor: AppColors.urgentCrimson,
                      content: Text('Cannot skip: 9:00 PM cutoff has passed.', style: AppTypography.labelLarge.copyWith(color: Colors.white)),
                    ),
                  );
                }
              },
              child: const Text('Confirm Skip'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerDashboardProvider);
    final isComboA = state.tomorrowCombo == 'A';

    final comboTitle = isComboA ? '2 Hot Set Dosas (Option A)' : '4 Idlis + 1 Medu Vada (Option B)';

    final progressRatio = state.totalMeals > 0 ? (state.mealsRemaining / state.totalMeals) : 0.0;

    return ObsidianCard(
      borderColor: AppColors.zomatoRed.withOpacity(0.35),
      borderWidth: 1.2,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF1F2),
          Colors.white,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.neonMint,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.neonMint, blurRadius: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TOMORROW 07:30 AM',
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.neonMint,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${state.mealsRemaining}/${state.totalMeals} MEALS LEFT',
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.electricSaffron,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => context.push(RouteNames.ticketCalendar),
                    child: Text(
                      'Schedule ➔',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.zomatoRedLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Food & Actions Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.zomatoRedSurface,
                  borderRadius: AppDimensions.radius8,
                  border: Border.all(color: AppColors.zomatoRed.withOpacity(0.4)),
                ),
                child: Icon(
                  isComboA ? Icons.breakfast_dining : Icons.dinner_dining,
                  color: AppColors.zomatoRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comboTitle,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Gate Drop • ${state.selectedCluster.name}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMutedSlate,
                        fontSize: 10.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Compact Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showSwitchComboSheet(context, ref, state.tomorrowCombo),
                    borderRadius: AppDimensions.radius8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: AppDimensions.radius8,
                        border: Border.all(color: AppColors.charcoalBorder),
                      ),
                      child: Text(
                        'Switch',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textCrispWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _confirmSkipTomorrow(context, ref),
                    borderRadius: AppDimensions.radius8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.urgentCrimsonSurface,
                        borderRadius: AppDimensions.radius8,
                        border: Border.all(color: AppColors.urgentCrimson.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Pause',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.urgentCrimson,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Slim Progress Indicator
          ClipRRect(
            borderRadius: AppDimensions.radiusCircle,
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 2.5,
              backgroundColor: AppColors.surfaceHighlight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonMint),
            ),
          ),
        ],
      ),
    );
  }
}
