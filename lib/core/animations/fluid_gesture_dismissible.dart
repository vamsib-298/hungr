import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Inspired by react-native-screen-transitions (eds2002):
/// Gesture-driven interactive dismiss wrapper with 1:1 finger tracking,
/// dynamic scale-down (1.0 -> 0.92), corner radius expansion (0 -> 28dp),
/// and physics-based spring damping.
class FluidGestureDismissible extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismiss;
  final bool enableDrag;

  const FluidGestureDismissible({
    super.key,
    required this.child,
    this.onDismiss,
    this.enableDrag = true,
  });

  @override
  State<FluidGestureDismissible> createState() => _FluidGestureDismissibleState();
}

class _FluidGestureDismissibleState extends State<FluidGestureDismissible>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  late Animation<double> _dragAnimation;

  double _dragOffset = 0.0;
  static const double _dismissThreshold = 130.0;
  static const double _velocityThreshold = 700.0;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _springController.addListener(() {
      setState(() {
        _dragOffset = _dragAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!widget.enableDrag) return;
    // Only handle downward drag
    if (details.primaryDelta != null && details.primaryDelta! > 0 || _dragOffset > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.primaryDelta!).clamp(0.0, 350.0);
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!widget.enableDrag) return;
    final velocity = details.primaryVelocity ?? 0.0;

    if (_dragOffset > _dismissThreshold || velocity > _velocityThreshold) {
      // Dismiss
      HapticFeedback.lightImpact();
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      } else {
        Navigator.of(context).maybePop();
      }
    } else {
      // Snap back with spring
      _dragAnimation = Tween<double>(
        begin: _dragOffset,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _springController,
          curve: Curves.easeOutBack,
        ),
      );
      _springController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragOffset / 250.0).clamp(0.0, 1.0);
    final scale = 1.0 - (progress * 0.08); // 1.0 -> 0.92
    final radius = progress * 28.0;       // 0 -> 28dp
    final opacity = 1.0 - (progress * 0.35); // 1.0 -> 0.65

    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: Opacity(
            opacity: opacity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
