# Design Spec - Visual and Audio Enhancements

This document outlines the design and implementation details for adding real-time audio synthesis, scrambling text animations, and a laser scanner visualization to the Encoderinfo application.

## 1. PCM Audio Synthesis

### Problem
The current PCM visualizer is purely visual. Adding sound would provide a multi-sensory understanding of how Sampling Rate and Bit Depth affect audio quality.

### Solution
Implement real-time audio generation that mirrors the visual sine wave.

- **Audio Engine**: Use the `sound_generator` package (to be added) or modulate `audioplayers` if suitable for real-time tone generation.
- **Parameters**:
  - **Frequency**: Mapped to the visual wave frequency (fixed at 1.5 cycles in the current painter).
  - **Bit Depth Simulation**: Quantize the generated audio samples to match the selected bit depth (2, 3, or 4 bits), introducing audible quantization noise.
  - **Sampling Rate Simulation**: Adjust the audio playback to reflect the sampling rate (though this is more complex, we will focus on the audible "grittiness" of low bit depths).

## 2. Scrambling Text Animation

### Problem
Hashing and encoding results appear instantly, which lacks visual "impact" and doesn't convey the complexity of the transformation.

### Solution
Create a reusable `ScrambledText` widget.

- **Mechanism**:
  - Takes `targetText`, `duration`, and `characterSet` (e.g., ASCII, Hex, or Binary).
  - Uses an `AnimationController` to cycle characters at each index.
  - Characters "freeze" into their final state from left to right or all at once at the end of the duration.
- **Usage**: Apply to `CryptoToolScreen` (hashes) and `EncodersToolScreen` (Base64/URL results).

## 3. Laser Scanner Steganography Visualization

### Problem
Encoding and decoding images causes a noticeable lag (several seconds) during which the UI feels unresponsive, even with a basic loading spinner.

### Solution
Replace the standard loading overlay with a thematic "Laser Scanner" animation.

- **Visuals**:
  - **Scanning Line**: A horizontal neonic green/blue line that moves up and down the image preview.
  - **Pixel Glitch**: Areas "behind" the scanner line show transient random pixel colors or "0/1" binary fragments.
  - **Status Text**: "Injecting bits...", "Modifying LSB...", "Extracting hidden layer...".
- **Implementation**:
  - A `CustomPainter` overlay that covers the image preview area during processing.
  - The animation will run on the main thread while the `compute` function handles the heavy lifting in a separate isolate.

## 4. Technical Changes

### Dependencies
- Add `sound_generator: ^1.0.1` (or similar) to `pubspec.yaml`.

### Files to Modify/Create
- `lib/ui/widgets/scrambled_text.dart` (New)
- `lib/ui/widgets/stegano_scanner_overlay.dart` (New)
- `lib/ui/screens/pcm_visualizer_screen.dart` (Audio logic)
- `lib/ui/screens/steganography_screen.dart` (Scanner integration)
- `lib/ui/screens/tools/crypto_tool_screen.dart` (Scrambled text)
- `lib/ui/screens/tools/encoders_tool_screen.dart` (Scrambled text)

## 5. Success Criteria
- PCM screen plays a sine wave that sounds "cleaner" at higher bit depths and "grittier" at lower ones.
- Hashes and encoded text reveal themselves through a 1-second scrambling animation.
- Steganography processing shows a "scanning" effect that masks the background processing time.
