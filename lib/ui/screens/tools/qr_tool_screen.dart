import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../widgets/custom_text_field.dart';

class QrToolScreen extends StatefulWidget {
  const QrToolScreen({super.key});

  @override
  State<QrToolScreen> createState() => _QrToolScreenState();
}

class _QrToolScreenState extends State<QrToolScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _qrTextController = TextEditingController();
  final _scanResultController = TextEditingController();
  final _historyService = GetIt.instance<HistoryService>();
  String _qrData = '';
  bool _scannerActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _qrTextController.dispose();
    _scanResultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR & Штрихкод'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code), text: 'Генератор'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Сканер'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneratorTab(),
          _buildScannerTab(),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
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
                    controller: _qrTextController,
                    label: 'Мәтін енгізіңіз',
                    hint: 'QR код үшін мәтін...',
                    showPaste: true,
                    maxLines: 3,
                    onChanged: (val) {
                      setState(() => _qrData = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      if (_qrTextController.text.isNotEmpty) {
                        setState(() {
                          _qrData = _qrTextController.text;
                        });
                        _historyService.addHistoryItem(HistoryItem(
                          title: 'QR код құрылды',
                          details: _qrData.length > 50 ? '${_qrData.substring(0, 50)}...' : _qrData,
                          timestamp: DateTime.now(),
                          type: 'QR',
                        ));
                      }
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('QR код жасау'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_qrData.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _qrData));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Көшірілді!')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Көшіру'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {
                            SharePlus.instance.share(ShareParams(text: _qrData));
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Бөлісу'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return Column(
      children: [
        Expanded(
          child: _scannerActive
              ? MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.firstOrNull;
                    if (barcode != null && barcode.rawValue != null) {
                      setState(() {
                        _scanResultController.text = barcode.rawValue!;
                        _scannerActive = false;
                      });
                      _historyService.addHistoryItem(HistoryItem(
                        title: 'QR код сканерленді',
                        details: barcode.rawValue!,
                        timestamp: DateTime.now(),
                        type: 'QR',
                      ));
                    }
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        size: 80,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text('Сканерді қосу үшін батырманы басыңыз'),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() => _scannerActive = true);
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Сканерді қосу'),
                      ),
                    ],
                  ),
                ),
        ),
        if (_scanResultController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Нәтиже:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(_scanResultController.text),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _scanResultController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Көшірілді!')),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Көшіру'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SharePlus.instance.share(ShareParams(text: _scanResultController.text));
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Бөлісу'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
