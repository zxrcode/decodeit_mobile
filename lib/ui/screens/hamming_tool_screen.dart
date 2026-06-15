import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/explanations/hamming_explanation.dart';

class HammingToolScreen extends StatefulWidget {
  const HammingToolScreen({super.key});

  @override
  State<HammingToolScreen> createState() => _HammingToolScreenState();
}

class _HammingToolScreenState extends State<HammingToolScreen> with SingleTickerProviderStateMixin {
  // Data bits: d1, d2, d3, d4
  List<int> _dataBits = [1, 0, 1, 1];
  // Parity bits: p1, p2, p3
  List<int> _parityBits = [0, 0, 0];
  // Sent bits (7 bits total: p1, p2, d1, p3, d2, d3, d4)
  List<int> _sentBits = List.filled(7, 0);
  // Received bits (with possible error)
  List<int> _receivedBits = List.filled(7, 0);
  
  int _errorBitIndex = -1; // -1 means no error
  int _detectedErrorIndex = -1;

  late AnimationController _animController;
  bool _isTransmitting = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..addListener(() => setState(() {}));
    _calculateHamming();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _runTransmission() {
    setState(() {
      _isTransmitting = true;
    });
    _animController.forward(from: 0).then((_) {
      setState(() {
        _isTransmitting = false;
      });
    });
  }

  void _calculateHamming() {
    final d1 = _dataBits[0];
    final d2 = _dataBits[1];
    final d3 = _dataBits[2];
    final d4 = _dataBits[3];

    final p1 = d1 ^ d2 ^ d4;
    final p2 = d1 ^ d3 ^ d4;
    final p3 = d2 ^ d3 ^ d4;

    _parityBits = [p1, p2, p3];
    _sentBits = [p1, p2, d1, p3, d2, d3, d4];
    _receivedBits = List.from(_sentBits);
    if (_errorBitIndex != -1) {
      _receivedBits[_errorBitIndex] = 1 - _receivedBits[_errorBitIndex];
    }
    _detectError();
  }

  void _detectError() {
    final r = _receivedBits;
    final s1 = r[0] ^ r[2] ^ r[4] ^ r[6];
    final s2 = r[1] ^ r[2] ^ r[5] ^ r[6];
    final s3 = r[3] ^ r[4] ^ r[5] ^ r[6];

    final syndrome = (s3 << 2) | (s2 << 1) | s1;
    _detectedErrorIndex = syndrome - 1;
  }

  void _toggleDataBit(int index) {
    setState(() {
      _dataBits[index] = 1 - _dataBits[index];
      _calculateHamming();
    });
  }

