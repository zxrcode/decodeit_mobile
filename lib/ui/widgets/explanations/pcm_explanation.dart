import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PcmExplanation extends StatelessWidget {
  const PcmExplanation({super.key});

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
              const Icon(Icons.graphic_eq, color: Colors.cyanAccent),
              const SizedBox(width: 12),
              Text(
                'PCM Дыбыс кодтау',
                style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.cyanAccent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogic('Дискреттеу (Sampling)', 'Аналогты толқынды уақыт бойынша нүктелерге бөлу. Жиілік (Hz) жоғары болса, нүктелер көп болады.', Icons.more_horiz),
          _buildLogic('Кванттау (Quantization)', 'Әр нүктенің биіктігін биттермен кодтау. Бит саны жоғары болса, дыбыс сапалы болады.', Icons.format_list_numbered),
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

  Widget _buildLogic(String title, String desc, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.cyanAccent),
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
