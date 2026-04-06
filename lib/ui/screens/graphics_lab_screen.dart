import 'package:flutter/material.dart';

class GraphicsLabScreen extends StatefulWidget {
  const GraphicsLabScreen({super.key});

  @override
  State<GraphicsLabScreen> createState() => _GraphicsLabScreenState();
}

class _GraphicsLabScreenState extends State<GraphicsLabScreen> {
  final List<int> _grid = List.filled(64, 0);

  void _toggleCell(int index) {
    setState(() {
      _grid[index] = _grid[index] == 0 ? 1 : 0;
    });
  }

  void _clearGrid() {
    setState(() {
      _grid.fillRange(0, 64, 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Пиксель торы'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                  ),
                  itemCount: 64,
                  itemBuilder: (context, index) {
                    final isActive = _grid[index] == 1;
                    return GestureDetector(
                      onTap: () => _toggleCell(index),
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isActive
                              ? colorScheme.primary
                              : Colors.black12,
                          border: Border.all(color: Colors.white10),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Екілік көрінісі:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: _clearGrid,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Тазалау"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: SelectableText(
                "[${_grid.join(', ')}]",
                style: const TextStyle(fontFamily: 'Courier New', fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
