import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HammingExplanation extends StatelessWidget {
  const HammingExplanation({super.key});

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
              const Icon(Icons.shield, color: Colors.blueAccent),
              const SizedBox(width: 12),
              Text(
                'Хэмминг коды қалай жұмыс істейді?',
                style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Бұл алгоритм деректерді шулы арналар арқылы жібергенде пайда болатын қателерді түзету үшін қолданылады.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildFeature('Бақылау биттері', 'Деректердің белгілі бір топтары үшін жұптықты (parity) тексеретін қосымша биттер.', Icons.visibility),
          _buildFeature('Қатені анықтау', 'Егер бір бит өзгерсе, бақылау биттерінің жиынтығы қатенің нақты орнын көрсетеді.', Icons.bug_report),
          _buildFeature('Авто-түзету', 'Қате табылғаннан кейін оны жай ғана теріске айналдыру (0->1) арқылы түзетуге болады.', Icons.auto_fix_high),
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

  Widget _buildFeature(String title, String desc, IconData icon) {
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent, fontSize: 13)),
                Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
