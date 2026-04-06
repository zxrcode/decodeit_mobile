import 'dart:convert';
import 'dart:html' as html;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_package;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          const Text('No image selected.'),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _pickImage(isEncode),
            icon: const Icon(Icons.photo_library),
            label: const Text('Pick Image'),
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
          label: const Text('Change Image'),
        ),
      ],
    );
  }

  Uint8List _encodeMessage(String message, img.Image image) {
    var messageBytes = Uint8List.fromList(utf8.encode(message));
    var lengthBytes = Uint8List(4)
      ..buffer.asByteData().setUint32(0, messageBytes.length, Endian.big);
    var allBytes = Uint8List.fromList([...lengthBytes, ...messageBytes]);

    final totalPixels = image.width * image.height;
    if (allBytes.length * 8 > totalPixels) {
      throw ArgumentError('Message is too long for this image.');
    }

    // Clone image to avoid modifying the original
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

  String _decodeMessage(img.Image image) {
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

    var messageLength =
        lengthBytes.buffer.asByteData().getUint32(0, Endian.big);
    
    if (messageLength <= 0 || messageLength > 1000000) {
      throw Exception('No valid encoded message found or data is corrupted.');
    }
    
    if (messageLength * 8 > image.width * image.height - 32) {
      throw Exception('Encoded message length is too large for image.');
    }

    // Read message bytes
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
    if (kIsWeb) {
      // Web: trigger browser download
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'steganography_image.png')
        ..click();
      html.Url.revokeObjectUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded successfully!')),
        );
      }
    } else {
      // Mobile/Desktop: save to filesystem
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/steganography/steganography_image.png';
      final imageFile = File(imagePath);
      await imageFile.create(recursive: true);
      await imageFile.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to:\n$imagePath')),
        );
      }
    }
  }

  Future<void> _encodeAndSave() async {
    if (_isKeyAvailableForEncode && _key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an encryption key.')),
      );
      return;
    }
    if (_encodeImage == null || _message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image and enter a message.')),
      );
      return;
    }

    try {
      String messageToEncode = _message;
      if (_isKeyAvailableForEncode) {
        messageToEncode = _encryptMessage(_message, _key);
      }

      final imageBytes = await _encodeImage!.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Could not decode image.');
      }
      final encodedImage = _encodeMessage(messageToEncode, image);

      await _saveImage(encodedImage);

      // Reset encode tab state
      setState(() {
        _message = '';
        _key = '';
        _isKeyAvailableForEncode = false;
        _encodeImage = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _doDecode() async {
    if (_isKeyAvailableForDecode && _decodeKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a decryption key.')),
      );
      return;
    }
    if (_decodeImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.')),
      );
      return;
    }

    try {
      final imageBytes = await _decodeImage!.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Could not decode image.');
      }
      String extractedMessage = _decodeMessage(image);

      if (_isKeyAvailableForDecode) {
        try {
          extractedMessage = _decryptMessage(extractedMessage, _decodeKey);
        } catch (e) {
          throw Exception('Failed to decrypt. Wrong key or not encrypted.');
        }
      }

      setState(() {
        _decodedMessage = extractedMessage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Steganography'),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.image_outlined), text: 'Encode'),
              Tab(icon: Icon(Icons.text_snippet_outlined), text: 'Decode'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _encodeTab(),
                _decodeTab(),
              ],
            ),
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
            'Encode a secret message into an image using LSB steganography.',
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
                  return Text('Image size: ${(snapshot.data! / 1024).toStringAsFixed(1)} KB');
                }
                return const SizedBox.shrink();
              },
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Enter your secret message...',
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
              const Text('Encrypt with key'),
            ],
          ),
          if (_isKeyAvailableForEncode)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Encryption Key',
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
              label: const Text('Encode & Save Image'),
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
            'Extract a hidden message from a steganography image.',
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
              const Text('Decrypt with key'),
            ],
          ),
          if (_isKeyAvailableForDecode)
            TextField(
              decoration: const InputDecoration(
                labelText: 'Decryption Key',
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
              label: const Text('Decode Image'),
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
                          'Decoded Message:',
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
}
