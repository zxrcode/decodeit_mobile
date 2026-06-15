import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpectrogramExplanation extends StatelessWidget {
  const SpectrogramExplanation({super.key});

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
              const Icon(Icons.waves, color: Colors.yellowAccent),
              const SizedBox(width: 12),
              Text(
                'Спектрограмма деген не?',
                style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.yellowAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep('Уақыт пен Жиілік', 'Төменгі жағы — уақыт, биіктігі — жиілік (Hz). Түстер дыбыс күшін білдіреді.', Icons.timer),
          _buildStep('Аудио-стеганография', 'Дыбыс спектріне арнайы жиіліктерді қосу арқылы визуалды хабарлама жасыруға болады.', Icons.visibility_off),
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
          Icon(icon, size: 18, color: Colors.yellowAccent),
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
