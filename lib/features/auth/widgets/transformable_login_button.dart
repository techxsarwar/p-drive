import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TransformableButtonState { idle, loading, success }

class TransformableLoginButton extends StatefulWidget {
  final String buttonText;
  final TransformableButtonState state;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? color;

  const TransformableLoginButton({
    super.key,
    required this.buttonText,
    required this.state,
    this.onPressed,
    this.backgroundColor,
    this.color,
  });

  @override
  State<TransformableLoginButton> createState() => _TransformableLoginButtonState();
}

class _TransformableLoginButtonState extends State<TransformableLoginButton>
    with TickerProviderStateMixin {
  late AnimationController _morphController; // Controls width and corner radius morph
  late AnimationController _successController; // Controls arrow to checkmark morph
  late AnimationController _spinController; // For subtle rotation during loading

  late Animation<double> _widthAnimation;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;

  final double _buttonHeight = 56.0;

  @override
  void initState() {
    super.initState();

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _radiusAnimation = Tween<double>(begin: 16.0, end: 28.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _morphController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _setupAnimations();
  }

  void _setupAnimations() {
    // Width animation is updated dynamically based on parent constraint or layout width
    _widthAnimation = Tween<double>(begin: 300.0, end: 56.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didUpdateWidget(TransformableLoginButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state != oldWidget.state) {
      if (widget.state == TransformableButtonState.loading) {
        _morphController.forward();
        _spinController.repeat();
      } else if (widget.state == TransformableButtonState.success) {
        _morphController.forward();
        _spinController.stop();
        _successController.forward();
      } else {
        _morphController.reverse();
        _successController.reverse();
        _spinController.stop();
      }
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _successController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final btnBg = widget.backgroundColor ?? theme.colorScheme.secondary;
    final strokeColor = widget.color ?? Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        // Dynamically adjust width animation based on layout constraints
        _widthAnimation = Tween<double>(
          begin: maxWidth == double.infinity ? 320.0 : maxWidth,
          end: _buttonHeight,
        ).animate(
          CurvedAnimation(parent: _morphController, curve: Curves.easeInOutCubic),
        );

        return AnimatedBuilder(
          animation: _morphController,
          builder: (context, child) {
            final double currentWidth = _widthAnimation.value;
            final double currentRadius = _radiusAnimation.value;

            return Center(
              child: SizedBox(
                width: currentWidth,
                height: _buttonHeight,
                child: Material(
                  color: btnBg,
                  borderRadius: BorderRadius.circular(currentRadius),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: widget.state == TransformableButtonState.idle ? widget.onPressed : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Button Text & Arrow (Idle state)
                        Opacity(
                          opacity: _opacityAnimation.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.buttonText,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),

                        // 2. Animated Custom Painter (Loading / Success state)
                        if (_morphController.value > 0.4)
                          AnimatedBuilder(
                            animation: Listenable.merge([_successController, _spinController]),
                            builder: (context, child) {
                              // Spin the arrow slightly during loading for a dynamic effect
                              final double spinAngle = widget.state == TransformableButtonState.loading
                                  ? _spinController.value * 2 * math.pi
                                  : 0.0;

                              return Transform.rotate(
                                angle: spinAngle,
                                child: SizedBox(
                                  width: _buttonHeight,
                                  height: _buttonHeight,
                                  child: CustomPaint(
                                    painter: TransformableButtonPainter(
                                      progress: _successController.value,
                                      isSuccess: widget.state == TransformableButtonState.success,
                                      color: strokeColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TransformableButtonPainter extends CustomPainter {
  final double progress; // 0.0 (arrow) to 1.0 (checkmark)
  final bool isSuccess;
  final Color color;

  TransformableButtonPainter({
    required this.progress,
    required this.isSuccess,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;

    // We draw relative to a 56x56 coordinate box
    const double arrowPadding = 18.0;
    const double arrowBackSize = 9.0;
    const double leftCheckLine = 7.0;
    const double rightCheckLine = 15.0;

    final double startX = arrowPadding;
    final double endX = width - arrowPadding;

    if (!isSuccess && progress == 0.0) {
      // 1. Draw pure static arrow pointing right
      canvas.drawLine(Offset(startX, centerY), Offset(endX, centerY), paint);

      final double backX = endX - arrowBackSize * math.cos(math.pi / 4);
      final double backY = arrowBackSize * math.sin(math.pi / 4);

      canvas.drawLine(Offset(endX, centerY), Offset(backX, centerY - backY), paint);
      canvas.drawLine(Offset(endX, centerY), Offset(backX, centerY + backY), paint);
    } else {
      // 2. Morph from Arrow to Checkmark
      // Translate slightly to center the checkmark nicely
      canvas.save();
      canvas.translate(-2.0 * progress, 1.0 * progress);
      canvas.translate(centerX, centerY);
      canvas.rotate(90.0 * progress * math.pi / 180.0);
      canvas.translate(-centerX, -centerY);

      // Shaft line: as progress goes to 1.0, the line shrinks and vanishes
      final double currentStartX = startX + (endX - startX) * progress;
      if (currentStartX < endX) {
        canvas.drawLine(Offset(currentStartX, centerY), Offset(endX, centerY), paint);
      }

      // Checkmark arms (formerly arrow tips)
      final double leftSize = arrowBackSize + (leftCheckLine - arrowBackSize) * progress;
      final double rightSize = arrowBackSize + (rightCheckLine - arrowBackSize) * progress;

      final double leftAngle = math.pi / 4;
      final double rightAngle = math.pi / 4;

      canvas.drawLine(
        Offset(endX, centerY),
        Offset(endX - leftSize * math.cos(leftAngle), centerY + leftSize * math.sin(leftAngle)),
        paint,
      );

      canvas.drawLine(
        Offset(endX, centerY),
        Offset(endX - rightSize * math.cos(rightAngle), centerY - rightSize * math.sin(rightAngle)),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant TransformableButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.color != color;
  }
}
