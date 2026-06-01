import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import '../../data/services/sound_generator_service.dart';

class SpectrogramScreen extends StatefulWidget {
  const SpectrogramScreen({super.key});

  @override
  State<SpectrogramScreen> createState() => _SpectrogramScreenState();
}

class _SpectrogramScreenState extends State<SpectrogramScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _soundService = GetIt.instance<SoundGeneratorService>();
  final Random _random = Random();
  bool _isListening = false;
  String _hiddenMessage = '';
  final _msgController = TextEditingController();

  // Simulation data for spectrogram "waterfall"
  List<List<double>> _waterfallData = [];
  final int _rows = 40;
  final int _cols = 60;

  @override
  void initState() {
    super.initState();
    _waterfallData = List.generate(_rows, (_) => List.generate(_cols, (_) => _random.nextDouble() * 0.2));
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100))..repeat();
    _controller.addListener(_updateWaterfall);
  }

  void _toggleListening(bool value) async {
    setState(() => _isListening = value);
    if (_isListening) {
      await _soundService.start();
      _soundService.setVolume(0.1);
    } else {
      _soundService.stop();
      _hiddenMessage = '';
    }
  }

  void _updateWaterfall() {
    if (!_isListening) return;
    setState(() {
      // Shift rows down
      _waterfallData.removeLast();
      
      // Generate new top row
      double avgFreq = 440.0;
      final newRow = List.generate(_cols, (i) {
        double val = _random.nextDouble() * 0.3;
        
        // If we have a hidden message, "burn" pixels into the spectrogram
        if (_hiddenMessage.isNotEmpty) {
           for (var charIndex = 0; charIndex < _hiddenMessage.length; charIndex++) {
             int targetCol = (charIndex * 5 + 10) % _cols;
             if ((DateTime.now().millisecondsSinceEpoch / 100).floor() % 10 < 5) {
                if (i == targetCol) {
                  val = 1.0;
                  // Modulate sound based on visible message columns
                  avgFreq = 200.0 + (targetCol * 20.0);
                }
             }
           }
        }
        return val;
      });
      
      if (_isListening) {
        _soundService.setFrequency(avgFreq + (_random.nextDouble() * 50));
      }
      
      _waterfallData.insert(0, newRow);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _msgController.dispose();
    _soundService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('СПЕКТРОГРАММА')),
      body: Column(
        children: [
          _buildVisualizer(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildControls(),
                  const SizedBox(height: 20),
                  _buildSteganoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizer() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.black,
      child: CustomPaint(
        painter: _SpectrogramPainter(data: _waterfallData),
      ),
    );
  }

  Widget _buildControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Микрофон / Сигнал:', style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: _isListening,
                  onChanged: _toggleListening,
                ),
              ],
            ),
            const Text('Спектрограмма дыбыстың жиілік құрамын уақыт бойынша көрсетеді (FFT симуляциясы).',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSteganoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('АУДИО-СТЕГАНОГРАФИЯ', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.cyan)),
        const SizedBox(height: 8),
        const Text('Дыбыс спектріне жасырын хабарлама жазу технологиясы.', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 12),
        TextField(
          controller: _msgController,
          decoration: const InputDecoration(
            labelText: 'Жасырын сөз',
            hintText: 'Мысалы: HELLO',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            setState(() {
              _hiddenMessage = _msgController.text.toUpperCase();
            });
            _toggleListening(true);
          },
          icon: const Icon(Icons.hearing),
          label: const Text('Спектрге жазу және тыңдау'),
        ),
        if (_hiddenMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Жоғарыдағы графиктен "$_hiddenMessage" сөзін іздеңіз!', 
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
      ],
    );
  }
}

class _SpectrogramPainter extends CustomPainter {
  final List<List<double>> data;
  _SpectrogramPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final double cellW = size.width / data[0].length;
    final double cellH = size.height / data.length;

    for (int r = 0; r < data.length; r++) {
      for (int c = 0; c < data[r].length; c++) {
        final val = data[r][c];
        // Heatmap colors: Blue -> Green -> Yellow -> Red
        Color color;
        if (val < 0.25) {
          color = Colors.blue.withOpacity(val * 4);
        } else if (val < 0.5) {
          color = Colors.green.withOpacity(val * 2);
        } else if (val < 0.75) {
          color = Colors.yellow.withOpacity(val);
        } else {
          color = Colors.red.withOpacity(val);
        }

        final paint = Paint()..color = color;
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrogramPainter oldDelegate) => true;
}
