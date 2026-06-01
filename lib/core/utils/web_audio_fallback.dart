import 'dart:js_interop';

@JS('AudioContext')
extension type AudioContext._(JSObject _) implements JSObject {
  external AudioContext();
  external OscillatorNode createOscillator();
  external GainNode createGain();
  external AudioDestinationNode get destination;
  external JSPromise<JSAny?> resume();
}

@JS('OscillatorNode')
extension type OscillatorNode._(JSObject _) implements JSObject {
  external AudioParam get frequency;
  external void start();
  external void stop();
  external void connect(AudioNode destination);
  external set type(String value);
}

@JS('GainNode')
extension type GainNode._(JSObject _) implements AudioNode {
  external AudioParam get gain;
}

@JS('AudioNode')
extension type AudioNode._(JSObject _) implements JSObject {
  external void connect(AudioNode destination);
}

@JS('AudioDestinationNode')
extension type AudioDestinationNode._(JSObject _) implements AudioNode {}

@JS('AudioParam')
extension type AudioParam._(JSObject _) implements JSObject {
  external set value(double value);
}

class WebAudioHelper {
  static AudioContext? _context;
  static OscillatorNode? _oscillator;
  static GainNode? _gainNode;

  static void start(double frequency) {
    _context ??= AudioContext();
    _context!.resume();

    _oscillator?.stop();
    _oscillator = _context!.createOscillator();
    _gainNode = _context!.createGain();

    _oscillator!.type = 'sine';
    _oscillator!.frequency.value = frequency;
    _gainNode!.gain.value = 0.1; // Low volume

    _oscillator!.connect(_gainNode!);
    _gainNode!.connect(_context!.destination);

    _oscillator!.start();
  }

  static void setFrequency(double frequency) {
    _oscillator?.frequency.value = frequency;
  }

  static bool get isPlaying => _oscillator != null;

  static void stop() {
    try {
      _oscillator?.stop();
    } catch (_) {}
    _oscillator = null;
  }
}
