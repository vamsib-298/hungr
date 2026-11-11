import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Physics particle for Confetti burst
class ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  double opacity;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    this.opacity = 1.0,
  });
}

class ConfettiBurstOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onCompleted;

  const ConfettiBurstOverlay({
    super.key,
    required this.child,
    this.onCompleted,
  });

  static ConfettiBurstOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<ConfettiBurstOverlayState>();
  }

  @override
  State<ConfettiBurstOverlay> createState() => ConfettiBurstOverlayState();
}


class ConfettiBurstOverlayState extends State<ConfettiBurstOverlay>
    with SingleTickerProviderStateMixin {
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  late AnimationController _controller;
  bool _isExploding = false;

  final List<Color> _confettiColors = [
    AppColors.electricSaffron,
    AppColors.neonMint,
    const Color(0xFFFFD700), // Gold
    const Color(0xFFFF9E00), // Amber
    Colors.white,
    AppColors.saffronLight,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(_updatePhysics)
     ..addStatusListener((status) {
       if (status == AnimationStatus.completed) {
         setState(() {
           _isExploding = false;
           _particles.clear();
         });
         widget.onCompleted?.call();
       }
     });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void burstAtCenter({int count = 65}) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final originX = size.width / 2;
    final originY = size.height * 0.65; // Erupts from bottom slider position

    _particles.clear();
    for (int i = 0; i < count; i++) {
      final angle = -math.pi / 2 + (_random.nextDouble() - 0.5) * 1.5; // Upward spray
      final speed = _random.nextDouble() * 16 + 10;
      _particles.add(
        ConfettiParticle(
          x: originX,
          y: originY,
          vx: math.cos(angle) * speed + (_random.nextDouble() - 0.5) * 4,
          vy: math.sin(angle) * speed,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
          color: _confettiColors[_random.nextInt(_confettiColors.length)],
          size: _random.nextDouble() * 8 + 6,
        ),
      );
    }

    setState(() {
      _isExploding = true;
    });
    _controller.forward(from: 0.0);
  }

  void _updatePhysics() {
    if (!_isExploding) return;
    const gravity = 0.45;
    const drag = 0.98;

    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity;
      p.vx *= drag;
      p.vy *= drag;
      p.rotation += p.rotationSpeed;
      p.opacity = (1.0 - (_controller.value * 1.1)).clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isExploding)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(particles: _particles),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0.01) continue;

      final paint = Paint()
        ..color = p.color.withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      // Draw rectangular confetti strip
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size * 0.55,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
