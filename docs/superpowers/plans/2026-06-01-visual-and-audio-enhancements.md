# Visual and Audio Enhancements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add real-time audio synthesis to the PCM visualizer, a "scrambling" text animation for hashes/encodings, and a "laser scanner" overlay for steganography processing.

**Architecture:** 
- New `SoundGeneratorService` for low-level audio buffer management.
- Reusable `ScrambledText` widget using `AnimationController`.
- `LaserScannerOverlay` using `CustomPainter` and `ValueNotifier` for progress tracking.

**Tech Stack:** 
- Flutter (Dart)
- `sound_generator` (for real-time PCM)
- `flutter_animate` (optional, but we'll stick to native AnimationController for better control)

---

### Task 1: Setup Dependencies and Audio Service

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/data/services/sound_generator_service.dart`

- [ ] **Step 1: Add dependencies**
Add `sound_generator: ^1.0.1` to `pubspec.yaml`.

- [ ] **Step 2: Implement SoundGeneratorService**
```dart
import 'dart:math';
import 'package:sound_generator/sound_generator.dart';

class SoundGeneratorService {
  bool _isPlaying = false;
  double _frequency = 440.0;
  int _bitDepth = 16;
  int _sampleRate = 44100;

  Future<void> init() async {
    await SoundGenerator.init(sampleRate: _sampleRate);
    SoundGenerator.setWaveType(waveType: WaveType.SINUSOIDAL);
  }

  void start() {
    SoundGenerator.play();
    _isPlaying = true;
  }

  void stop() {
    SoundGenerator.stop();
    _isPlaying = false;
  }

  void setFrequency(double freq) => SoundGenerator.setFrequency(freq);
  
  // Simulation of low bit depth by manual quantization isn't directly 
  // supported by sound_generator easily, so we might modulate volume or pitch
  // to simulate "grittiness" if needed, but for now we'll focus on tone.
}
```

- [ ] **Step 3: Commit**
`git add pubspec.yaml lib/data/services/sound_generator_service.dart && git commit -m "feat: add sound_generator dependency and service"`

### Task 2: PCM Visualizer Audio Integration

**Files:**
- Modify: `lib/ui/screens/pcm_visualizer_screen.dart`

- [ ] **Step 1: Integrate audio service into PCM Screen**
Update `_togglePlay` to start/stop the audio.

- [ ] **Step 2: Commit**
`git commit -m "feat: integrate audio into PCM visualizer"`

### Task 3: ScrambledText Widget

**Files:**
- Create: `lib/ui/widgets/scrambled_text.dart`

- [ ] **Step 1: Create ScrambledText Widget**
```dart
import 'dart:math';
import 'package:flutter/material.dart';

class ScrambledText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const ScrambledText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<ScrambledText> createState() => _ScrambledTextState();
}

class _ScrambledTextState extends State<ScrambledText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        String displayedText = '';
        double progress = _controller.value;
        for (int i = 0; i < widget.text.length; i++) {
          if (progress > (i / widget.text.length)) {
            displayedText += widget.text[i];
          } else {
            displayedText += _chars[_random.nextInt(_chars.length)];
          }
        }
        return Text(displayedText, style: widget.style);
      },
    );
  }
}
```

- [ ] **Step 2: Commit**
`git commit -m "feat: add ScrambledText widget"`

### Task 4: Apply ScrambledText to Tools

**Files:**
- Modify: `lib/ui/screens/tools/crypto_tool_screen.dart`
- Modify: `lib/ui/screens/tools/encoders_tool_screen.dart`

- [ ] **Step 1: Use ScrambledText for hash results and encoding outputs.**
- [ ] **Step 2: Commit**
`git commit -m "feat: apply ScrambledText to crypto and encoder tools"`

### Task 5: Laser Scanner Overlay for Steganography

**Files:**
- Create: `lib/ui/widgets/laser_scanner_overlay.dart`
- Modify: `lib/ui/screens/steganography_screen.dart`

- [ ] **Step 1: Create LaserScannerOverlay Widget**
- [ ] **Step 2: Replace HudLoadingOverlay in SteganographyScreen**
- [ ] **Step 3: Commit**
`git commit -m "feat: add laser scanner overlay to steganography"`
