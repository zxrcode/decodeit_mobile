import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../data/services/timestamp_service.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/history_service.dart';
import '../../../domain/models/history_item.dart';
import '../../../domain/models/ip_info.dart';
import '../../widgets/custom_text_field.dart';

class DevToolScreen extends StatefulWidget {
  const DevToolScreen({super.key});

  @override
  State<DevToolScreen> createState() => _DevToolScreenState();
}

class _DevToolScreenState extends State<DevToolScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _timestampService = GetIt.instance<TimestampService>();
  final _apiService = GetIt.instance<ApiService>();
  final _historyService = GetIt.instance<HistoryService>();

  // Timestamp
  final _timestampInputController = TextEditingController();
  final _timestampOutputController = TextEditingController();
  String _currentTimestamp = '';

  // IP
  IpInfo? _ipInfo;
  bool _loadingIp = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _updateCurrentTimestamp();
  }

  void _updateCurrentTimestamp() {
    setState(() {
      _currentTimestamp = _timestampService.toTimestamp(DateTime.now());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timestampInputController.dispose();
    _timestampOutputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Әзірлеуші құралдары'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.access_time), text: 'Уақыт белгісі'),
            Tab(icon: Icon(Icons.public), text: 'IP Ақпарат'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimestampTab(),
          _buildIpTab(),
        ],
      ),
    );
  }

  Widget _buildTimestampTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current timestamp card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Қазіргі уақыт белгісі',
                      style: theme.textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentTimestamp,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _currentTimestamp));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Көшірілді!')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 20),
                        onPressed: _updateCurrentTimestamp,
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timestamp → Date
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Timestamp → Күн',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _timestampInputController,
                    label: 'Unix Timestamp',
                    hint: 'Мысалы: 1700000000',
                    showPaste: true,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      final input = _timestampInputController.text;
                      if (input.isEmpty) return;
                      final result = _timestampService.toDate(input);
                      setState(() => _timestampOutputController.text = result);
                      _historyService.addHistoryItem(HistoryItem(
                        title: 'Timestamp → Күн',
                        details: '$input → $result',
                        timestamp: DateTime.now(),
                        type: 'Dev',
                      ));
                    },
                    icon: const Icon(Icons.transform),
                    label: const Text('Түрлендіру'),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _timestampOutputController,
                    label: 'Нәтиже',
                    readOnly: true,
                    showCopy: true,
                    showShare: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Date → Timestamp
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Күн → Timestamp',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1970),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        if (!mounted) return;
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (!mounted) return;
                        final dateTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time?.hour ?? 0,
                          time?.minute ?? 0,
                        );
                        final ts = _timestampService.toTimestamp(dateTime);
                        setState(() {
                          _timestampOutputController.text = ts;
                        });
                        _historyService.addHistoryItem(HistoryItem(
                          title: 'Күн → Timestamp',
                          details: '$dateTime → $ts',
                          timestamp: DateTime.now(),
                          type: 'Dev',
                        ));
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Күнді таңдау'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpTab() {
    final theme = Theme.of(context);
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
                  Icon(Icons.public, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  const Text('IP мекен-жайыңызды анықтаңыз'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _loadingIp
                        ? null
                        : () async {
                            setState(() => _loadingIp = true);
                            final info = await _apiService.fetchIpInfo();
                            setState(() {
                              _ipInfo = info;
                              _loadingIp = false;
                            });
                            if (info != null) {
                              _historyService.addHistoryItem(HistoryItem(
                                title: 'IP ақпарат алынды',
                                details: 'IP: ${info.ip}, ${info.city}, ${info.country}',
                                timestamp: DateTime.now(),
                                type: 'Dev',
                              ));
                            }
                          },
                    icon: _loadingIp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                    label: Text(_loadingIp ? 'Жүктелуде...' : 'IP анықтау'),
                  ),
                ],
              ),
            ),
          ),
          if (_ipInfo != null) ...[
            const SizedBox(height: 12),
            _InfoCard(icon: Icons.language, label: 'IP мекен-жайы', value: _ipInfo!.ip),
            _InfoCard(icon: Icons.flag, label: 'Ел', value: _ipInfo!.country),
            _InfoCard(icon: Icons.location_city, label: 'Қала', value: _ipInfo!.city),
            if (_ipInfo!.region != null && _ipInfo!.region!.isNotEmpty)
              _InfoCard(icon: Icons.map_outlined, label: 'Аймақ (Region)', value: _ipInfo!.region!),
            if (_ipInfo!.timezone != null && _ipInfo!.timezone!.isNotEmpty)
              _InfoCard(icon: Icons.access_time, label: 'Уақыт белдеуі', value: _ipInfo!.timezone!),
            _InfoCard(icon: Icons.cell_tower, label: 'Провайдер (ISP)', value: _ipInfo!.isp),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: const TextStyle(fontSize: 12)),
        subtitle: Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
              onPressed: () => SharePlus.instance.share(ShareParams(text: '$label: $value')),
            ),
          ],
        ),
      ),
    );
  }
}
