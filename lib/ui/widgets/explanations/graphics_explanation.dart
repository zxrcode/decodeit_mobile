import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GraphicsExplanation extends StatelessWidget {
  const GraphicsExplanation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_4x4, color: Colors.greenAccent),
              const SizedBox(width: 12),
              Text(
                'Графика қалай кодталады?',
                style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.greenAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetail('1-бит (Екілік)', 'Әр пиксель не 0 (қара), не 1 (ақ) болады. Сондықтан код тек 0 мен 1-лерден тұрады.', Icons.looks_one),
          _buildDetail('8-бит (Grayscale)', 'Әр пиксель 0-ден 255-ке дейінгі санмен белгіленеді. 0 - қара, 255 - ақ.', Icons.gradient),
          _buildDetail('RLE Сығу', 'Қатар тұрған бірдей пикселдерді санау арқылы кодты қысқарту (мысалы, 5x[1] орнына 11111).', Icons.compress),
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

  Widget _buildDetail(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
