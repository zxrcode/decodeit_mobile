import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaserScannerOverlay extends StatefulWidget {
  final String statusText;
  const LaserScannerOverlay({super.key, required this.statusText});

  @override
  State<LaserScannerOverlay> createState() => _LaserScannerOverlayState();
}

class _LaserScannerOverlayState extends State<LaserScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Matrix-like binary rain or static bits
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScannerPainter(
                    progress: _controller.value,
                    random: _random,
                  ),
                );
              },
            ),
          ),
          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glitchy looking status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.statusText.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          color: Colors.greenAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
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
}

class _ScannerPainter extends CustomPainter {
  final double progress;
  final Random random;

  _ScannerPainter({required this.progress, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.6)
      ..strokeWidth = 2.0;

    final double y = size.height * progress;
    
    // Draw scanner line with glow
    final glowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.3)
      ..strokeWidth = 15.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    
    canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Draw some "bits" passing through the scanner
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 20; i++) {
      final double x = (i * size.width / 20) + (sin(progress * pi * 2 + i) * 10);
      final double bitY = (y + (i * 10) % 50 - 25).clamp(0, size.height);
      
      textPainter.text = TextSpan(
        text: random.nextBool() ? '0' : '1',
        style: GoogleFonts.firaCode(
          color: Colors.greenAccent.withOpacity(0.2),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x, bitY));
    }
    
    // Draw vertical grid lines occasionally
    final gridPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.05)
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 10; i++) {
      final double x = i * size.width / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScannerPainter oldDelegate) => true;
}
