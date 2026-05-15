import 'package:flutter/material.dart';
import '../../domain/models/morse_code_data.dart';
import '../../data/services/morse_audio_service.dart';
import '../widgets/morse_reference_table.dart';

enum ChartCategory { alphabet, numbers, punctuation }

class MorseChartScreen extends StatefulWidget {
  final MorseAudioService audioService;

  const MorseChartScreen({super.key, required this.audioService});

  @override
  State<MorseChartScreen> createState() => _MorseChartScreenState();
}

class _MorseChartScreenState extends State<MorseChartScreen> {
  ChartCategory _category = ChartCategory.alphabet;

  Map<String, String> get _currentData {
    switch (_category) {
      case ChartCategory.alphabet:
        return MorseCodeData.alphabetMap;
      case ChartCategory.numbers:
        return MorseCodeData.numberMap;
      case ChartCategory.punctuation:
        return MorseCodeData.punctuationMap;
    }
  }

  String get _characterLabel {
    switch (_category) {
      case ChartCategory.alphabet:
        return 'Таңба';
      case ChartCategory.numbers:
        return 'Сан';
      case ChartCategory.punctuation:
        return 'Символ';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Морзе коды кестесі'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Wrap(
              spacing: 8,
              children: ChartCategory.values.map((cat) {
                String label = '';
                switch (cat) {
                  case ChartCategory.alphabet:
                    label = 'Әліпби';
                  case ChartCategory.numbers:
                    label = 'Сандар';
                  case ChartCategory.punctuation:
                    label = 'Тыныс белгілері';
                }
                return ChoiceChip(
                  label: Text(label),
                  selected: _category == cat,
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat);
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: MorseReferenceTable(
              data: _currentData,
              characterLabel: _characterLabel,
              getSoundDescription: MorseCodeData.getMorseSound,
              onPlayPressed: (character) =>
                  widget.audioService.playCharacter(character),
            ),
          ),
        ],
      ),
    );
  }
}
