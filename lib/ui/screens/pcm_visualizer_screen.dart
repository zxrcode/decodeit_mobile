import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/sound_generator_service.dart';

class PcmVisualizerScreen extends StatefulWidget {
  const PcmVisualizerScreen({super.key});

  @override
  State<PcmVisualizerScreen> createState() => _PcmVisualizerScreenState();
}

class _PcmVisualizerScreenState extends State<PcmVisualizerScreen>
    with SingleTickerProviderStateMixin {
  final _soundService = GetIt.instance<SoundGeneratorService>();
  double _samplingRate = 12.0; // 4 to 32 samples per wave cycle
  int _bitDepth = 3; // 2, 3, or 4 bits (4, 8, or 16 levels)
  late AnimationController _animationController;
  bool _isPlaying = false;
  double _scanPosition = 0.0;

  void _updateAnimationSpeed() {
    // Higher sampling rate = faster animation
    // 4Hz -> 4 seconds per cycle, 24Hz -> 0.6 seconds per cycle
    final double newSeconds = (16.0 / _samplingRate) * 1.0;
    _animationController.duration = Duration(milliseconds: (newSeconds * 1000).toInt());
    if (_isPlaying) {
      _animationController.repeat();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        if (_isPlaying) {
          final double x = _animationController.value;
          
          // Match painter's logic for quantization
          // We have 1.5 sine cycles in the visual width
          final int samplesCount = _samplingRate.round();
          final int levels = math.pow(2, _bitDepth).toInt();
          
          // Find which visual sample we are on
          final int currentSampleIndex = (x * samplesCount).floor();
          // The x position of that sample's start
          final double sampleT = currentSampleIndex / samplesCount;
          
          // Painter uses math.sin(t * 2 * math.pi * 1.5)
          final double sineVal = math.sin(sampleT * 2 * math.pi * 1.5);
          
          // Normalize exactly like painter's yQuantized logic
          // Painter: midY + sineVal * (size.height / 2 - levelHeight)
          // Since we just need the quantized level (0 to levels-1)
          final double normalized = (sineVal + 1.0) / 2.0; // 0.0 to 1.0
          int quantLevel = (normalized * (levels - 1)).round();
          quantLevel = quantLevel.clamp(0, levels - 1);
          
          // Map quantized level to frequency
          final double baseFreq = 200.0;
          final double freqStep = 600.0 / levels;
          final double targetFreq = baseFreq + (quantLevel * freqStep);
          
          _soundService.setFrequency(targetFreq);
        }
        
        setState(() {
          _scanPosition = _animationController.value;
        });
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _soundService.stop();
    super.dispose();
  }

  void _togglePlay() async {
    if (_isPlaying) {
      _animationController.stop();
      _soundService.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      _updateAnimationSpeed();
      await _soundService.start();
      _soundService.setVolume(0.1);
    }
  }

  // Calculate the binary representation for a given sine value
  List<String> _getSampledBits() {
    final int samplesCount = _samplingRate.round();
    final int levels = math.pow(2, _bitDepth).toInt();
    final List<String> bits = [];

    for (int i = 0; i < samplesCount; i++) {
      final double t = i / samplesCount;
      final double sineValue = math.sin(t * 2 * math.pi); // -1.0 to 1.0
      // Normalize to 0.0 to 1.0
      final double normalized = (sineValue + 1.0) / 2.0;
      // Quantize to integer level
      int level = (normalized * (levels - 1)).round();
      level = level.clamp(0, levels - 1);
      // Convert to binary string
      final String binary = level.toRadixString(2).padLeft(_bitDepth, '0');
      bits.add(binary);
    }
    return bits;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> binaryStream = _getSampledBits();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PCM ДЫБЫС КОДТАУ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header explanation Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.graphic_eq, color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Импульстік-Кодтық Модуляция (PCM)',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Аналогты дыбысты цифрлық кодқа айналдыру 2 негізгі кезеңнен тұрады:\n'
                      '1. Дискреттеу (уақыт бойынша өлшеу жиілігі)\n'
                      '2. Кванттау (амплитуда деңгейлерін биттермен кодтау)',
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Visualizer Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Сигналдарды Салыстыру',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Drawing canvas
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1E2638), width: 1.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomPaint(
                          painter: _PcmPainter(
                            samplingRate: _samplingRate,
                            bitDepth: _bitDepth,
                            scanPosition: _scanPosition,
                            isPlaying: _isPlaying,
                            theme: theme,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Legend
                    Wrap(
                      spacing: 16,
                      children: [
                        _LegendItem(color: Colors.yellow, label: 'Аналогты (Толқын)'),
                        _LegendItem(color: theme.colorScheme.primary, label: 'Дискреттеу нүктелері'),
                        _LegendItem(color: theme.colorScheme.tertiary, label: 'Қалпына келген сандық'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Параметрлерді реттеу',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sampling Rate Slider
                    Text(
                      'Дискреттеу жиілігі (Sampling Rate): ${_samplingRate.round()} Гц (нүкте саны)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Slider(
                      value: _samplingRate,
                      min: 4,
                      max: 24,
                      divisions: 20,
                      label: '${_samplingRate.round()} Гц',
                      onChanged: (val) {
                        setState(() {
                          _samplingRate = val;
                          _updateAnimationSpeed();
                        });
                      },
                    ),
                    // Bit Depth Selection
                    const Text(
                      'Кванттау тереңдігі (Bit Depth):',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [2, 3, 4].map((bits) {
                        final count = math.pow(2, bits).toInt();
                        return ChoiceChip(
                          label: Text(
                            '$bits-бит ($count деңгей)',
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: _bitDepth == bits,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _bitDepth = bits;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Controls
                    FilledButton.icon(
                      onPressed: _togglePlay,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? 'Тоқтату' : 'Сигналды іске қосу'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Binary Output Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сандық биттер легі (Binary Stream):',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF070B14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1E2638)),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: binaryStream.map((bin) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: theme.colorScheme.tertiary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              bin,
                              style: GoogleFonts.firaCode(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Жалпы бит саны: ${binaryStream.length * _bitDepth} бит',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _PcmPainter extends CustomPainter {
  final double samplingRate;
  final int bitDepth;
  final double scanPosition;
  final bool isPlaying;
  final ThemeData theme;

  _PcmPainter({
    required this.samplingRate,
    required this.bitDepth,
    required this.scanPosition,
    required this.isPlaying,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double width = size.width;
    final int levels = math.pow(2, bitDepth).toInt();
    final double levelHeight = size.height / (levels + 1);

    // Draw grid quantization lines
    final Paint gridPaint = Paint()
      ..color = const Color(0xFF1E2638)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= levels; i++) {
      final double y = i * levelHeight;
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);

      // Quantization Level Text
      final String binary = (levels - i).toRadixString(2).padLeft(bitDepth, '0');
      final textPainter = TextPainter(
        text: TextSpan(
          text: binary,
          style: GoogleFonts.firaCode(
            color: const Color(0xFF64748B),
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(4, y - 10));
    }

    // Draw Analog Sine Wave
    final Paint analogPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path analogPath = Path();
    for (double x = 0; x <= width; x++) {
      final double t = x / width;
      final double y = midY + math.sin(t * 2 * math.pi * 1.5) * (size.height / 2 - levelHeight);
      if (x == 0) {
        analogPath.moveTo(x, y);
      } else {
        analogPath.lineTo(x, y);
      }
    }
    canvas.drawPath(analogPath, analogPaint);

    // Sampling Points and Digitized stairwave calculation
    final int samplesCount = samplingRate.round();
    final List<Offset> samplePoints = [];
    final List<Offset> stairPoints = [];

    final double stepWidth = width / samplesCount;

    for (int i = 0; i <= samplesCount; i++) {
      final double x = i * stepWidth;
      final double t = x / width;
      final double sineVal = math.sin(t * 2 * math.pi * 1.5);
      final double yAnalog = midY + sineVal * (size.height / 2 - levelHeight);

      // Map analog y value to nearest quantization level
      // Normalize to 0-1 range from top of grid to bottom
      // In flutter, top is 0, bottom is height
      final double normalized = yAnalog / size.height;
      // Convert to integer level
      int quantLevel = (normalized * (levels + 1)).round();
      quantLevel = quantLevel.clamp(1, levels);
      final double yQuantized = quantLevel * levelHeight;

      samplePoints.add(Offset(x, yQuantized));

      if (i > 0) {
        // Horizontal line from previous step to current x
        stairPoints.add(Offset(x, samplePoints[i - 1].dy));
      }
      stairPoints.add(Offset(x, yQuantized));
    }

    // Draw Digitized Stair-step wave
    final Paint stairPaint = Paint()
      ..color = theme.colorScheme.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final Path stairPath = Path();
    if (stairPoints.isNotEmpty) {
      stairPath.moveTo(stairPoints[0].dx, stairPoints[0].dy);
      for (int i = 1; i < stairPoints.length; i++) {
        stairPath.lineTo(stairPoints[i].dx, stairPoints[i].dy);
      }
      canvas.drawPath(stairPath, stairPaint);
    }

    // Draw Sampling lines and Red Dots
    final Paint linePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.3)
      ..strokeWidth = 1.0;
    final Paint dotPaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.fill;

    for (var point in samplePoints) {
      // vertical sampling line
      canvas.drawLine(Offset(point.dx, 0), Offset(point.dx, size.height), linePaint);
      // dot
      canvas.drawCircle(point, 4.0, dotPaint);
    }

    // Playback scan line
    if (isPlaying) {
      final double scanX = scanPosition * width;
      final Paint scanPaint = Paint()
        ..color = theme.colorScheme.secondary
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(scanX, 0), Offset(scanX, size.height), scanPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PcmPainter oldDelegate) {
    return oldDelegate.samplingRate != samplingRate ||
        oldDelegate.bitDepth != bitDepth ||
        oldDelegate.scanPosition != scanPosition ||
        oldDelegate.isPlaying != isPlaying;
  }
}
