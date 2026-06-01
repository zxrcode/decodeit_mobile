import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_package;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../../core/utils/file_saver.dart';
import '../../ui/widgets/hud_loading_overlay.dart';
import 'package:google_fonts/google_fonts.dart';

class SteganographyScreen extends StatefulWidget {
  const SteganographyScreen({super.key});

  @override
  State<SteganographyScreen> createState() => _SteganographyScreenState();
}

class _SteganographyScreenState extends State<SteganographyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Encode tab state
  XFile? _encodeImage;
  String _message = '';
  String _key = '';
  bool _isKeyAvailableForEncode = false;

  // Decode tab state
  XFile? _decodeImage;
  String _decodedMessage = '';
  String _decodeKey = '';
  bool _isKeyAvailableForDecode = false;

  // LSB Explainer state
  String _lsbChar = 'A';
  double _lsbRed = 154.0;
  double _lsbGreen = 80.0;
  double _lsbBlue = 212.0;

  bool _isProcessing = false;
  String _processingStatus = 'Өңдеу...';

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isEncode) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isEncode) {
          _encodeImage = pickedFile;
        } else {
          _decodeImage = pickedFile;
        }
      });
    }
  }

  Widget _imagePreview(XFile? image, bool isEncode) {
    if (image == null) {
      return Column(
        children: [
          const Icon(Icons.image, size: 100, color: Colors.grey),
          const SizedBox(height: 8),
          const Text('Сурет таңдалмаған.'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _pickImage(isEncode),
            icon: const Icon(Icons.photo_library),
            label: const Text('Сурет таңдау'),
          ),
        ],
      );
    }
    return Column(
      children: [
        FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.memory(snapshot.data!, width: 200, height: 200, fit: BoxFit.contain);
            }
            return const SizedBox(
              width: 200,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _pickImage(isEncode),
          icon: const Icon(Icons.swap_horiz),
          label: const Text('Суретті өзгерту'),
        ),
      ],
    );
  }


  String _encryptMessage(String message, String key) {
    final keyBytes = utf8.encode(key);
    final hashedKey = sha256.convert(keyBytes).bytes.sublist(0, 16);
    final encrypter = encrypt_package.Encrypter(encrypt_package.AES(
        encrypt_package.Key(Uint8List.fromList(hashedKey)),
        mode: encrypt_package.AESMode.cbc));
    final iv = encrypt_package.IV.fromLength(16);
    final encrypted = encrypter.encrypt(message, iv: iv);
    return base64.encode(encrypted.bytes + iv.bytes);
  }

  String _decryptMessage(String encryptedMessage, String key) {
    final keyBytes = utf8.encode(key);
    final hashedKey = sha256.convert(keyBytes).bytes.sublist(0, 16);
    final encrypter = encrypt_package.Encrypter(encrypt_package.AES(
        encrypt_package.Key(Uint8List.fromList(hashedKey)),
        mode: encrypt_package.AESMode.cbc));
    final decoded = base64.decode(encryptedMessage);
    final iv = encrypt_package.IV(decoded.sublist(decoded.length - 16));
    final encryptedBytes = decoded.sublist(0, decoded.length - 16);
    final encrypted = encrypt_package.Encrypted(encryptedBytes);
    return encrypter.decrypt(encrypted, iv: iv);
  }

  Future<void> _saveImage(Uint8List bytes) async {
    try {
      await saveFile(bytes, 'steganography_image.png');
      if (mounted) {
        String message = kIsWeb
            ? 'Сурет сәтті жүктелді!'
            : 'Сурет құрылғы құжаттарына сақталды (steganography_image.png)';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Файлды сақтау сәтсіз аяқталды: $e')),
        );
      }
    }
  }

  Future<void> _encodeAndSave() async {
    if (_isKeyAvailableForEncode && _key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Шифрлау кілтін енгізіңіз.')),
      );
      return;
    }
    if (_encodeImage == null || _message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сурет таңдап, хабарлама енгізіңіз.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = 'Пикселдерге жазу...';
    });

    try {
      String messageToEncode = _message;
      if (_isKeyAvailableForEncode) {
        messageToEncode = _encryptMessage(_message, _key);
      }

      final imageBytes = await _encodeImage!.readAsBytes();

      // Run heavy pixel manipulation in background isolate
      final encodedImage = await compute(
        _encodeMessageIsolate,
        _EncodeParams(message: messageToEncode, imageBytes: imageBytes),
      );

      await _saveImage(encodedImage);

      // Reset encode tab state
      if (mounted) {
        setState(() {
          _message = '';
          _key = '';
          _isKeyAvailableForEncode = false;
          _encodeImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _doDecode() async {
    if (_isKeyAvailableForDecode && _decodeKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дешифрлау кілтін енгізіңіз.')),
      );
      return;
    }
    if (_decodeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Суретті таңдаңыз.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _processingStatus = 'Жасырын деректерді оқу...';
    });

    try {
      final imageBytes = await _decodeImage!.readAsBytes();

      // Run heavy pixel read in background isolate
      String extractedMessage = await compute(
        _decodeMessageIsolate,
        imageBytes,
      );

      if (_isKeyAvailableForDecode) {
        try {
          extractedMessage = _decryptMessage(extractedMessage, _decodeKey);
        } catch (e) {
          throw Exception('Дешифрлау сәтсіз аяқталды. Кілті қате немесе шифрланбаған.');
        }
      }

      if (mounted) {
        setState(() {
          _decodedMessage = extractedMessage;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Қате: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Стеганография'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(icon: Icon(Icons.image_outlined), text: 'Кодтау'),
                  Tab(icon: Icon(Icons.text_snippet_outlined), text: 'Декодтау'),
                  Tab(icon: Icon(Icons.psychology_outlined), text: 'LSB Түсіндірме'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _encodeTab(),
                    _decodeTab(),
                    _lsbExplanationTab(),
                  ],
                ),
              ),
            ],
          ),
          HudLoadingOverlay(
            isVisible: _isProcessing,
            statusText: _processingStatus,
          ),
        ],
      ),
    );
  }

  Widget _encodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'LSB стеганографиясын пайдаланып, суреттің ішіне жасырын хабарламаны жасырыңыз.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _imagePreview(_encodeImage, true),
            ),
          ),
          if (_encodeImage != null) ...[
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: _encodeImage?.length(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text('Сурет өлшемі: ${(snapshot.data! / 1024).toStringAsFixed(1)} КБ');
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Хабарлама',
              hintText: 'Жасырын хабарламаңызды енгізіңіз...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => setState(() => _message = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isKeyAvailableForEncode,
                onChanged: (value) {
                  setState(() => _isKeyAvailableForEncode = value!);
                },
              ),
              const Text('Кілтпен шифрлау'),
            ],
          ),
          if (_isKeyAvailableForEncode)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Шифрлау кілті',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _key = value),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _encodeAndSave,
              icon: const Icon(Icons.save),
              label: const Text('Кодтау және суретті сақтау'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Стеганографиялық суреттен жасырын хабарламаны шығарып алыңыз.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _imagePreview(_decodeImage, false),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isKeyAvailableForDecode,
                onChanged: (value) {
                  setState(() => _isKeyAvailableForDecode = value!);
                },
              ),
              const Text('Кілтпен дешифрлау'),
            ],
          ),
          if (_isKeyAvailableForDecode)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Дешифрлау кілті',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _decodeKey = value),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _doDecode,
              icon: const Icon(Icons.lock_open),
              label: const Text('Суретті декодтау'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          if (_decodedMessage.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.message, color: Theme.of(context).colorScheme.onPrimaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'Декодталған хабарлама:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _decodedMessage,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _charToBinary(String char) {
    if (char.isEmpty) return '00000000';
    final code = char.codeUnitAt(0);
    return code.toRadixString(2).padLeft(8, '0');
  }

  int _modifyLsb(int val, int bit) {
    return (val & ~1) | bit;
  }

  Widget _lsbExplanationTab() {
    final theme = Theme.of(context);
    final charBinary = _charToBinary(_lsbChar);
    final int rOrig = _lsbRed.round();
    final int gOrig = _lsbGreen.round();
    final int bOrig = _lsbBlue.round();

    final int rBit = int.parse(charBinary[0]);
    final int gBit = int.parse(charBinary[1]);
    final int bBit = int.parse(charBinary[2]);

    final int rMod = _modifyLsb(rOrig, rBit);
    final int gMod = _modifyLsb(gOrig, gBit);
    final int bMod = _modifyLsb(bOrig, bBit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.visibility_off, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'LSB (Least Significant Bit) қалай жұмыс істейді?',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Стеганографияда құпия хабарламаның биттері сурет пикселінің RGB түстерінің ең соңғы (кіші) биттеріне жазылады.',
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Жасыру үшін таңба енгізіңіз:', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextField(
                          maxLength: 1,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: _lsbChar)..selection = TextSelection.fromPosition(TextPosition(offset: _lsbChar.length)),
                          onChanged: (val) {
                            if (val.isNotEmpty) {
                              setState(() {
                                _lsbChar = val;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ASCII коды: ${_lsbChar.isEmpty ? 0 : _lsbChar.codeUnitAt(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Екілік жүйеде: $charBinary',
                              style: GoogleFonts.firaCode(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('2. Пиксель түсін баптаңыз (RGB):', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _colorSlider('Қызыл (Red): $rOrig', _lsbRed, Colors.red, (v) => setState(() => _lsbRed = v)),
                  _colorSlider('Жасыл (Green): $gOrig', _lsbGreen, Colors.green, (v) => setState(() => _lsbGreen = v)),
                  _colorSlider('Көк (Blue): $bOrig', _lsbBlue, Colors.blue, (v) => setState(() => _lsbBlue = v)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('3. Соңғы биттерді ауыстыру процесі', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildLsbStepRow('Red арнасы', rOrig, rBit, rMod, Colors.red),
                  const SizedBox(height: 8),
                  _buildLsbStepRow('Green арнасы', gOrig, gBit, gMod, Colors.green),
                  const SizedBox(height: 8),
                  _buildLsbStepRow('Blue арнасы', bOrig, bBit, bMod, Colors.blue),
                  const Divider(height: 24, color: Colors.white24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Бастапқы түс', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, rOrig, gOrig, bOrig),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('($rOrig, $gOrig, $bOrig)', style: GoogleFonts.firaCode(fontSize: 10)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            const Text('Модификацияланған түс', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, rMod, gMod, bMod),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('($rMod, $gMod, $bMod)', style: GoogleFonts.firaCode(fontSize: 10)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Көріп тұрғаныңыздай, екі түс бір-бірінен мүлдем ажыратылмайды!',
                    style: TextStyle(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _colorSlider(String label, double val, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Slider(
          value: val,
          min: 0,
          max: 255,
          activeColor: color,
          inactiveColor: color.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildLsbStepRow(String title, int orig, int bit, int mod, Color color) {
    final origBin = orig.toRadixString(2).padLeft(8, '0');
    final modBin = mod.toRadixString(2).padLeft(8, '0');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Text('Бастапқы: ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                Text(origBin.substring(0, 7), style: GoogleFonts.firaCode(fontSize: 11)),
                Text(origBin.substring(7), style: GoogleFonts.firaCode(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('Енгізілген бит: ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                Text('$bit', style: GoogleFonts.firaCode(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Text('Нәтиже: ', style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                Text(modBin.substring(0, 7), style: GoogleFonts.firaCode(fontSize: 11)),
                Text(modBin.substring(7), style: GoogleFonts.firaCode(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        )
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Top-level helpers required by compute() – must be outside class
// ────────────────────────────────────────────────────────────────

class _EncodeParams {
  final String message;
  final Uint8List imageBytes;
  _EncodeParams({required this.message, required this.imageBytes});
}

/// Runs in a separate isolate – encodes [params.message] into the image
/// and returns the resulting PNG bytes.
Uint8List _encodeMessageIsolate(_EncodeParams params) {
  final image = img.decodeImage(params.imageBytes);
  if (image == null) {
    throw Exception('Суретті декодтау мүмкін болмады.');
  }

  var messageBytes = Uint8List.fromList(utf8.encode(params.message));
  var lengthBytes = Uint8List(4)
    ..buffer.asByteData().setUint32(0, messageBytes.length, Endian.big);
  var allBytes = Uint8List.fromList([...lengthBytes, ...messageBytes]);

  final totalPixels = image.width * image.height;
  if (allBytes.length * 8 > totalPixels) {
    throw ArgumentError('Хабарлама бұл сурет үшін тым ұзын.');
  }

  final clonedImage = image.clone();
  int bitIndex = 0;
  for (var y = 0; y < clonedImage.height && bitIndex < allBytes.length * 8; y++) {
    for (var x = 0; x < clonedImage.width && bitIndex < allBytes.length * 8; x++) {
      var pixel = clonedImage.getPixel(x, y);
      var bit = (allBytes[bitIndex ~/ 8] >> (bitIndex % 8)) & 1;
      var r = pixel.r.toInt();
      r = (r & ~1) | bit;
      clonedImage.setPixelRgba(x, y, r, pixel.g.toInt(), pixel.b.toInt(), pixel.a.toInt());
      bitIndex++;
    }
  }
  return Uint8List.fromList(img.encodePng(clonedImage));
}

/// Runs in a separate isolate – extracts the hidden message from the image.
String _decodeMessageIsolate(Uint8List imageBytes) {
  final image = img.decodeImage(imageBytes);
  if (image == null) {
    throw Exception('Суретті декодтау мүмкін болмады.');
  }

  // Read length (first 32 bits from red channel LSB)
  var lengthBytes = Uint8List(4);
  int bitIndex = 0;
  for (var y = 0; y < image.height && bitIndex < 32; y++) {
    for (var x = 0; x < image.width && bitIndex < 32; x++) {
      var pixel = image.getPixel(x, y);
      lengthBytes[bitIndex ~/ 8] |= (pixel.r.toInt() & 1) << (bitIndex % 8);
      bitIndex++;
    }
  }

  var messageLength = lengthBytes.buffer.asByteData().getUint32(0, Endian.big);
  if (messageLength <= 0 || messageLength > 1000000) {
    throw Exception('Жарамды кодталған хабарлама табылмады немесе деректер зақымдалған.');
  }
  if (messageLength * 8 > image.width * image.height - 32) {
    throw Exception('Кодталған хабарламаның ұзындығы сурет үшін тым үлкен.');
  }

  var messageBytes = Uint8List(messageLength);
  bitIndex = 0;
  int msgBitIndex = 0;
  for (var y = 0; y < image.height && msgBitIndex < messageLength * 8; y++) {
    for (var x = 0; x < image.width && msgBitIndex < messageLength * 8; x++) {
      if (bitIndex < 32) {
        bitIndex++;
        continue;
      }
      var pixel = image.getPixel(x, y);
      messageBytes[msgBitIndex ~/ 8] |= (pixel.r.toInt() & 1) << (msgBitIndex % 8);
      msgBitIndex++;
      bitIndex++;
    }
  }
  return utf8.decode(messageBytes);
}
