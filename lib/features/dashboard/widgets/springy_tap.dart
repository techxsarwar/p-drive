import 'package:flutter/material.dart';

class SpringyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const SpringyTap({
    super.key,
    required this.child,
    required this.onTap,
  });

  @override
  State<SpringyTap> createState() => _SpringyTapState();
}

class _SpringyTapState extends State<SpringyTap> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        reverseCurve: const Cubic(0.34, 1.56, 0.64, 1),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
