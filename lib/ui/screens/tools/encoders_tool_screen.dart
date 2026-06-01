import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/encoding_service.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scrambled_text.dart';

class EncodersToolScreen extends StatefulWidget {
  const EncodersToolScreen({super.key});

  @override
  State<EncodersToolScreen> createState() => _EncodersToolScreenState();
}

class _EncodersToolScreenState extends State<EncodersToolScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _encodingService = GetIt.instance<EncodingService>();
  final _historyService = GetIt.instance<HistoryService>();

  // Base64
  final _base64InputController = TextEditingController();
  final _base64OutputController = TextEditingController();

  // URL
  final _urlInputController = TextEditingController();
  final _urlOutputController = TextEditingController();

  // ASCII / Binary
  final _abInputController = TextEditingController();
  final _abBinaryOutputController = TextEditingController();
  final _abAsciiOutputController = TextEditingController();

  // Caesar
  final _caesarInputController = TextEditingController();
  final _caesarOutputController = TextEditingController();
  int _caesarShift = 3;

  // Vigenere
  final _vigenereInputController = TextEditingController();
  final _vigenereKeyController = TextEditingController();
  final _vigenereOutputController = TextEditingController();

  bool _autoDetectedBase64 = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _base64InputController.dispose();
    _base64OutputController.dispose();
    _urlInputController.dispose();
    _urlOutputController.dispose();
    _abInputController.dispose();
    _abBinaryOutputController.dispose();
    _abAsciiOutputController.dispose();
    _caesarInputController.dispose();
    _caesarOutputController.dispose();
    _vigenereInputController.dispose();
    _vigenereKeyController.dispose();
    _vigenereOutputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кодтау / Декодтау'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Base64'),
            Tab(text: 'URL'),
            Tab(text: 'ASCII/Екілік'),
            Tab(text: 'Цезарь'),
            Tab(text: 'Виженер'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBase64Tab(),
          _buildUrlTab(),
          _buildAsciiTab(),
          _buildCaesarTab(),
          _buildVigenereTab(),
        ],
      ),
    );
  }

  Widget _buildBase64Tab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_autoDetectedBase64)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Base64 форматы анықталды! Декодтау ұсынылады.'),
                    ),
                    TextButton(
                      onPressed: _decodeBase64,
                      child: const Text('Декодтау'),
                    ),
                  ],
                ),
              ),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    controller: _base64InputController,
                    label: 'Мәтін',
                    hint: 'Кодтау немесе декодтау үшін мәтін...',
                    showPaste: true,
                    maxLines: 3,
                    onChanged: (val) {
                      setState(() {
                        _autoDetectedBase64 = _encodingService.isLikelyBase64(val);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _encodeBase64,
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Кодтау'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _decodeBase64,
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Декодтау'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _base64OutputController,
                label: 'Нәтиже',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
                showShare: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _encodeBase64() async {
    final input = _base64InputController.text;
    if (input.isEmpty) return;
    setState(() => _base64OutputController.text = '');
    await Future.delayed(const Duration(milliseconds: 50));
    final result = _encodingService.encodeBase64(input);
    setState(() => _base64OutputController.text = result);
    _historyService.addHistoryItem(HistoryItem(
      title: 'Base64 кодтау',
      details: '$input → $result',
      timestamp: DateTime.now(),
      type: 'Encode',
    ));
  }

  void _decodeBase64() async {
    final input = _base64InputController.text;
    if (input.isEmpty) return;
    setState(() => _base64OutputController.text = '');
    await Future.delayed(const Duration(milliseconds: 50));
    final result = _encodingService.decodeBase64(input);
    setState(() => _base64OutputController.text = result);
    _historyService.addHistoryItem(HistoryItem(
      title: 'Base64 декодтау',
      details: '$input → $result',
      timestamp: DateTime.now(),
      type: 'Decode',
    ));
  }

  Widget _buildUrlTab() {
    return SingleChildScrollView(
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
                    controller: _urlInputController,
                    label: 'Мәтін',
                    hint: 'URL кодтау үшін мәтін...',
                    showPaste: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final input = _urlInputController.text;
                            if (input.isEmpty) return;
                            final result = _encodingService.encodeUrl(input);
                            setState(() => _urlOutputController.text = result);
                            _historyService.addHistoryItem(HistoryItem(
                              title: 'URL кодтау',
                              details: '$input → $result',
                              timestamp: DateTime.now(),
                              type: 'Encode',
                            ));
                          },
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text('Кодтау'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final input = _urlInputController.text;
                            if (input.isEmpty) return;
                            final result = _encodingService.decodeUrl(input);
                            setState(() => _urlOutputController.text = result);
                            _historyService.addHistoryItem(HistoryItem(
                              title: 'URL декодтау',
                              details: '$input → $result',
                              timestamp: DateTime.now(),
                              type: 'Decode',
                            ));
                          },
                          icon: const Icon(Icons.arrow_upward),
                          label: const Text('Декодтау'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _urlOutputController,
                label: 'Нәтиже',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
                showShare: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsciiTab() {
    return SingleChildScrollView(
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
                    controller: _abInputController,
                    label: 'Мәтін',
                    hint: 'Түрлендіру үшін мәтін...',
                    showPaste: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final input = _abInputController.text;
                      if (input.isEmpty) return;
                      setState(() {
                        _abBinaryOutputController.text = _encodingService.encodeBinary(input);
                        _abAsciiOutputController.text = _encodingService.encodeAscii(input);
                      });
                      _historyService.addHistoryItem(HistoryItem(
                        title: 'ASCII/Екілік кодтау',
                        details: input,
                        timestamp: DateTime.now(),
                        type: 'Encode',
                      ));
                    },
                    icon: const Icon(Icons.transform),
                    label: const Text('Түрлендіру'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _abBinaryOutputController,
                label: 'Екілік (Binary)',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
                showShare: true,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _abAsciiOutputController,
                label: 'ASCII кодтары',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
                showShare: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaesarTab() {
    return SingleChildScrollView(
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
                    controller: _caesarInputController,
                    label: 'Мәтін',
                    hint: 'Цезарь шифры үшін мәтін...',
                    showPaste: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Жылжыту (Shift): ', style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Slider(
                          value: _caesarShift.toDouble(),
                          min: 0,
                          max: 25,
                          divisions: 25,
                          label: _caesarShift.toString(),
                          onChanged: (val) => setState(() => _caesarShift = val.round()),
                        ),
                      ),
                      Text(_caesarShift.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final input = _caesarInputController.text;
                            if (input.isEmpty) return;
                            final result = _encodingService.encodeCaesar(input, _caesarShift);
                            setState(() => _caesarOutputController.text = result);
                          },
                          icon: const Icon(Icons.lock),
                          label: const Text('Шифрлау'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final input = _caesarInputController.text;
                            if (input.isEmpty) return;
                            final result = _encodingService.decodeCaesar(input, _caesarShift);
                            setState(() => _caesarOutputController.text = result);
                          },
                          icon: const Icon(Icons.lock_open),
                          label: const Text('Дешифрлау'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _caesarOutputController,
                label: 'Нәтиже',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVigenereTab() {
    return SingleChildScrollView(
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
                    controller: _vigenereInputController,
                    label: 'Мәтін',
                    hint: 'Виженер шифры үшін мәтін...',
                    showPaste: true,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _vigenereKeyController,
                    label: 'Кілт (Сөз)',
                    hint: 'Мысалы: KEY',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final input = _vigenereInputController.text;
                            final key = _vigenereKeyController.text;
                            if (input.isEmpty || key.isEmpty) return;
                            final result = _encodingService.encodeVigenere(input, key);
                            setState(() => _vigenereOutputController.text = result);
                          },
                          icon: const Icon(Icons.enhanced_encryption),
                          label: const Text('Шифрлау'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final input = _vigenereInputController.text;
                            final key = _vigenereKeyController.text;
                            if (input.isEmpty || key.isEmpty) return;
                            final result = _encodingService.decodeVigenere(input, key);
                            setState(() => _vigenereOutputController.text = result);
                          },
                          icon: const Icon(Icons.no_encryption),
                          label: const Text('Дешифрлау'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextField(
                controller: _vigenereOutputController,
                label: 'Нәтиже',
                maxLines: 3,
                readOnly: true,
                showCopy: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
