import 'package:flutter/material.dart';
import '../../data/services/morse_audio_service.dart';

class MorseSettingsScreen extends StatefulWidget {
  final MorseAudioService audioService;

  const MorseSettingsScreen({super.key, required this.audioService});

  @override
  State<MorseSettingsScreen> createState() => _MorseSettingsScreenState();
}

class _MorseSettingsScreenState extends State<MorseSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = widget.audioService.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Morse Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio settings
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volume_up,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Audio',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Speed: ${settings.wpm.round()} WPM'),
                  Slider(
                    value: settings.wpm,
                    min: 5,
                    max: 50,
                    divisions: 45,
                    label: '${settings.wpm.round()} WPM',
                    onChanged: (value) {
                      setState(() => settings.wpm = value);
                      settings.save();
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('Volume: ${(settings.volume * 100).round()}%'),
                  Slider(
                    value: settings.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(settings.volume * 100).round()}%',
                    onChanged: (value) {
                      setState(() => settings.volume = value);
                      settings.save();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
