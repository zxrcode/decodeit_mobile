import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';

class SoundGeneratorService {
  bool _isInitialized = false;
  AudioSource? _sineSource;
  SoundHandle? _soundHandle;

  Future<void> init() async {
    if (_isInitialized) return;
    try {
      await SoLoud.instance.init();
      _isInitialized = true;
    } catch (e) {
      debugPrint('SoLoud init error: $e');
    }
  }

  Future<void> start() async {
    if (!_isInitialized) await init();
    if (_soundHandle != null) return;

    try {
      // Create a sine wave source
      _sineSource = await SoLoud.instance.loadWaveform(
        WaveForm.sin,
        false,
        1.0,
        0.0,
      );
      
      _soundHandle = SoLoud.instance.play(_sineSource!);
    } catch (e) {
      debugPrint('SoLoud play error: $e');
    }
  }

  void stop() {
    if (_soundHandle != null) {
      SoLoud.instance.stop(_soundHandle!);
      _soundHandle = null;
    }
    if (_sineSource != null) {
      SoLoud.instance.disposeSource(_sineSource!);
      _sineSource = null;
    }
  }

  void setFrequency(double freq) {
    if (_sineSource != null) {
      SoLoud.instance.setWaveformFreq(_sineSource!, freq);
    }
  }

  bool get isPlaying => _soundHandle != null;

  void dispose() {
    stop();
    SoLoud.instance.deinit();
  }
}
