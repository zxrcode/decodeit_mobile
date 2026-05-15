import 'package:flutter/material.dart';
import 'tools/qr_tool_screen.dart';
import 'tools/crypto_tool_screen.dart';
import 'tools/encoders_tool_screen.dart';
import 'tools/dev_tool_screen.dart';
import 'history_screen.dart';
import 'graphics_lab_screen.dart';
import 'morse_translator_screen.dart';
import 'morse_chart_screen.dart';
import 'morse_learn_screen.dart';
import 'steganography_screen.dart';
import '../../core/di.dart';
import '../../data/services/morse_audio_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeGrid(),
    QrToolScreen(),
    CryptoToolScreen(),
    EncodersToolScreen(),
    DevToolScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Басты бет',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'QR / Штрих',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_outline),
            selectedIcon: Icon(Icons.lock),
            label: 'Хэштер',
          ),
          NavigationDestination(
            icon: Icon(Icons.code_outlined),
            selectedIcon: Icon(Icons.code),
            label: 'Кодтау',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build),
            label: 'Құралдар',
          ),
        ],
      ),
    );
  }
}

class _HomeGrid extends StatelessWidget {
  const _HomeGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final morseAudioService = getIt<MorseAudioService>();

    final tools = [
      _ToolItem('QR Сканер', Icons.qr_code_scanner, Colors.teal, const QrToolScreen()),
      _ToolItem('Хэш құру', Icons.fingerprint, Colors.indigo, const CryptoToolScreen()),
      _ToolItem('Base64', Icons.text_fields, Colors.orange, const EncodersToolScreen()),
      _ToolItem('URL Кодтау', Icons.link, Colors.blue, const EncodersToolScreen()),
      _ToolItem('ASCII / Екілік', Icons.grid_3x3, Colors.purple, const EncodersToolScreen()),
      _ToolItem('Уақыт белгісі', Icons.access_time, Colors.green, const DevToolScreen()),
      _ToolItem('IP Ақпарат', Icons.public, Colors.red, const DevToolScreen()),
      _ToolItem('Тарих', Icons.history, Colors.brown, const HistoryScreen()),
      _ToolItem('Пиксель торы', Icons.grid_4x4, Colors.cyan, const GraphicsLabScreen()),
      _ToolItem('Стеганография', Icons.visibility_off, Colors.deepOrange, const SteganographyScreen()),
      _ToolItem('Морзе код', Icons.signal_cellular_alt, Colors.lime, MorseTranslatorScreen(audioService: morseAudioService)),
      _ToolItem('Морзе кесте', Icons.table_chart, Colors.amber, MorseChartScreen(audioService: morseAudioService)),
      _ToolItem('Морзе оқу', Icons.school, Colors.pink, MorseLearnScreen(audioService: morseAudioService)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decode It! Mobile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Тарих',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Әмбебап құрал',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Кодтау, декодтау, хэштеу — бәрі бір қолданбада',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Құралдар',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: tools.length,
                itemBuilder: (context, index) {
                  final tool = tools[index];
                  return _ToolCard(tool: tool);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String title;
  final IconData icon;
  final Color color;
  final Widget screen;

  _ToolItem(this.title, this.icon, this.color, this.screen);
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => tool.screen),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, size: 36, color: tool.color),
              const SizedBox(height: 8),
              Text(
                tool.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
