import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/crypto_service.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../widgets/custom_text_field.dart';

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

  void _generateHashes() {
    final input = _inputController.text;
    if (input.isEmpty) return;

    setState(() {
      _md5 = _cryptoService.generateMd5(input);
      _sha1 = _cryptoService.generateSha1(input);
      _sha256 = _cryptoService.generateSha256(input);
      _strength = _cryptoService.evaluatePasswordStrength(input);
    });

    _historyService.addHistoryItem(HistoryItem(
      title: 'Хэш құрылды',
      details: 'MD5: ${_md5.substring(0, 8)}...',
      timestamp: DateTime.now(),
      type: 'Hash',
    ));
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label көшірілді!')),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Криптография (Хэштер)')),
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
                      label: 'Мәтін немесе құпия сөз',
                      hint: 'Хэштеу үшін мәтін...',
                      showPaste: true,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _generateHashes,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Хэш жасау'),
                    ),
                  ],
                ),
              ),
            ),
            if (_strength.isNotEmpty) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _getStrengthIcon(),
                        color: _getStrengthColor(),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Құпия сөз мықтылығы',
                            style: theme.textTheme.labelMedium,
                          ),
                          Text(
                            _strength,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: _getStrengthColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_md5.isNotEmpty) ...[
              const SizedBox(height: 12),
              _HashResultCard(label: 'MD5', value: _md5, onCopy: () => _copyToClipboard(_md5, 'MD5')),
              _HashResultCard(label: 'SHA-1', value: _sha1, onCopy: () => _copyToClipboard(_sha1, 'SHA-1')),
              _HashResultCard(label: 'SHA-256', value: _sha256, onCopy: () => _copyToClipboard(_sha256, 'SHA-256')),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStrengthIcon() {
    switch (_strength) {
      case 'Мықты':
        return Icons.shield;
      case 'Жақсы':
        return Icons.verified_user;
      case 'Орташа':
        return Icons.security;
      default:
        return Icons.warning;
    }
  }

  Color _getStrengthColor() {
    switch (_strength) {
      case 'Мықты':
        return Colors.green;
      case 'Жақсы':
        return Colors.lightGreen;
      case 'Орташа':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

class _HashResultCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onCopy;

  const _HashResultCard({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      tooltip: 'Көшіру',
                      onPressed: onCopy,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      tooltip: 'Бөлісу',
                      onPressed: () => SharePlus.instance.share(ShareParams(text: '$label: $value')),
                    ),
                  ],
                ),
              ],
            ),
            SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
