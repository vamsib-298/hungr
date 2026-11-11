import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/theme/glassmorphism.dart';
import '../../../../core/utils/date_time_utils.dart';

/// Sticky Glassmorphic 9:00 PM Flip-Clock Header
/// Pinned at top of Storefront using SliverPersistentHeaderDelegate.
/// Digit transitions use vertical slide-and-fade AnimatedSwitcher.
/// Shifts border glow from Saffron (#FF6B00) to Urgent Crimson (#EF4444)
/// during the final 30 minutes (8:30 PM – 9:00 PM IST).
class StickyCutoffFlipClockHeader extends SliverPersistentHeaderDelegate {
  final double height;

  StickyCutoffFlipClockHeader({this.height = AppDimensions.flipClockHeight});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: const CutoffFlipClockWidget(),
    );
  }

  @override
  bool shouldRebuild(covariant StickyCutoffFlipClockHeader oldDelegate) {
    return oldDelegate.height != height;
  }
}

class CutoffFlipClockWidget extends StatefulWidget {
  const CutoffFlipClockWidget({super.key});

  @override
  State<CutoffFlipClockWidget> createState() => _CutoffFlipClockWidgetState();
}

class _CutoffFlipClockWidgetState extends State<CutoffFlipClockWidget> {
  late Timer _timer;
  Duration _remaining = Duration.zero;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    if (!mounted) return;
    setState(() {
      _remaining = DateTimeUtils.timeRemainingUntilCutoff();
      _isUrgent = DateTimeUtils.isCutoffUrgent();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    final primaryAccent = _isUrgent ? AppColors.urgentCrimson : AppColors.electricSaffron;
    final glowColor = _isUrgent ? AppColors.urgentCrimsonGlow : AppColors.saffronGlow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p16),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.p16,
          vertical: AppDimensions.p10,
        ),
        borderColor: primaryAccent.withOpacity(0.55),
        borderWidth: 1.2,
        shadows: [
          BoxShadow(
            color: glowColor,
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
        child: Row(
          children: [
            // Status Indicator & Label
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryAccent.withOpacity(0.8),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimensions.p8),
                      Flexible(
                        child: Text(
                          _isUrgent ? 'URGENT 9:00 PM LOCK' : '9:00 PM HARD CUTOFF',
                          style: AppTypography.labelSmall.copyWith(
                            color: primaryAccent,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.p4),
                  Text(
                    _isUrgent
                      ? 'Orders lock in 30 mins'
                      : 'Next batch locks at 21:00 IST',
                    style: AppTypography.bodySmall,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Live Monospace Flip-Clock Digits
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFlipUnit(hours, 'HRS', primaryAccent),
                  _buildSeparator(primaryAccent),
                  _buildFlipUnit(minutes, 'MIN', primaryAccent),
                  _buildSeparator(primaryAccent),
                  _buildFlipUnit(seconds, 'SEC', primaryAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlipUnit(String value, String label, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            final inAnimation = Tween<Offset>(
              begin: const Offset(0.0, -0.6),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

            return SlideTransition(
              position: inAnimation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: Container(
            key: ValueKey<String>(value),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.matteCharcoal,
              borderRadius: AppDimensions.radius8,
              border: Border.all(color: AppColors.charcoalBorder),
            ),
            child: Text(
              value,
              style: AppTypography.monoClockLarge.copyWith(
                color: accentColor,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(fontSize: 8, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSeparator(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: accentColor.withOpacity(0.8),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
