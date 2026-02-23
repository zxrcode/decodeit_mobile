import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../data/services/history_service.dart';
import '../../domain/models/history_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = GetIt.instance<HistoryService>();
  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await _historyService.getHistory();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'QR':
        return Icons.qr_code;
      case 'Hash':
        return Icons.fingerprint;
      case 'Encode':
        return Icons.arrow_downward;
      case 'Decode':
        return Icons.arrow_upward;
      case 'Dev':
        return Icons.build;
      default:
        return Icons.history;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'QR':
        return Colors.teal;
      case 'Hash':
        return Colors.indigo;
      case 'Encode':
        return Colors.orange;
      case 'Decode':
        return Colors.blue;
      case 'Dev':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Тарих'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Тарихты тазалау',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Тарихты тазалау'),
                    content: const Text('Барлық тарих жазбалары жойылады. Жалғастырасыз ба?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Болдырмау'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Жою'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _historyService.clearHistory();
                  _loadHistory();
                }
              },
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Тарих бос',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Операциялар мұнда сақталады',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getTypeColor(item.type).withAlpha(38),
                            child: Icon(
                              _getTypeIcon(item.type),
                              color: _getTypeColor(item.type),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.details,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                DateFormat('dd.MM.yyyy HH:mm').format(item.timestamp),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                tooltip: 'Көшіру',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: item.details));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Көшірілді!')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, size: 18),
                                tooltip: 'Бөлісу',
                                onPressed: () => SharePlus.instance.share(ShareParams(text: item.details)),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
