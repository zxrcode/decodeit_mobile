import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'huffman_coding_screen.dart';
import '../widgets/explanations/graphics_explanation.dart';

enum GraphicsMode { binary, grayscale, rgb }

class GraphicsLabScreen extends StatefulWidget {
  const GraphicsLabScreen({super.key});

  @override
  State<GraphicsLabScreen> createState() => _GraphicsLabScreenState();
}

class _GraphicsLabScreenState extends State<GraphicsLabScreen> {
  GraphicsMode _mode = GraphicsMode.binary;
  final List<Color> _gridColors = List.generate(64, (_) => const Color(0xFF0F172A)); // Default dark background
  final TextEditingController _dataController = TextEditingController();
  bool _isUpdatingFromCode = false;

  @override
  void initState() {
    super.initState();
    _updateCodeFromGrid();
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  // Colors palette for RGB mode
  final List<Color> _palette = [
    const Color(0xFF0F172A), // Background dark
    const Color(0xFF00E5FF), // Cyan
    const Color(0xFF9D4EDD), // Purple
    const Color(0xFF10B981), // Green
    const Color(0xFFEF4444), // Red
    const Color(0xFFF59E0B), // Yellow
    Colors.white,
  ];
  int _selectedPaletteIndex = 1; // Default Cyan

  // Brush values for Grayscale mode
  double _grayscaleValue = 128.0; // 0 to 255

  // RLE Compression animation state
  bool _isCompressing = false;
  int _scanningRow = -1;
  String _compressedResultText = '';
  List<String> _rleSteps = [];
  double _compressionRatio = 0.0;

  void _clearGrid() {
    setState(() {
      _gridColors.fillRange(0, 64, const Color(0xFF0F172A));
      _scanningRow = -1;
      _compressedResultText = '';
      _rleSteps.clear();
      _compressionRatio = 0.0;
    });
  }

  void _paintCell(int index) {
    if (_isCompressing) return;
    setState(() {
      if (_mode == GraphicsMode.binary) {
        // Toggle between dark slate and primary color
        final isDefault = _gridColors[index] == const Color(0xFF0F172A);
        _gridColors[index] = isDefault ? const Color(0xFF00E5FF) : const Color(0xFF0F172A);
      } else if (_mode == GraphicsMode.grayscale) {
        // Paint cell with selected grayscale value
        final valInt = _grayscaleValue.round();
        _gridColors[index] = Color.fromARGB(255, valInt, valInt, valInt);
      } else {
        // Paint cell with selected palette color
        _gridColors[index] = _palette[_selectedPaletteIndex];
      }
      _updateCodeFromGrid();
    });
  }

  void _updateCodeFromGrid() {
    if (_isUpdatingFromCode) return;
    _dataController.text = _getSerializedData();
  }

  void _updateGridFromCode(String value) {
    if (_isCompressing) return;
    _isUpdatingFromCode = true;
    setState(() {
      try {
        if (_mode == GraphicsMode.binary) {
          final bits = value.trim().split(RegExp(r'\s+'));
          for (int i = 0; i < 64 && i < bits.length; i++) {
            _gridColors[i] = bits[i] == '1' ? const Color(0xFF00E5FF) : const Color(0xFF0F172A);
          }
        } else if (_mode == GraphicsMode.grayscale) {
          final bytes = value.trim().split(RegExp(r'[,\s]+'));
          for (int i = 0; i < 64 && i < bytes.length; i++) {
            final val = int.tryParse(bytes[i]) ?? 0;
            final valClamped = val.clamp(0, 255);
            _gridColors[i] = Color.fromARGB(255, valClamped, valClamped, valClamped);
          }
        } else {
          final codes = value.trim().split(RegExp(r'\s+'));
          for (int i = 0; i < 64 && i < codes.length; i++) {
            _gridColors[i] = _getColorFromCode(codes[i]);
          }
        }
      } catch (e) {
        debugPrint('Grid update error: $e');
      }
    });
    _isUpdatingFromCode = false;
  }

  Color _getColorFromCode(String code) {
    switch (code) {
      case 'D': return const Color(0xFF0F172A);
      case 'C': return const Color(0xFF00E5FF);
      case 'P': return const Color(0xFF9D4EDD);
      case 'G': return const Color(0xFF10B981);
      case 'R': return const Color(0xFFEF4444);
      case 'Y': return const Color(0xFFF59E0B);
      case 'W': return Colors.white;
      default: return const Color(0xFF0F172A);
    }
  }

  // Helper to stringify color for serialization
  String _getSerializedData() {
    if (_mode == GraphicsMode.binary) {
      // 0 or 1
      final list = _gridColors.map((c) => c == const Color(0xFF0F172A) ? '0' : '1').toList();
      return list.join(' ');
    } else if (_mode == GraphicsMode.grayscale) {
      // 0-255
      final list = _gridColors.map((c) => c.red.toString()).toList();
      return list.join(', ');
    } else {
      // hex short names or indices
      final list = _gridColors.map((c) {
        if (c == const Color(0xFF0F172A)) return 'D'; // Dark
        if (c == const Color(0xFF00E5FF)) return 'C'; // Cyan
        if (c == const Color(0xFF9D4EDD)) return 'P'; // Purple
        if (c == const Color(0xFF10B981)) return 'G'; // Green
        if (c == const Color(0xFFEF4444)) return 'R'; // Red
        if (c == const Color(0xFFF59E0B)) return 'Y'; // Yellow
        if (c == Colors.white) return 'W';
        return 'X';
      }).toList();
      return list.join(' ');
    }
  }

  // Perform RLE compression with step-by-step scanner animation
  Future<void> _runRleCompression() async {
    if (_isCompressing) return;

    setState(() {
      _isCompressing = true;
      _scanningRow = 0;
      _rleSteps.clear();
      _compressedResultText = 'Сканерлеу басталды...';
    });

    final int totalRows = 8;
    int totalCompressedElements = 0;

    for (int row = 0; row < totalRows; row++) {
      setState(() {
        _scanningRow = row;
      });

      // Compress current row
      final List<Color> rowColors = _gridColors.sublist(row * 8, (row + 1) * 8);
      final List<String> rowRle = [];

      int count = 1;
      Color lastColor = rowColors[0];

      for (int col = 1; col < 8; col++) {
        if (rowColors[col] == lastColor) {
          count++;
        } else {
          rowRle.add('${count}x[${_getColorCode(lastColor)}]');
          lastColor = rowColors[col];
          count = 1;
        }
      }
      rowRle.add('${count}x[${_getColorCode(lastColor)}]');
      totalCompressedElements += rowRle.length;

      await Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _rleSteps.add('Жол ${row + 1}: ${rowRle.join(", ")}');
      });
    }

