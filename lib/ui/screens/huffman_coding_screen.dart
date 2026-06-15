import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/explanations/huffman_explanation.dart';

class HuffmanNode {
  final String char;
  final int frequency;
  HuffmanNode? left;
  HuffmanNode? right;

  HuffmanNode({required this.char, required this.frequency, this.left, this.right});

  bool get isLeaf => left == null && right == null;
}

class HuffmanCodingScreen extends StatefulWidget {
  final String? initialText;
  const HuffmanCodingScreen({super.key, this.initialText});

  @override
  State<HuffmanCodingScreen> createState() => _HuffmanCodingScreenState();
}

class _HuffmanCodingScreenState extends State<HuffmanCodingScreen> {
  final TextEditingController _textController = TextEditingController();
  final TransformationController _transformationController = TransformationController();
  HuffmanNode? _root;
  Map<String, String> _huffmanCodes = {};
  int _originalSizeBits = 0;
  int _compressedSizeBits = 0;

  @override
  void initState() {
    super.initState();
    // Set initial scale to 0.6
    _transformationController.value = Matrix4.diagonal3Values(0.6, 0.6, 1.0);
    if (widget.initialText != null) {
      _textController.text = widget.initialText!;
      _generateHuffman();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _generateHuffman() {
    final text = _textController.text;
    if (text.isEmpty) return;

    // 1. Calculate frequencies
    final Map<String, int> frequencies = {};
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      frequencies[char] = (frequencies[char] ?? 0) + 1;
    }

    // 2. Build Huffman Tree
    final priorityQueue = PriorityQueue<HuffmanNode>((a, b) => a.frequency.compareTo(b.frequency));
    frequencies.forEach((char, freq) {
      priorityQueue.add(HuffmanNode(char: char, frequency: freq));
    });

    while (priorityQueue.length > 1) {
      final left = priorityQueue.removeFirst();
      final right = priorityQueue.removeFirst();
      final parent = HuffmanNode(
        char: '', // Internal node
        frequency: left.frequency + right.frequency,
        left: left,
        right: right,
      );
      priorityQueue.add(parent);
    }

    _root = priorityQueue.isEmpty ? null : priorityQueue.first;
    _huffmanCodes.clear();
    if (_root != null) {
      if (_root!.isLeaf) {
        _huffmanCodes[_root!.char] = '0';
      } else {
        _generateCodes(_root!, '');
      }
    }

    // 3. Calculate statistics
    _originalSizeBits = text.length * 8; // Assuming 8-bit ASCII
    _compressedSizeBits = 0;
    for (var i = 0; i < text.length; i++) {
      _compressedSizeBits += _huffmanCodes[text[i]]?.length ?? 0;
    }

    setState(() {});
  }

  void _generateCodes(HuffmanNode node, String code) {
    if (node.isLeaf) {
      _huffmanCodes[node.char] = code;
      return;
    }
    if (node.left != null) _generateCodes(node.left!, '${code}0');
    if (node.right != null) _generateCodes(node.right!, '${code}1');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = _originalSizeBits > 0 ? (1.0 - (_compressedSizeBits / _originalSizeBits)) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ХАФФМАН КОДТАУЫ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const HuffmanExplanation(),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Кодталатын мәтін немесе деректер',
                        border: OutlineInputBorder(),
                        hintText: 'Мәтінді осы жерге жазыңыз...',
                      ),
                      maxLines: 2,
                      onChanged: (_) => _generateHuffman(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            if (_root != null) ...[
              // Statistics Card
              Card(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(label: 'Түпнұсқа', value: '$_originalSizeBits бит'),
                      _StatItem(label: 'Сығылған', value: '$_compressedSizeBits бит'),
                      _StatItem(
                        label: 'Тиімділік', 
                        value: '${ratio.toStringAsFixed(1)}%',
                        color: Colors.greenAccent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Huffman Codes Table
              Text(
                'Таңбалардың префикстік кодтары:',
                style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _huffmanCodes.entries.map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              e.key == ' ' ? '␣' : e.key,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyan),
                            ),
                            const Text(' : '),
                            Text(
                              e.value,
                              style: GoogleFonts.firaCode(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(1000), // Huge margin to allow panning anywhere
                  minScale: 0.05,
                  maxScale: 2.0,
                  transformationController: _transformationController,
                  child: CustomPaint(
                    size: const Size(2000, 1000), // Massive canvas for large trees
                    painter: _HuffmanTreePainter(root: _root),
                  ),
                ),
              ),
              ],
              ],
              ),
              ),
              );
              }
              }

              class _HuffmanTreePainter extends CustomPainter {
              final HuffmanNode? root;
              _HuffmanTreePainter({required this.root});

              @override
              void paint(Canvas canvas, Size size) {
              if (root == null) return;

              final paint = Paint()
              ..color = Colors.cyanAccent.withOpacity(0.5)
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke;

              final nodePaint = Paint()
              ..color = const Color(0xFF1E293B)
              ..style = PaintingStyle.fill;

              final leafPaint = Paint()
              ..color = Colors.purpleAccent.withOpacity(0.3)
              ..style = PaintingStyle.fill;

              _drawNode(canvas, root!, size.width / 2, 40, size.width / 4, 1, paint, nodePaint, leafPaint);
              }

              void _drawNode(Canvas canvas, HuffmanNode node, double x, double y, double xOffset, int level,
                Paint linePaint, Paint nodePaint, Paint leafPaint) {

              // Dynamic vertical spacing and horizontal spread
              final double vGap = 70.0;
              // As we go deeper, we need to reduce the offset, but keep enough for the nodes
              final double nextXOffset = xOffset * 0.8;

              if (node.left != null) {
                canvas.drawLine(Offset(x, y), Offset(x - xOffset, y + vGap), linePaint);
                _drawLabel(canvas, "0", Offset(x - xOffset / 2 - 10, y + vGap / 2));
                _drawNode(canvas, node.left!, x - xOffset, y + vGap, nextXOffset, level + 1, linePaint, nodePaint, leafPaint);
              }

              if (node.right != null) {
                canvas.drawLine(Offset(x, y), Offset(x + xOffset, y + vGap), linePaint);
                _drawLabel(canvas, "1", Offset(x + xOffset / 2 + 5, y + vGap / 2));
                _drawNode(canvas, node.right!, x + xOffset, y + vGap, nextXOffset, level + 1, linePaint, nodePaint, leafPaint);
              }
              // Draw node circle
              canvas.drawCircle(Offset(x, y), 20, node.isLeaf ? leafPaint : nodePaint);
              canvas.drawCircle(Offset(x, y), 20, linePaint..style = PaintingStyle.stroke..color = Colors.white24);

              // Draw frequency/char
              final text = node.isLeaf 
              ? "${node.char == ' ' ? '␣' : node.char}\n${node.frequency}" 
              : node.frequency.toString();

              _drawText(canvas, text, Offset(x, y), fontSize: node.isLeaf ? 10 : 12);
              }

              void _drawLabel(Canvas canvas, String text, Offset pos) {
              final tp = TextPainter(
              text: TextSpan(text: text, style: const TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              textDirection: TextDirection.ltr,
              );
              tp.layout();
              tp.paint(canvas, pos);
              }

              void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12}) {
              final tp = TextPainter(
              text: TextSpan(text: text, style: TextStyle(color: Colors.white, fontSize: fontSize, fontWeight: FontWeight.bold)),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              );
              tp.layout();
              tp.paint(canvas, pos.translate(-tp.width / 2, -tp.height / 2));
              }

              @override
              bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
              }


class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// Simple PriorityQueue implementation for the example
class PriorityQueue<T> extends Iterable<T> {
  final List<T> _list = [];
  final int Function(T, T) comparator;

  PriorityQueue(this.comparator);

  @override
  Iterator<T> get iterator => _list.iterator;

  void add(T element) {
    _list.add(element);
    _list.sort(comparator);
  }

  T removeFirst() {
    return _list.removeAt(0);
  }

  @override
  int get length => _list.length;
}
