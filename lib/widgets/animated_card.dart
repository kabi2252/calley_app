import 'package:flutter/material.dart';

/// A reusable card widget that fades and slides in with a configurable delay
/// for staggered animation effects.
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.elevation = 2.0,
    this.margin,
    this.padding,
    this.borderRadius,
    this.color,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Stagger start based on index
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          elevation: widget.elevation,
          margin: widget.margin ?? const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          color: widget.color,
          shape: RoundedRectangleBorder(
            borderRadius: widget.borderRadius ??
                BorderRadius.circular(16),
          ),
          child: widget.padding != null
              ? Padding(
                  padding: widget.padding!,
                  child: widget.child,
                )
              : widget.child,
        ),
      ),
    );
  }
}
