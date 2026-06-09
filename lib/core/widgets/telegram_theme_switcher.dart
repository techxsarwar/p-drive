import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Wraps the application to provide Telegram-style circular theme reveal animations.
class TelegramThemeSwitcher extends StatefulWidget {
  final Widget child;

  const TelegramThemeSwitcher({super.key, required this.child});

  @override
  State<TelegramThemeSwitcher> createState() => TelegramThemeSwitcherState();

  /// Finds the nearest [TelegramThemeSwitcherState] and triggers the theme change animation.
  static void changeTheme({
    required BuildContext context,
    required Offset tapPosition,
    required VoidCallback changeThemeAction,
  }) {
    final state = context.findAncestorStateOfType<TelegramThemeSwitcherState>();
    if (state != null) {
      state.triggerThemeChange(tapPosition, changeThemeAction);
    } else {
      // Fallback if not wrapped
      changeThemeAction();
    }
  }
}

class TelegramThemeSwitcherState extends State<TelegramThemeSwitcher> with SingleTickerProviderStateMixin {
  final GlobalKey _boundaryKey = GlobalKey();
  ui.Image? _oldScreenImage;
  Offset? _tapPosition;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> triggerThemeChange(Offset tapPosition, VoidCallback changeThemeAction) async {
    // 1. Capture the current screen (old theme)
    final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      changeThemeAction();
      return;
    }

    final image = await boundary.toImage(pixelRatio: View.of(context).devicePixelRatio);
    
    setState(() {
      _oldScreenImage = image;
      _tapPosition = tapPosition;
    });

    // 2. Execute the actual theme change (this rebuilds the app underneath instantly)
    changeThemeAction();

    // 3. Start the reveal animation
    _animationController.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _oldScreenImage = null;
          _tapPosition = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The actual app wrapped in a RepaintBoundary
        RepaintBoundary(
          key: _boundaryKey,
          child: widget.child,
        ),
        
        // The overlay showing the old theme being clipped away
        if (_oldScreenImage != null && _tapPosition != null)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Calculate max radius needed to cover the screen from the tap position
                final screenSize = MediaQuery.sizeOf(context);
                final dx = _tapPosition!.dx;
                final dy = _tapPosition!.dy;
                
                // Max distance from tap position to any of the 4 corners
                final maxRadius = _distance(dx, dy, screenSize.width, screenSize.height);
                
                // Use easeOutCubic curve for Telegram-like fast start, smooth finish
                final curve = Curves.easeOutCubic.transform(_animationController.value);
                final currentRadius = maxRadius * curve;

                return ClipPath(
                  clipper: _InvertedCircleClipper(
                    center: _tapPosition!,
                    radius: currentRadius,
                  ),
                  child: RawImage(
                    image: _oldScreenImage,
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  double _distance(double dx, double dy, double width, double height) {
    final d1 = (Offset(dx, dy) - const Offset(0, 0)).distance;
    final d2 = (Offset(dx, dy) - Offset(width, 0)).distance;
    final d3 = (Offset(dx, dy) - Offset(0, height)).distance;
    final d4 = (Offset(dx, dy) - Offset(width, height)).distance;
    return [d1, d2, d3, d4].reduce((a, b) => a > b ? a : b);
  }
}

/// A clipper that clips everything *except* a growing circle.
/// The circle is fully transparent (creating a hole in the overlay).
class _InvertedCircleClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _InvertedCircleClipper({required this.center, required this.radius});

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant _InvertedCircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
