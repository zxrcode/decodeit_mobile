import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/explanations/color_explanation.dart';

class ColorModelsScreen extends StatefulWidget {
  const ColorModelsScreen({super.key});

  @override
  State<ColorModelsScreen> createState() => _ColorModelsScreenState();
}

class _ColorModelsScreenState extends State<ColorModelsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // RGB values
  double _r = 255, _g = 255, _b = 0;
  // CMYK values
  double _c = 0, _m = 0, _y = 1, _k = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _updateCmykFromRgb() {
    double r = _r / 255;
    double g = _g / 255;
    double b = _b / 255;

    _k = 1 - [r, g, b].reduce((curr, next) => curr > next ? curr : next);
    if (_k == 1) {
      _c = _m = _y = 0;
    } else {
      _c = (1 - r - _k) / (1 - _k);
      _m = (1 - g - _k) / (1 - _k);
      _y = (1 - b - _k) / (1 - _k);
    }
  }

  void _updateRgbFromCmyk() {
    _r = 255 * (1 - _c) * (1 - _k);
    _g = 255 * (1 - _m) * (1 - _k);
    _b = 255 * (1 - _y) * (1 - _k);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RGB vs CMYK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const ColorExplanation(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RGB (Экран)'),
            Tab(text: 'CMYK (Баспа)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRgbTab(),
          _buildCmykTab(),
        ],
      ),
    );
  }

  Widget _buildRgbTab() {
    final currentColor = Color.fromARGB(255, _r.round(), _g.round(), _b.round());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            'Аддитивті модель (RGB)',
            'Түстер жарық сәулелерін қосу арқылы жасалады. R+G+B = Ақ түс. Экрандарда қолданылады.',
            Colors.redAccent,
          ),
          const SizedBox(height: 20),
          _buildColorPreview(currentColor, 'RGB(${_r.round()}, ${_g.round()}, ${_b.round()})'),
          const SizedBox(height: 20),
          _buildSlider('Қызыл (Red)', _r, Colors.red, (v) => setState(() { _r = v; _updateCmykFromRgb(); })),
          _buildSlider('Жасыл (Green)', _g, Colors.green, (v) => setState(() { _g = v; _updateCmykFromRgb(); })),
          _buildSlider('Көк (Blue)', _b, Colors.blue, (v) => setState(() { _b = v; _updateCmykFromRgb(); })),
          const SizedBox(height: 20),
          _buildVennSim(currentColor, true),
        ],
      ),
    );
  }

  Widget _buildCmykTab() {
    final currentColor = Color.fromARGB(255, _r.round(), _g.round(), _b.round());
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard(
            'Субтрактивті модель (CMYK)',
            'Түстер жарықты жұту (бояу) арқылы жасалады. C+M+Y = Қара түс. Баспада қолданылады.',
            Colors.cyan,
          ),
          const SizedBox(height: 20),
          _buildColorPreview(currentColor, 
            'C:${(_c*100).round()}% M:${(_m*100).round()}% Y:${(_y*100).round()}% K:${(_k*100).round()}%'),
          const SizedBox(height: 20),
          _buildSlider('Cyan', _c * 100, Colors.cyan, (v) => setState(() { _c = v/100; _updateRgbFromCmyk(); })),
          _buildSlider('Magenta', _m * 100, const Color(0xFFFF00FF), (v) => setState(() { _m = v/100; _updateRgbFromCmyk(); })),
          _buildSlider('Yellow', _y * 100, Colors.yellow, (v) => setState(() { _y = v/100; _updateRgbFromCmyk(); })),
          _buildSlider('Black (Key)', _k * 100, Colors.black, (v) => setState(() { _k = v/100; _updateRgbFromCmyk(); })),
          const SizedBox(height: 20),
          _buildVennSim(currentColor, false),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 4),
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.firaCode(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSlider(String label, double value, Color color, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 100 > value ? 100 : 255, // Adapt for CMYK % or RGB 255
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildVennSim(Color result, bool isRgb) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isRgb ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _ColorMixingPainter(
            r: _r, g: _g, b: _b,
            c: _c, m: _m, y: _y, k: _k,
            isRgb: isRgb,
          ),
        ),
      ),
    );
  }
}

class _ColorMixingPainter extends CustomPainter {
  final double r, g, b;
  final double c, m, y, k;
  final bool isRgb;

  _ColorMixingPainter({
    required this.r, required this.g, required this.b,
    required this.c, required this.m, required this.y, required this.k,
    required this.isRgb,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 6;

    if (isRgb) {
      // Additive mixing (Light)
      final paintR = Paint()..color = Color.fromARGB((r).round(), 255, 0, 0)..blendMode = BlendMode.plus;
      final paintG = Paint()..color = Color.fromARGB((g).round(), 0, 255, 0)..blendMode = BlendMode.plus;
      final paintB = Paint()..color = Color.fromARGB((b).round(), 0, 0, 255)..blendMode = BlendMode.plus;

      canvas.drawCircle(center.translate(0, -radius * 0.5), radius, paintR);
      canvas.drawCircle(center.translate(-radius * 0.5, radius * 0.3), radius, paintG);
      canvas.drawCircle(center.translate(radius * 0.5, radius * 0.3), radius, paintB);
    } else {
      // Subtractive mixing (Ink)
      // CMYK simulation: we use multiply blend mode
      // Resulting color is white - (C+M+Y+K)
      
      // We simulate physical ink layers
      final paintC = Paint()..color = Color.fromARGB((c * 255).round(), 0, 255, 255)..blendMode = BlendMode.multiply;
      final paintM = Paint()..color = Color.fromARGB((m * 255).round(), 255, 0, 255)..blendMode = BlendMode.multiply;
      final paintY = Paint()..color = Color.fromARGB((y * 255).round(), 255, 255, 0)..blendMode = BlendMode.multiply;
      final paintK = Paint()..color = Color.fromARGB((k * 255).round(), 0, 0, 0)..blendMode = BlendMode.multiply;

      canvas.drawCircle(center.translate(0, -radius * 0.5), radius, paintC);
      canvas.drawCircle(center.translate(-radius * 0.5, radius * 0.3), radius, paintM);
      canvas.drawCircle(center.translate(radius * 0.5, radius * 0.3), radius, paintY);
      // Black layer covers everything
      canvas.drawCircle(center, radius * 0.3, paintK);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
