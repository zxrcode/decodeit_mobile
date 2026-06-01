import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/crypto_service.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scrambled_text.dart';

class CryptoToolScreen extends StatefulWidget {
  const CryptoToolScreen({super.key});

  @override
  State<CryptoToolScreen> createState() => _CryptoToolScreenState();
}

class _CryptoToolScreenState extends State<CryptoToolScreen> {
  final _inputController = TextEditingController();
  final _cryptoService = GetIt.instance<CryptoService>();
  final _historyService = GetIt.instance<HistoryService>();

  String _md5 = '';
  String _sha1 = '';
  String _sha256 = '';
  String _strength = '';
  String? _fileName;
  bool _isHashingFile = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _generateHashes() async {
    final input = _inputController.text;
    if (input.isEmpty) return;

    setState(() {
      _md5 = '';
      _sha1 = '';
      _sha256 = '';
      _fileName = null;
    });
    
    await Future.delayed(const Duration(milliseconds: 50));

    setState(() {
      _md5 = _cryptoService.generateMd5(input);
      _sha1 = _cryptoService.generateSha1(input);
      _sha256 = _cryptoService.generateSha256(input);
      _strength = _cryptoService.evaluatePasswordStrength(input);
    });

    _historyService.addHistoryItem(HistoryItem(
      title: 'Хэш генерацияланды',
      details: input.length > 30 ? '${input.substring(0, 30)}...' : input,
      timestamp: DateTime.now(),
      type: 'Hash',
    ));
  }

  void _hashFile() async {
    final result = await FilePicker.pickFiles(withData: true);
    if (result == null) return;

    setState(() {
      _isHashingFile = true;
      _fileName = result.files.first.name;
      _md5 = '';
      _sha1 = '';
      _sha256 = '';
    });

    try {
      final bytes = result.files.first.bytes ?? await result.files.first.xFile.readAsBytes();
      
      setState(() {
        // We convert bytes to hex hash directly via service
        _md5 = _cryptoService.generateMd5(utf8.decode(bytes, allowMalformed: true));
        _sha1 = _cryptoService.generateSha1(utf8.decode(bytes, allowMalformed: true));
        _sha256 = _cryptoService.generateSha256(utf8.decode(bytes, allowMalformed: true));
        _isHashingFile = false;
      });

      _historyService.addHistoryItem(HistoryItem(
        title: 'Файл хэштелді',
        details: _fileName!,
        timestamp: DateTime.now(),
        type: 'Hash',
      ));
    } catch (e) {
      setState(() {
        _isHashingFile = false;
        _fileName = 'Қате: Файлды оқу мүмкін емес';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Криптографиялық хэштер'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _inputController,
                      label: 'Мәтінді енгізіңіз',
                      hint: 'Хэштеу үшін құпия сөз немесе мәтін...',
                      showPaste: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _generateHashes,
                            icon: const Icon(Icons.security),
                            label: const Text('Хэштеу'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isHashingFile ? null : _hashFile,
                            icon: _isHashingFile 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.file_present),
                            label: Text(_fileName ?? 'Файлды таңдау'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Results
            if (_md5.isNotEmpty || _isHashingFile) ...[
              if (_fileName == null) ...[
                Text(
                  'Құпия сөз беріктігі: $_strength',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getStrengthColor(_strength),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _HashResultCard(label: 'MD5', value: _md5),
              _HashResultCard(label: 'SHA-1', value: _sha1),
              _HashResultCard(label: 'SHA-256', value: _sha256),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStrengthColor(String strength) {
    switch (strength) {
      case 'Мықты': return Colors.green;
      case 'Жақсы': return Colors.blue;
      case 'Орташа': return Colors.orange;
      case 'Әлсіз':
      case 'Өте әлсіз': return Colors.red;
      default: return Colors.grey;
    }
  }
}

class _HashResultCard extends StatelessWidget {
  final String label;
  final String value;

  const _HashResultCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Көшірілді!')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 18),
                      onPressed: () => SharePlus.instance.share(ShareParams(text: value)),
                    ),
                  ],
                ),
              ],
            ),
            if (value.isEmpty)
              const LinearProgressIndicator()
            else
              ScrambledText(
                text: value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                duration: const Duration(seconds: 1),
              ),
          ],
        ),
      ),
    );
  }
}
