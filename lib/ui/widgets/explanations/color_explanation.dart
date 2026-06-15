import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ColorExplanation extends StatelessWidget {
  const ColorExplanation({super.key});

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
              const Icon(Icons.palette, color: Colors.pinkAccent),
              const SizedBox(width: 12),
              Text(
                'Түс модельдері',
                style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildItem('RGB (Аддитивті)', 'Экранда қолданылады. Түстер — қызыл, жасыл, көк жарық сәулелерінің қосындысы. Барлығын қосса — Ақ түс.', Icons.light_mode),
          _buildItem('CMYK (Субтрактивті)', 'Баспада қолданылады. Бояулар жарықты жұтады. Барлығын қосса — Қара түс.', Icons.print),
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

  Widget _buildItem(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.pinkAccent),
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
