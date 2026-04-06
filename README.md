# Decode It! Mobile (Encoderinfo)

A universal encoding, decoding, hashing, and cryptography toolkit — all in one Flutter app. Supports **Android**, **iOS**, and **Web**.

> The UI language is **Kazakh (Қазақша)** with some English labels.

---

## 📱 Features

### 🔐 Encoding & Decoding

| Tool | Description |
|------|-------------|
| **Base64** | Encode and decode Base64 strings with auto-detection |
| **URL Encoding** | Encode and decode URL-safe strings (`%XX` format) |
| **ASCII / Binary** | Convert text to ASCII codes and binary (0/1), and back |

### 🔑 Cryptography & Hashing

| Tool | Description |
|------|-------------|
| **Hash Generator** | Generate MD5, SHA-1, SHA-256 hashes of any text |
| **Password Strength** | Evaluates password strength: very weak → strong |
| **Steganography** | Hide secret messages inside images using LSB (Least Significant Bit) encoding with optional AES-CBC encryption |

### 📷 QR & Barcode

| Tool | Description |
|------|-------------|
| **QR Generator** | Create QR codes from text with copy/share support |
| **QR Scanner** | Scan QR codes and barcodes using the device camera |

### 📡 Developer Tools

| Tool | Description |
|------|-------------|
| **Timestamp Converter** | Convert Unix timestamps ↔ human-readable dates with live clock |
| **IP Information** | Look up IP address details (country, city, ISP) via ip-api.com |

### 🎵 Morse Code

| Tool | Description |
|------|-------------|
| **Translator** | Bidirectional text ↔ Morse code conversion with audio playback. Supports letters, numbers, and punctuation. Adjustable speed (WPM) and volume. Includes quick example chips (SOS, HELP, etc.) |
| **Reference Chart** | Complete Morse code lookup table with category tabs (Alphabet, Numbers, Punctuation). Tap the play button on any row to hear the code |
| **Practice Mode** | Quiz-based learning with progress tracking per character. Features dot/dash input buttons, hide-target mode, and CSV export of your progress |

### 🖼️ Graphics Lab

| Tool | Description |
|------|-------------|
| **Pixel Grid** | Interactive 8×8 grid (64 cells). Tap cells to toggle between 0 and 1. Visualize how bitmap/raster graphics work at the bit level. Outputs the binary array representation |

---

## 🏗️ Architecture

```
lib/
├── core/
│   └── di.dart                          # GetIt service locator
├── data/
│   └── services/
│       ├── api_service.dart             # IP info lookup (ip-api.com)
│       ├── crypto_service.dart          # MD5, SHA-1, SHA-256, password strength
│       ├── encoding_service.dart        # Base64, URL, Binary, ASCII encode/decode
│       ├── history_service.dart         # SharedPreferences persistence (max 10 items)
│       ├── timestamp_service.dart       # Unix timestamp ↔ DateTime
│       └── morse_audio_service.dart     # Morse code audio playback
├── domain/
│   └── models/
│       ├── history_item.dart            # History entry model
│       ├── ip_info.dart                 # IP info model
│       ├── morse_code_data.dart         # Morse code maps & conversion utilities
│       └── audio_settings.dart          # WPM + volume, persisted settings
├── ui/
│   ├── screens/
│   │   ├── main_screen.dart             # Bottom nav + home grid (13 tools)
│   │   ├── history_screen.dart          # History list with copy/share/delete
│   │   ├── graphics_lab_screen.dart     # 8×8 pixel grid
│   │   ├── morse_translator_screen.dart # Text ↔ Morse with audio
│   │   ├── morse_chart_screen.dart      # Morse reference chart
│   │   ├── morse_learn_screen.dart      # Quiz/practice mode
│   │   ├── morse_settings_screen.dart   # Morse audio settings (unused)
│   │   ├── steganography_screen.dart    # Image steganography encode/decode
│   │   └── tools/
│   │       ├── qr_tool_screen.dart      # QR generator + scanner
│   │       ├── crypto_tool_screen.dart  # Hash generator + password strength
│   │       ├── encoders_tool_screen.dart # Base64 / URL / ASCII-Binary
│   │       └── dev_tool_screen.dart     # Timestamp + IP info
│   ├── theme/
│   │   └── app_theme.dart              # Material 3, deepPurple seed, light + dark
│   └── widgets/
│       ├── custom_text_field.dart       # Reusable text field with action buttons
│       └── morse_reference_table.dart   # Reusable Morse code table
└── main.dart                           # Entry point
```

### Dependency Injection

Uses **GetIt** for service locator registration. All services are lazy singletons registered in `core/di.dart`.

### State Management