  void _injectError(int index) {
    setState(() {
      if (_errorBitIndex == index) {
        _errorBitIndex = -1;
      } else {
        _errorBitIndex = index;
      }
      _calculateHamming();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ХЭММИНГ КОДЫ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const HammingExplanation(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildExplanationCard(),
            const SizedBox(height: 16),
            _buildInputSection(),
            const SizedBox(height: 16),
            _buildVennDiagram(),
            const SizedBox(height: 16),
            _buildTransmissionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return Card(
      color: Colors.blue.withOpacity(0.1),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Хэмминг (7,4) коды дегеніміз не?', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueAccent)),
            SizedBox(height: 8),
            Text('Бұл әдіс 4 бит дерекке 3 бақылау битін қосу арқылы 1-биттік қатені тауып, оны автоматты түрде түзеуге мүмкіндік береді.',
              style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Деректерді өзгерту (4 бит):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_dataBits[i].toString(), style: const TextStyle(fontSize: 18)),
                  selected: false,
                  onSelected: (_) => _toggleDataBit(i),
                  avatar: Text('d${i+1}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVennDiagram() {
    return AspectRatio(
      aspectRatio: 1.2,
      child: CustomPaint(
        painter: _HammingVennPainter(
          dataBits: _dataBits,
          parityBits: _parityBits,
          errorIndex: _isTransmitting ? -1 : _detectedErrorIndex,
        ),
      ),
    );
  }

  Widget _buildTransmissionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Тасымалдау және Қате жіберу (7 бит):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_isTransmitting)
               Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: LinearProgressIndicator(value: _animController.value, color: Colors.blueAccent),
               ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: List.generate(7, (i) {
                final isError = _errorBitIndex == i;
                final isDetected = _detectedErrorIndex == i && !_isTransmitting;
                return GestureDetector(
                  onTap: () => _injectError(i),
                  child: Container(
                    width: 35,
                    height: 45,
                    decoration: BoxDecoration(
                      color: isError ? Colors.red.withOpacity(0.3) : Colors.black26,
                      border: Border.all(
                        color: isDetected ? Colors.greenAccent : (isError ? Colors.red : Colors.white24),
                        width: isDetected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_receivedBits[i].toString(), 
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: isError ? Colors.redAccent : Colors.white,
                          )),
                        Text(['p1','p2','d1','p3','d2','d3','d4'][i], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isTransmitting ? null : _runTransmission,
              icon: const Icon(Icons.send),
              label: const Text('Деректерді жіберу'),
            ),
            const SizedBox(height: 12),
            if (_detectedErrorIndex != -1 && !_isTransmitting)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Қате табылды! ${_detectedErrorIndex + 1}-позициядағы бит түзетілді.',
                        style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              )
            else if (!_isTransmitting)
              const Text('Қате жоқ. Деректер таза.', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _HammingVennPainter extends CustomPainter {
  final List<int> dataBits;
  final List<int> parityBits;
  final int errorIndex;

  _HammingVennPainter({required this.dataBits, required this.parityBits, required this.errorIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 4;

    final p1Center = center.translate(-radius * 0.6, -radius * 0.4);
    final p2Center = center.translate(radius * 0.6, -radius * 0.4);
    final p3Center = center.translate(0, radius * 0.6);

    final paint1 = Paint()..color = Colors.blue.withOpacity(0.2)..style = PaintingStyle.fill;
    final paint2 = Paint()..color = Colors.red.withOpacity(0.2)..style = PaintingStyle.fill;
    final paint3 = Paint()..color = Colors.yellow.withOpacity(0.2)..style = PaintingStyle.fill;
    
    final borderPaint = Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1;

    canvas.drawCircle(p1Center, radius, paint1);
    canvas.drawCircle(p1Center, radius, borderPaint);
    canvas.drawCircle(p2Center, radius, paint2);
    canvas.drawCircle(p2Center, radius, borderPaint);
    canvas.drawCircle(p3Center, radius, paint3);
    canvas.drawCircle(p3Center, radius, borderPaint);

    void drawBit(String label, String value, Offset pos, {bool highlight = false}) {
      final tp = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(text: '$label\n', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            TextSpan(text: value, style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: highlight ? Colors.greenAccent : Colors.white,
            )),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
    }

    drawBit('p1', parityBits[0].toString(), p1Center.translate(-radius * 0.4, -radius * 0.3), highlight: errorIndex == 0);
    // Actually using center offsets
    drawBit('p2', parityBits[1].toString(), p2Center.translate(radius * 0.4, -radius * 0.3), highlight: errorIndex == 1);
    drawBit('p3', parityBits[2].toString(), p3Center.translate(0, radius * 0.5), highlight: errorIndex == 3);

    drawBit('d1', dataBits[0].toString(), center.translate(0, -radius * 0.45), highlight: errorIndex == 2);
    drawBit('d2', dataBits[1].toString(), center.translate(-radius * 0.35, radius * 0.15), highlight: errorIndex == 4);
    drawBit('d3', dataBits[2].toString(), center.translate(radius * 0.35, radius * 0.15), highlight: errorIndex == 5);
    drawBit('d4', dataBits[3].toString(), center, highlight: errorIndex == 6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
