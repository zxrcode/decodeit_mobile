import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HuffmanExplanation extends StatelessWidget {
  const HuffmanExplanation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Text(
                'Хаффман кодтауы деген не?',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Бұл — деректерді жоғалтсыз сығу алгоритмі. Оның негізгі принципі өте қарапайым:',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          _buildStep(
            '1. Жиілік',
            'Жиі кездесетін әріптерге қысқа код беріледі (мысалы, "А" -> 01).',
            Icons.analytics,
          ),
          _buildStep(
            '2. Ағаш құрылымы',
            'Сирек әріптерге ұзын код беріледі. Осылайша файлдың жалпы өлшемі кішірейеді.',
            Icons.account_tree,
          ),
          const SizedBox(height: 24),
          // Simple Animation/Diagram representation
          Center(
            child: Container(
              height: 120,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: CustomPaint(
                painter: _HuffmanExplanationPainter(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Түсінікті'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HuffmanExplanationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = Colors.cyanAccent;

    // Draw a small symbolic tree
    final top = Offset(size.width / 2, 20);
    final left = Offset(size.width / 2 - 40, 60);
    final right = Offset(size.width / 2 + 40, 60);
    final leftLeft = Offset(size.width / 2 - 60, 100);
    final leftRight = Offset(size.width / 2 - 20, 100);

    canvas.drawLine(top, left, paint);
    canvas.drawLine(top, right, paint);
    canvas.drawLine(left, leftLeft, paint);
    canvas.drawLine(left, leftRight, paint);

    canvas.drawCircle(top, 4, dotPaint);
    canvas.drawCircle(left, 4, dotPaint);
    canvas.drawCircle(right, 4, dotPaint);
    canvas.drawCircle(leftLeft, 4, dotPaint);
    canvas.drawCircle(leftRight, 4, dotPaint);

    // Labels
    _drawText(canvas, "100%", top.translate(0, -15));
    _drawText(canvas, "0", Offset((top.dx + left.dx) / 2 - 10, (top.dy + left.dy) / 2));
    _drawText(canvas, "1", Offset((top.dx + right.dx) / 2 + 10, (top.dy + right.dy) / 2));
    _drawText(canvas, "A", leftLeft.translate(0, 10));
    _drawText(canvas, "B", leftRight.translate(0, 10));
    _drawText(canvas, "C", right.translate(0, 10));
  }

  void _drawText(Canvas canvas, String text, Offset pos) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
