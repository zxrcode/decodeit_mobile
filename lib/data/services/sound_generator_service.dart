import 'package:sound_generator/sound_generator.dart';
import 'package:sound_generator/waveTypes.dart';

class SoundGeneratorService {
  bool _isPlaying = false;
  double _frequency = 440.0;
  final int _sampleRate = 44100;

  Future<void> init() async {
    await SoundGenerator.init(sampleRate: _sampleRate);
    SoundGenerator.setWaveType(waveType: waveTypes.SINUSOIDAL);
    SoundGenerator.setVolume(0.5); // Start with safe volume
  }

  void start() {
    if (_isPlaying) return;
    SoundGenerator.play();
    _isPlaying = true;
  }

  void stop() {
    if (!_isPlaying) return;
    SoundGenerator.stop();
    _isPlaying = false;
  }

  void setFrequency(double freq) {
    _frequency = freq;
    SoundGenerator.setFrequency(_frequency);
  }

  bool get isPlaying => _isPlaying;
}
