import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/morse_code_data.dart';
import '../../data/services/morse_audio_service.dart';

class MorseTranslatorScreen extends StatefulWidget {
  final MorseAudioService audioService;

  const MorseTranslatorScreen({super.key, required this.audioService});

  @override
  State<MorseTranslatorScreen> createState() => _MorseTranslatorScreenState();
}

class _MorseTranslatorScreenState extends State<MorseTranslatorScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController morseController = TextEditingController();
  bool _isPlaying = false;

  void convertTextToMorse() {
    setState(() {
      morseController.text = MorseCodeData.textToMorse(textController.text);
    });
  }

  void convertMorseToText() {
    setState(() {
      textController.text = MorseCodeData.morseToText(morseController.text);
    });
  }

  Future<void> _playOrStop() async {
    if (_isPlaying) {
      await widget.audioService.stop();
      setState(() => _isPlaying = false);
      return;
    }
    if (morseController.text.isEmpty) return;
    setState(() => _isPlaying = true);
    await widget.audioService.playMorseCode(morseController.text);
    if (mounted) setState(() => _isPlaying = false);
  }

  void _copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label алмасу буферіне көшірілді'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyExample(String text) {
    textController.text = text;
    convertTextToMorse();
  }

  void _showAudioSettings() {
    final settings = widget.audioService.settings;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Аудио параметрлері',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('Жылдамдық: ${settings.wpm.round()} WPM'),
                  Slider(
                    value: settings.wpm,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    label: '${settings.wpm.round()} WPM',
                    onChanged: (value) {
                      setModalState(() => settings.wpm = value);
                      settings.save();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Дыбыс деңгейі: ${(settings.volume * 100).round()}%'),
                  Slider(
                    value: settings.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(settings.volume * 100).round()}%',
                    onChanged: (value) {
                      setModalState(() => settings.volume = value);
                      settings.save();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Морзе коды'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text input area
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Мәтін",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () =>
                                _copyToClipboard(textController.text, 'Мәтін'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          onChanged: (value) => convertTextToMorse(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'''[a-zA-Z0-9 .,?!/()&:;=+\-"'@]'''))
                          ],
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Morse code area
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Морзе коды",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () => _copyToClipboard(
                                morseController.text, 'Морзе коды'),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: morseController,
                          onChanged: (value) => convertMorseToText(),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[.\- /]'))
                          ],
                          maxLines: null,
                          expands: true,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Quick examples
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: MorseCodeData.quickExamples.map((example) {
                return ActionChip(
                  label: Text(example['label']!),
                  onPressed: () => _applyExample(example['text']!),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Waveform visualizer
            MorseWaveformVisualizer(audioService: widget.audioService),
            const SizedBox(height: 16),
            // Play/Stop + Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _playOrStop,
                  child: Icon(
                    _isPlaying ? Icons.stop : Icons.play_arrow,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: _showAudioSettings,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MorseWaveformVisualizer extends StatefulWidget {
  final MorseAudioService audioService;
  const MorseWaveformVisualizer({super.key, required this.audioService});

  @override
  State<MorseWaveformVisualizer> createState() => _MorseWaveformVisualizerState();
}

class _MorseWaveformVisualizerState extends State<MorseWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSoundActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    widget.audioService.isEmittingSound.addListener(_onSoundChanged);
  }

  void _onSoundChanged() {
    if (mounted) {
      setState(() {
        _isSoundActive = widget.audioService.isEmittingSound.value;
      });
    }
  }

  @override
  void dispose() {
    widget.audioService.isEmittingSound.removeListener(_onSoundChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF070B14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2638)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _WaveformPainter(
                progress: _controller.value,
                isActive: _isSoundActive,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color color;

  _WaveformPainter({
    required this.progress,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double midY = size.height / 2;
    final double width = size.width;

    final Paint paint = Paint()
      ..color = isActive ? color : color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path path = Path();
    path.moveTo(0, midY);

    final double frequency = isActive ? 6.0 : 1.5;
    final double amplitude = isActive ? size.height * 0.35 : 2.0;

    for (double x = 0; x <= width; x++) {
      final double t = x / width;
      final double phase = progress * 2 * math.pi;
      final double sineVal = math.sin(t * frequency * 2 * math.pi - phase);
      final double envelope = math.sin(t * math.pi); // 0 at t=0, 1 at t=0.5, 0 at t=1
      final double y = midY + sineVal * amplitude * envelope;
      
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isActive != isActive ||
        oldDelegate.color != color;
  }
}
