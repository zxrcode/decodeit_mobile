import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/encoding_service.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../widgets/custom_text_field.dart';

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

  bool _autoDetectedBase64 = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кодтау / Декодтау'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Base64'),
            Tab(text: 'URL'),
            Tab(text: 'ASCII/Екілік'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBase64Tab(),
          _buildUrlTab(),
          _buildAsciiTab(),
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

  void _encodeBase64() {
    final input = _base64InputController.text;
    if (input.isEmpty) return;
    final result = _encodingService.encodeBase64(input);
    setState(() => _base64OutputController.text = result);
    _historyService.addHistoryItem(HistoryItem(
      title: 'Base64 кодтау',
      details: '$input → $result',
      timestamp: DateTime.now(),
      type: 'Encode',
    ));
  }

  void _decodeBase64() {
    final input = _base64InputController.text;
    if (input.isEmpty) return;
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
}
