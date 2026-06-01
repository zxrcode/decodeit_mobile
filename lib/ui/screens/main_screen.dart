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

import 'pcm_visualizer_screen.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final morseAudioService = getIt<MorseAudioService>();

    final soundTools = [
      _ToolItem('PCM Дыбыс', Icons.graphic_eq, const Color(0xFF00E5FF), const PcmVisualizerScreen()),
      _ToolItem('Морзе колы', Icons.signal_cellular_alt, const Color(0xFF10B981), MorseTranslatorScreen(audioService: morseAudioService)),
      _ToolItem('Морзе кесте', Icons.table_chart, const Color(0xFFFFB703), MorseChartScreen(audioService: morseAudioService)),
      _ToolItem('Морзе оқу', Icons.school, const Color(0xFFFF0055), MorseLearnScreen(audioService: morseAudioService)),
    ];

    final graphicsTools = [
      _ToolItem('Пиксель торы', Icons.grid_4x4, const Color(0xFF00F5D4), const GraphicsLabScreen()),
      _ToolItem('Стеганография', Icons.visibility_off, const Color(0xFF8B5CF6), const SteganographyScreen()),
    ];

    final generalTools = [
      _ToolItem('QR Сканер', Icons.qr_code_scanner, const Color(0xFF14B8A6), const QrToolScreen()),
      _ToolItem('Хэш құру', Icons.fingerprint, const Color(0xFF6366F1), const CryptoToolScreen()),
      _ToolItem('Base64 / URL', Icons.code, const Color(0xFFF59E0B), const EncodersToolScreen()),
      _ToolItem('Әзірлеуші құралы', Icons.build, const Color(0xFFEF4444), const DevToolScreen()),
      _ToolItem('Тарих', Icons.history, const Color(0xFF845EF7), const HistoryScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'DECODE IT! LAB',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            fontSize: 22,
          ),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F1424), Color(0xFF151E33)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2638), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome, color: Color(0xFF00E5FF), size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Кодтау технологиялары зертханасы',
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ақпаратты кодтау, декодтау және мультимедианы цифрландыруды визуализациялау құралдары',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sound Coding Section
            _buildSectionHeader(context, 'Дыбыстық ақпаратты кодтау', Icons.music_note),
            const SizedBox(height: 12),
            _buildToolGrid(soundTools, crossAxisCount: 2, aspectRatio: 1.5),
            const SizedBox(height: 24),

            // Graphics Coding Section
            _buildSectionHeader(context, 'Графикалық ақпаратты кодтау', Icons.image),
            const SizedBox(height: 12),
            _buildToolGrid(graphicsTools, crossAxisCount: 2, aspectRatio: 1.5),
            const SizedBox(height: 24),

            // General Tools Section
            _buildSectionHeader(context, 'Жалпы құралдар мен шифрлау', Icons.settings),
            const SizedBox(height: 12),
            _buildToolGrid(generalTools, crossAxisCount: 2, aspectRatio: 1.6),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildToolGrid(List<_ToolItem> tools, {required int crossAxisCount, required double aspectRatio}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: aspectRatio,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        return _ToolCard(tool: tools[index]);
      },
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

class _ToolCard extends StatefulWidget {
  final _ToolItem tool;

  const _ToolCard({required this.tool});

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => widget.tool.screen),
        );
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.tool.color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.tool.color.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.tool.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.tool.icon, size: 28, color: widget.tool.color),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.tool.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
