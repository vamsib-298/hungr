import 'dart:math' as math;
import 'package:flutter/material.dart';


/// Steaming Vector Micro-Animation
/// Renders hot rising steam wisps using continuous harmonic sine curves,
/// perfectly optimized for Impeller 60/120FPS rendering with zero dropped frames.
class SteamingVector extends StatefulWidget {
  final double width;
  final double height;
  final Color steamColor;

  const SteamingVector({
    super.key,
    this.width = 60,
    this.height = 70,
    this.steamColor = Colors.white54,
  });

  @override
  State<SteamingVector> createState() => _SteamingVectorState();
}

class _SteamingVectorState extends State<SteamingVector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SteamPainter(
            progress: _controller.value,
            steamColor: widget.steamColor,
          ),
        );
      },
    );
  }
}

class _SteamPainter extends CustomPainter {
  final double progress;
  final Color steamColor;

  _SteamPainter({required this.progress, required this.steamColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw 3 staggered rising steam ribbons
    _drawSteamWisp(canvas, size, paint, offsetX: size.width * 0.28, phase: 0.0, strokeW: 2.2);
    _drawSteamWisp(canvas, size, paint, offsetX: size.width * 0.50, phase: 0.35, strokeW: 2.8);
    _drawSteamWisp(canvas, size, paint, offsetX: size.width * 0.72, phase: 0.70, strokeW: 2.0);
  }

  void _drawSteamWisp(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double offsetX,
    required double phase,
    required double strokeW,
  }) {
    final effectiveProgress = (progress + phase) % 1.0;
    final path = Path();

    final startY = size.height * (1.0 - effectiveProgress * 0.9);
    final wispHeight = size.height * 0.45;
    final endY = math.max(0.0, startY - wispHeight);

    // Fade out as it ascends
    final alpha = ((1.0 - effectiveProgress) * 0.75).clamp(0.0, 1.0);
    paint.color = steamColor.withOpacity(alpha);
    paint.strokeWidth = strokeW;

    path.moveTo(offsetX, startY);

    final midY1 = startY - (wispHeight * 0.33);
    final midY2 = startY - (wispHeight * 0.66);

    final waveAmp = 5.0 * math.sin(effectiveProgress * 2 * math.pi);
    final controlX1 = offsetX + waveAmp;
    final controlX2 = offsetX - waveAmp;

    path.cubicTo(
      controlX1,
      midY1,
      controlX2,
      midY2,
      offsetX + (waveAmp * 0.5),
      endY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SteamPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.steamColor != steamColor;
  }
}
