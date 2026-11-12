import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/date_time_utils.dart';

/// Live Morning Drop Radar (Reverse Engineered from Swiggy / Zomato live telemetry)
/// Shows driver route proximity, stop progress, and bag token between 7:00 AM and 7:45 AM.
class LiveDropRadarCard extends StatefulWidget {
  final String clusterName;
  final String bagToken;

  const LiveDropRadarCard({
    super.key,
    required this.clusterName,
    this.bagToken = '#SS-04',
  });

  @override
  State<LiveDropRadarCard> createState() => _LiveDropRadarCardState();
}

class _LiveDropRadarCardState extends State<LiveDropRadarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppDimensions.radius16,
        border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x102563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Live Dispatch Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                // Pulsing Live Indicator
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.zomatoRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.zomatoRed.withOpacity(0.4 + 0.5 * _pulseController.value),
                            blurRadius: 6 + 4 * _pulseController.value,
                            spreadRadius: 1 + 2 * _pulseController.value,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'LIVE MORNING RADAR',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF1D4ED8),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'STOP 2 OF 4',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF1E40AF),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
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
                // Driver status headline
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('🛵', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver Ramesh is dropping at Stop 2',
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Next Stop: ${widget.clusterName} • ETA ~7 mins (07:38 AM)',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Interactive Route Progress Nodes
                Row(
                  children: [
                    _buildRouteNode(
                      title: 'Kitchen',
                      subtitle: 'Sri Venk...',
                      status: _NodeStatus.completed,
                    ),
                    _buildRouteLine(isCompleted: true),
                    _buildRouteNode(
                      title: 'Stop 2',
                      subtitle: 'Kakatiya',
                      status: _NodeStatus.current,
                    ),
                    _buildRouteLine(isCompleted: false),
                    _buildRouteNode(
                      title: 'Your Gate',
                      subtitle: 'ETA 7:38',
                      status: _NodeStatus.upcoming,
                    ),
                    _buildRouteLine(isCompleted: false),
                    _buildRouteNode(
                      title: 'Stop 4',
                      subtitle: 'Bypass',
                      status: _NodeStatus.upcoming,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Parcel Bag Token & Gate Drop Notification Note
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          widget.bagToken,
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF1D4ED8),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Security Desk Drop Only • Guard will hold your bag until 08:30 AM',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteNode({
    required String title,
    required String subtitle,
    required _NodeStatus status,
  }) {
    Color iconColor;
    Color bgColor;
    IconData icon;

    switch (status) {
      case _NodeStatus.completed:
        iconColor = AppColors.neonMint;
        bgColor = const Color(0xFFECFDF5);
        icon = Icons.check_circle_rounded;
        break;
      case _NodeStatus.current:
        iconColor = AppColors.zomatoRed;
        bgColor = const Color(0xFFFEE2E2);
        icon = Icons.two_wheeler_rounded;
        break;
      case _NodeStatus.upcoming:
        iconColor = const Color(0xFF9CA3AF);
        bgColor = const Color(0xFFF3F4F6);
        icon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: iconColor.withOpacity(0.6), width: 1.2),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            fontWeight: status == _NodeStatus.current ? FontWeight.w800 : FontWeight.w600,
            fontSize: 9.5,
            color: status == _NodeStatus.current ? AppColors.zomatoRed : AppColors.textPrimary,
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.caption.copyWith(
            fontSize: 8,
            color: AppColors.textSubtle,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteLine({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isCompleted ? AppColors.neonMint : const Color(0xFFE5E7EB),
      ),
    );
  }
}

enum _NodeStatus {
  completed,
  current,
  upcoming,
}
