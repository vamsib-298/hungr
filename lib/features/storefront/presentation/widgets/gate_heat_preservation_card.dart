import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/whatsapp_link_helper.dart';

/// 30-Minute Gate Heat Preservation Countdown Card (Reverse-Engineered Cold-Food Protection)
/// Activates when a breakfast meal is confirmed dropped at the gate security desk.
/// Displays live temperature degradation, heat-fresh timer, and a 1-tap "Snooze & Remind in 5 Mins"
/// to ensure sleeping students pick up their woodfire tiffins before cooling.
class GateHeatPreservationCard extends StatefulWidget {
  final String bagToken;
  final String clusterName;
  final String gateLocationDetail;
  final DateTime droppedAt;
  final String? proofPhotoUrl;
  final VoidCallback? onViewProof;

  const GateHeatPreservationCard({
    super.key,
    required this.bagToken,
    required this.clusterName,
    this.gateLocationDetail = 'Security Desk • Shelf #2',
    required this.droppedAt,
    this.proofPhotoUrl,
    this.onViewProof,
  });

  @override
  State<GateHeatPreservationCard> createState() => _GateHeatPreservationCardState();
}

class _GateHeatPreservationCardState extends State<GateHeatPreservationCard>
    with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _remaining;
  late AnimationController _steamController;
  bool _isSnoozed = false;
  int _snoozeMinutesLeft = 0;
  Timer? _snoozeTimer;

  static const int totalPreservationMinutes = 30;

  @override
  void initState() {
    super.initState();
    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _calculateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateRemaining());
  }

  void _calculateRemaining() {
    final now = DateTime.now();
    final expiration = widget.droppedAt.add(const Duration(minutes: totalPreservationMinutes));
    final diff = expiration.difference(now);

    if (mounted) {
      setState(() {
        _remaining = diff.isNegative ? Duration.zero : diff;
      });
    }
  }

  void _handleSnooze() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isSnoozed = true;
      _snoozeMinutesLeft = 5;
    });

    _snoozeTimer?.cancel();
    _snoozeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_snoozeMinutesLeft > 1) {
          _snoozeMinutesLeft--;
        } else {
          _isSnoozed = false;
          timer.cancel();
          HapticFeedback.heavyImpact();
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E40AF),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.alarm_on_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Alarm Snoozed! We will buzz your phone in 5 mins before Bag ${widget.bagToken} cools down.',
                style: AppTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _snoozeTimer?.cancel();
    _steamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = _remaining.inSeconds;
    final minutes = (_remaining.inMinutes).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    // Dynamic Heat Degradation Stages
    final bool isPipingHot = totalSeconds > 20 * 60; // 30-20 min
    final bool isWarm = totalSeconds <= 20 * 60 && totalSeconds > 10 * 60; // 20-10 min
    final bool isCooling = totalSeconds <= 10 * 60 && totalSeconds > 0; // 10-0 min
    final bool isCooled = totalSeconds == 0;

    Color stageColor;
    Color stageBg;
    String stageHeadline;
    String stageSub;
    IconData stageIcon;

    if (isPipingHot) {
      stageColor = const Color(0xFF16A34A); // Emerald green
      stageBg = const Color(0xFFECFDF5);
      stageHeadline = 'PIPING HOT • 72°C WOODFIRE FRESH';
      stageSub = 'Steaming hot breakfast just placed on security desk';
      stageIcon = Icons.whatshot_rounded;
    } else if (isWarm) {
      stageColor = const Color(0xFFD97706); // Amber
      stageBg = const Color(0xFFFFFBEB);
      stageHeadline = 'WARM & FRESH • 55°C';
      stageSub = 'Best enjoyed right now. Head down to the gate';
      stageIcon = Icons.soup_kitchen_rounded;
    } else if (isCooling) {
      stageColor = AppColors.urgentCrimson; // Crimson
      stageBg = const Color(0xFFFEF2F2);
      stageHeadline = 'RAPIDLY COOLING DOWN • 40°C';
      stageSub = 'Collect immediately from security desk to enjoy hot';
      stageIcon = Icons.warning_amber_rounded;
    } else {
      stageColor = const Color(0xFF4B5563); // Muted slate
      stageBg = const Color(0xFFF3F4F6);
      stageHeadline = 'COOLED DOWN • ROOM TEMPERATURE';
      stageSub = 'Meal waiting at security desk. Reheat recommended';
      stageIcon = Icons.ac_unit_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: stageColor.withOpacity(0.55), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: stageColor.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppDimensions.radius16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Header with Steam Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: stageBg,
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _steamController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -2 * _steamController.value),
                        child: Icon(stageIcon, color: stageColor, size: 18),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stageHeadline,
                      style: AppTypography.monoBadge.copyWith(
                        color: stageColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: stageColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GATE DROP',
                      style: AppTypography.caption.copyWith(
                        color: stageColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Parcel Bag Token Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'BAG TOKEN',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFF1D4ED8),
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.bagToken,
                              style: AppTypography.monoBadge.copyWith(
                                color: const Color(0xFF1E40AF),
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Location & Pickup Instruction
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.clusterName,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Waiting at: ${widget.gateLocationDetail}',
                              style: AppTypography.bodySmall.copyWith(
                                color: const Color(0xFF1E40AF),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              stageSub,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Countdown Timer & Heat Progress Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(
                                  'Heat Freshness Window:',
                                  style: AppTypography.caption.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$minutes:$seconds',
                              style: AppTypography.monoClockLarge.copyWith(
                                color: stageColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalSeconds / (totalPreservationMinutes * 60),
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(stageColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Buttons: Snooze Alert + View Drop Photo + WhatsApp Share
                  Row(
                    children: [
                      // Snooze Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSnoozed ? null : _handleSnooze,
                          icon: Icon(
                            _isSnoozed ? Icons.alarm_on_rounded : Icons.snooze_rounded,
                            size: 16,
                            color: _isSnoozed ? const Color(0xFF16A34A) : AppColors.textPrimary,
                          ),
                          label: Text(
                            _isSnoozed ? 'Snoozed (${_snoozeMinutesLeft}m)' : 'Snooze 5 Mins',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _isSnoozed ? const Color(0xFF16A34A) : AppColors.textPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isSnoozed ? const Color(0xFF86EFAC) : AppColors.charcoalBorder,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // View Drop Proof Photo Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            if (widget.onViewProof != null) {
                              widget.onViewProof!();
                            } else {
                              _showDropProofModal(context);
                            }
                          },
                          icon: const Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                          label: Text(
                            'Gate Proof Photo',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.zomatoRed,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDropProofModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.neonMint, size: 22),
            const SizedBox(width: 8),
            Text('Security Desk Drop Proof', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF3F4F6),
                image: const DecorationImage(
                  image: AssetImage('assets/images/gate_drop_sample.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Bag Token: ${widget.bagToken} • 07:34 AM',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Driver marked delivered at ${widget.clusterName}. Security Guard was handed the parcel.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '⚠️ Reminder: Hungr drops at security desk/gate only to keep deliveries strictly on-time by 7:30 AM.',
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF1E40AF),
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
