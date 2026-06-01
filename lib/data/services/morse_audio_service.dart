import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/models/morse_code_data.dart';
import '../../domain/models/audio_settings.dart';

class MorseAudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioSettings settings = AudioSettings();
  bool _stopRequested = false;
  bool _isPlaying = false;
  final ValueNotifier<bool> isEmittingSound = ValueNotifier<bool>(false);

  bool get isPlaying => _isPlaying;

  Future<void> init() async {
    await settings.load();
  }

  Future<void> playMorseCode(String morseString) async {
    if (_isPlaying) return;
    _isPlaying = true;
    _stopRequested = false;

    try {
      await _audioPlayer.setVolume(settings.volume);

      for (String word in morseString.split('/')) {
        if (_stopRequested) break;
        for (String letter in word.split(' ')) {
          if (_stopRequested) break;
          if (letter.isEmpty) continue;
          for (String symbol in letter.split('')) {
            if (_stopRequested) break;
            if (symbol == '.') {
              isEmittingSound.value = true;
              await _audioPlayer.play(AssetSource('audios/short_beep.mp3'));
              await _delay(settings.dotDuration);
              isEmittingSound.value = false;
            } else if (symbol == '-') {
              isEmittingSound.value = true;
              await _audioPlayer.play(AssetSource('audios/long_beep.mp3'));
              await _delay(settings.dashDuration);
              isEmittingSound.value = false;
            }
            if (_stopRequested) break;
            await _delay(settings.symbolGap);
          }
          if (_stopRequested) break;
          await _delay(settings.letterGap);
        }
        if (_stopRequested) break;
        await _delay(settings.wordGap);
      }
    } finally {
      _isPlaying = false;
      isEmittingSound.value = false;
    }
  }

  Future<void> playCharacter(String character) async {
    final morse = MorseCodeData.morseCodeMap[character.toUpperCase()];
    if (morse == null || morse == '/') return;
    if (_isPlaying) return;
    _isPlaying = true;
    _stopRequested = false;

    try {
      await _audioPlayer.setVolume(settings.volume);

      for (String symbol in morse.split('')) {
        if (_stopRequested) break;
        if (symbol == '.') {
          isEmittingSound.value = true;
          await _audioPlayer.play(AssetSource('audios/short_beep.mp3'));
          await _delay(settings.dotDuration);
          isEmittingSound.value = false;
        } else if (symbol == '-') {
          isEmittingSound.value = true;
          await _audioPlayer.play(AssetSource('audios/long_beep.mp3'));
          await _delay(settings.dashDuration);
          isEmittingSound.value = false;
        }
        if (_stopRequested) break;
        await _delay(settings.symbolGap);
      }
    } finally {
      _isPlaying = false;
      isEmittingSound.value = false;
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    await _audioPlayer.stop();
    _isPlaying = false;
    isEmittingSound.value = false;
  }

  Future<void> _delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  void dispose() {
    _audioPlayer.dispose();
    isEmittingSound.dispose();
  }
}
