import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HudLoadingOverlay extends StatefulWidget {
  final bool isVisible;
  final String statusText;

  const HudLoadingOverlay({
    super.key,
    required this.isVisible,
    required this.statusText,
  });

  @override
  State<HudLoadingOverlay> createState() => _HudLoadingOverlayState();
}

class _HudLoadingOverlayState extends State<HudLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.isVisible) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant HudLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!widget.isVisible && _rotationController.isAnimating) {
      _rotationController.stop();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1424),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.primaryColor.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rotating Cyber Ring
                AnimatedBuilder(
                  animation: _rotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(80, 80),
                        painter: _CyberRingPainter(
                          color: theme.primaryColor,
                          secondaryColor: theme.colorScheme.secondary,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Status Text
                Text(
                  widget.statusText.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ҚАУІПСІЗ Есептеу ОРЫНДАЛУДА...',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    color: theme.colorScheme.tertiary,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberRingPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _CyberRingPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);

    final Paint mainPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final Paint secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw main ring segments
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 0.4,
      false,
      mainPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.7,
      math.pi * 0.5,
      false,
      mainPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.4,
      math.pi * 0.4,
      false,
      mainPaint,
    );

    // Draw secondary outer ring segments
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 6),
      -math.pi * 0.3,
      math.pi * 0.6,
      false,
      secondaryPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 6),
      math.pi * 0.8,
      math.pi * 0.6,
      false,
      secondaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CyberRingPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.secondaryColor != secondaryColor;
  }
}