All screens use local `setState`. No provider/Riverpod/Bloc is used despite `provider` being declared in `pubspec.yaml`.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `qr_flutter` | ^4.1.0 | QR code generation |
| `mobile_scanner` | ^7.2.0 | Camera-based QR/barcode scanning |
| `crypto` | ^3.0.7 | MD5, SHA-1, SHA-256 hashing, key derivation |
| `encrypt` | ^5.0.1 | AES-CBC encryption for steganography |
| `image` | ^4.5.4 | Pixel-level image manipulation (LSB encoding) |
| `image_picker` | ^1.2.1 | Picking images from gallery |
| `audioplayers` | ^6.1.2 | Morse code audio playback |
| `shared_preferences` | ^2.5.4 | Persisting history and audio settings |
| `get_it` | ^9.2.1 | Service locator (DI) |
| `share_plus` | ^12.0.1 | Sharing results (QR, hashes, text) |
| `clipboard` | ^3.0.14 | Copying text to clipboard |
| `path_provider` | ^2.1.5 | Filesystem paths for saving images |
| `http` | ^1.6.0 | HTTP requests (IP info API) |
| `intl` | ^0.20.2 | Date/time formatting |
| `gal` | ^2.3.2 | Gallery save (unused) |
| `permission_handler` | ^12.0.1 | Runtime permissions (unused) |
| `google_fonts` | ^6.1.0 | Custom fonts (unused) |
| `provider` | ^6.1.5+1 | State management (unused) |
| `cupertino_icons` | ^1.0.8 | iOS-style icons |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.11.0
- **Dart SDK** ≥ 3.11.0
- **Android Studio** / **Xcode** (for mobile development)

### Installation

```bash
# Clone or navigate to the project
cd Encoderinfo

# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Run on web
flutter run -d chrome

# Build for Android
flutter build apk

# Build for Web
flutter build web
```

### Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| **Android** | ✅ Supported | Min SDK per Flutter defaults |
| **iOS** | ✅ Supported | Portrait + Landscape |
| **Web** | ✅ Supported | Steganography uses browser download for saved images |

> **Note:** The `dart:html` import in `steganography_screen.dart` is web-only. On Android/iOS, the `kIsWeb` check routes to `path_provider` instead, so the code works on all platforms despite the warning.

---

## 🧩 Feature Details

### Steganography

Uses **LSB (Least Significant Bit)** steganography to hide messages in the red channel of PNG images:

1. **Encoding flow:**
   - Message is UTF-8 encoded
   - 4-byte length prefix (big-endian) is prepended
   - Optional: AES-CBC encryption with SHA-256 derived 16-byte key
   - Each bit is embedded into the LSB of pixel red channel values
   - Output: PNG file (downloaded on web, saved to filesystem on mobile)

2. **Decoding flow:**
   - First 32 pixel LSBs → message length
   - Next `length × 8` pixel LSBs → message bytes
   - Optional: AES-CBC decryption with user-provided key
   - Display decoded text

> ⚠️ **Security note:** The AES-CBC implementation uses a zero-initialized IV, which is cryptographically weak. For production use, generate a random IV per encryption.

### Morse Code Audio

- **Timing** follows standard International Morse Code conventions:
  - Dot = 1 unit
  - Dash = 3 units
  - Symbol gap = 1 unit
  - Letter gap = 3 units
  - Word gap = 7 units
- **Speed** is adjustable via WPM (Words Per Minute), range 5–50 (default: 15)
- **Audio files:** `assets/audios/short_beep.mp3` (dot), `assets/audios/long_beep.mp3` (dash)

### History

- Stores the **last 10** operations across all tools
- Each entry: title, details, timestamp, type (QR/Hash/Encode/Decode/Dev)
- Actions: copy to clipboard, share, delete individual or clear all
- Persisted via `SharedPreferences`

---

## 🎨 Theming

- **Material 3** design
- Seed color: `deepPurple`
- **Light theme** and **dark theme** (follows system setting)
- Rounded corners on cards and inputs
- Color-coded tool icons in the home grid

---

## 🌐 APIs

| API | URL | Protocol | Purpose |
|-----|-----|----------|---------|
| ip-api.com | `http://ip-api.com/json/` | HTTP (not HTTPS) | IP geolocation lookup |

> ⚠️ The IP API uses plain HTTP. For production, consider using `https://ip-api.com/json/` or a self-hosted alternative.

---

## 📁 Assets

```
assets/
└── audios/
    ├── short_beep.mp3    # Morse dot sound
    └── long_beep.mp3     # Morse dash sound
```

---

## 📝 License

This project was assembled as a personal/educational project. Individual components may have their own licensing considerations.

---

## 🐛 Known Issues & Limitations

1. **History limited to 10 items** — May feel restrictive for heavy users
2. **Unused dependencies** — `provider`, `google_fonts`, `permission_handler`, `gal` are declared but not imported
3. **`MorseSettingsScreen` is dead code** — Never navigated to from anywhere in the app
4. **AES-CBC zero IV** — Cryptographic weakness; use random IVs in production
5. **HTTP (not HTTPS)** for ip-api.com — Should use HTTPS in production
6. **`dart:html` deprecation** — Flutter recommends `package:web` for new projects, but `dart:html` still works