    // Compression ratio calculation
    int originalSize;
    int compressedSize;
    String unit;

    if (_mode == GraphicsMode.binary) {
      originalSize = 64; // bits
      compressedSize = totalCompressedElements * 2; // approximation
      unit = 'Бит';
    } else {
      originalSize = _mode == GraphicsMode.rgb ? 64 * 3 : 64; // bytes
      compressedSize = totalCompressedElements * (_mode == GraphicsMode.rgb ? 4 : 2);
      unit = 'Байт';
    }
    
    final double ratio = (1.0 - (compressedSize / originalSize)) * 100.0;

    setState(() {
      _isCompressing = false;
      _scanningRow = -1;
      _compressionRatio = ratio.clamp(0.0, 100.0);
      _compressedResultText = 'Сығылу аяқталды!\n'
          'Түпнұсқа өлшемі: $originalSize $unit\n'
          'Сығылған өлшемі: $compressedSize $unit';
    });
  }

  String _getColorCode(Color c) {
    if (_mode == GraphicsMode.binary) {
      return c == const Color(0xFF0F172A) ? '0' : '1';
    } else if (_mode == GraphicsMode.grayscale) {
      return '${c.red}';
    } else {
      if (c == const Color(0xFF0F172A)) return 'D';
      if (c == const Color(0xFF00E5FF)) return 'C';
      if (c == const Color(0xFF9D4EDD)) return 'P';
      if (c == const Color(0xFF10B981)) return 'G';
      if (c == const Color(0xFFEF4444)) return 'R';
      if (c == const Color(0xFFF59E0B)) return 'Y';
      if (c == Colors.white) return 'W';
      return 'X';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serializedData = _getSerializedData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ГРАФИКАЛЫҚ ЗЕРТХАНА'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => const GraphicsExplanation(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mode Select Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: GraphicsMode.values.map((m) {
                    String label = '';
                    switch (m) {
                      case GraphicsMode.binary:
                        label = 'Екілік (1-бит)';
                      case GraphicsMode.grayscale:
                        label = 'Сұр (8-бит)';
                      case GraphicsMode.rgb:
                        label = 'Түсті (24-бит)';
                    }
                    return ChoiceChip(
                      label: Text(
                        label,
                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      selected: _mode == m,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _mode = m;
                            _clearGrid();
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Color Palette or Brush Settings
            if (_mode == GraphicsMode.rgb)
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Түс палитрасы:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(_palette.length, (index) {
                          final color = _palette[index];
                          final isSelected = _selectedPaletteIndex == index;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPaletteIndex = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? theme.primaryColor : Colors.grey.shade600,
                                  width: isSelected ? 3.0 : 1.0,
                                ),
                              ),
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              )
            else if (_mode == GraphicsMode.grayscale)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Сұр түс жарықтылығы:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            width: 36,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, _grayscaleValue.round(), _grayscaleValue.round(), _grayscaleValue.round()),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              _grayscaleValue.round().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _grayscaleValue > 128 ? Colors.black : Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      Slider(
                        value: _grayscaleValue,
                        min: 0,
                        max: 255,
                        divisions: 255,
                        onChanged: (val) {
                          setState(() {
                            _grayscaleValue = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Pixel grid canvas
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.primaryColor, width: 2.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (context, index) {
                      final row = index ~/ 8;
                      final isScanning = _scanningRow == row;
                      return GestureDetector(
                        onTap: () => _paintCell(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.all(1.0),
                          decoration: BoxDecoration(
                            color: _gridColors[index],
                            border: Border.all(
                              color: isScanning
                                  ? theme.primaryColor.withOpacity(0.8)
                                  : Colors.white10,
                              width: isScanning ? 2.0 : 0.5,
                            ),
                          ),
                          child: isScanning
                              ? Container(
                                  color: theme.primaryColor.withOpacity(0.2),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Controls & serialization
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _clearGrid,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Тазалау'),
                ),
                FilledButton.icon(
                  onPressed: _isCompressing ? null : _runRleCompression,
                  icon: _isCompressing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.compress),
                  label: const Text('RLE Сығу'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Serialization Panel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _mode == GraphicsMode.binary 
                    ? 'Кодталған биттер (Bits):' 
                    : 'Кодталған байттар (Bytes):',
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '64 пиксель',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF070B14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E2638)),
              ),
              child: TextField(
                controller: _dataController,
                maxLines: 3,
                onChanged: _updateGridFromCode,
                style: GoogleFonts.firaCode(fontSize: 11, color: Colors.cyan),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                  hintText: 'Кодты осы жерге енгізіңіз немесе өзгертіңіз...',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // RLE Compression details
            if (_rleSteps.isNotEmpty || _compressedResultText.isNotEmpty)
              Card(
                color: const Color(0xFF0F1424),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RLE Сығу Нәтижелері:',
                        style: GoogleFonts.orbitron(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      ..._rleSteps.map((step) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              step,
                              style: GoogleFonts.firaCode(fontSize: 11, color: Colors.grey.shade300),
                            ),
                          )),
                      const SizedBox(height: 12),
                      Text(
                        _compressedResultText,
                        style: const TextStyle(fontWeight: FontWeight.bold, height: 1.4),
                      ),
                      if (_compressionRatio > 0) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Сығылу тиімділігі: ${_compressionRatio.toStringAsFixed(1)}%',
                          style: GoogleFonts.orbitron(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HuffmanCodingScreen(
                                    initialText: _rleSteps.join("\n"),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.account_tree_outlined),
                            label: const Text('Хаффманға жіберу'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
