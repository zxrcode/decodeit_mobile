import 'package:shared_preferences/shared_preferences.dart';

class AudioSettings {
  static const _keyWpm = 'audio_wpm';
  static const _keyVolume = 'audio_volume';

  double wpm;
  double volume;

  AudioSettings({this.wpm = 15, this.volume = 1.0});

  int get unitDurationMs => (60 / (wpm * 50) * 1000).round();
  int get dotDuration => unitDurationMs;
  int get dashDuration => unitDurationMs * 3;
  int get symbolGap => unitDurationMs;
  int get letterGap => unitDurationMs * 3;
  int get wordGap => unitDurationMs * 7;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    wpm = prefs.getDouble(_keyWpm) ?? 15;
    volume = prefs.getDouble(_keyVolume) ?? 1.0;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyWpm, wpm);
    await prefs.setDouble(_keyVolume, volume);
  }
}
