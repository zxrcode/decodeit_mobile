import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/web_audio_fallback.dart' if (dart.library.io) '../../core/utils/web_audio_stub.dart';

class SoundGeneratorService {
  bool _isInitialized = false;
  AudioSource? _sineSource;
  SoundHandle? _soundHandle;
  double _lastFreq = 440.0;

  Future<void> init() async {
    if (kIsWeb) return; // Use standard Web Audio on web without Soloud
    if (_isInitialized) return;
    try {
      await SoLoud.instance.init();
      _isInitialized = true;
    } catch (e) {
      debugPrint('SoLoud init error: $e');
    }
  }

  Future<void> start() async {
    if (kIsWeb) {
      WebAudioHelper.start(_lastFreq);
      return;
    }

    if (!_isInitialized) await init();
    if (_soundHandle != null) return;

    try {
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
    if (kIsWeb) {
      WebAudioHelper.stop();
      return;
    }

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
    _lastFreq = freq;
    if (kIsWeb) {
      WebAudioHelper.setFrequency(freq);
      return;
    }

    if (_sineSource != null) {
      SoLoud.instance.setWaveformFreq(_sineSource!, freq);
    }
  }

  bool get isPlaying {
    if (kIsWeb) return WebAudioHelper.isPlaying;
    return _soundHandle != null;
  }

  void dispose() {
    stop();
    if (!kIsWeb) SoLoud.instance.deinit();
  }
}
