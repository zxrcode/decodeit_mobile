import 'package:flutter/foundation.dart';
import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';

class SoundGeneratorService {
  bool _isPlaying = false;
  double _frequency = 440.0;
  final int _sampleRate = 44100;

  Future<void> init() async {
    if (kIsWeb) return; // sound_generator does not support web
    await SoundGenerator.init(_sampleRate);
    SoundGenerator.setWaveType(waveTypes.SINUSOIDAL);
    SoundGenerator.setVolume(0.5); // Start with safe volume
  }

  void start() {
    if (kIsWeb || _isPlaying) return;
    SoundGenerator.play();
    _isPlaying = true;
  }

  void stop() {
    if (kIsWeb || !_isPlaying) return;
    SoundGenerator.stop();
    _isPlaying = false;
  }

  void setFrequency(double freq) {
    if (kIsWeb) return;
    _frequency = freq;
    SoundGenerator.setFrequency(_frequency);
  }

  bool get isPlaying => _isPlaying;
}
