import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimatedScrollItem extends StatefulWidget {
  final Widget child;
  final int delay; // délai en ms
  final AnimationType type;

  const AnimatedScrollItem({
    super.key,
    required this.child,
    this.delay = 0,
    this.type = AnimationType.fadeSlideUp,
  });

  @override
  State<AnimatedScrollItem> createState() => _AnimatedScrollItemState();
}

enum AnimationType { fadeSlideUp, fadeSlideLeft, fadeSlideRight, fadeScale }

class _AnimatedScrollItemState extends State<AnimatedScrollItem>
    with SingleTickerProviderStateMixin {
  static int _nextId = 0;

  late final Key _visibilityKey;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _visibilityKey = Key('animated-scroll-item-${_nextId++}');
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _scale = Tween<double>(
      begin: 0.85,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    switch (widget.type) {
      case AnimationType.fadeSlideUp:
        _slide = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
        break;
      case AnimationType.fadeSlideLeft:
        _slide = Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
        break;
      case AnimationType.fadeSlideRight:
        _slide = Tween<Offset>(
          begin: const Offset(-0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
        break;
      case AnimationType.fadeScale:
        _slide = Tween<Offset>(
          begin: Offset.zero,
          end: Offset.zero,
        ).animate(_ctrl);
        break;
    }

    // Déclencher avec délai
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted && _visible) {
        _ctrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: _visibilityKey,
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_visible) {
          setState(() => _visible = true);
          Future.delayed(Duration(milliseconds: widget.delay), () {
            if (mounted) _ctrl.forward();
          });
        }
      },
      child: FadeTransition(
        opacity: _fade,
        child: widget.type == AnimationType.fadeScale
            ? ScaleTransition(scale: _scale, child: widget.child)
            : SlideTransition(position: _slide, child: widget.child),
      ),
    );
  }
}
