import 'package:flutter/material.dart';

class MorseReferenceTable extends StatelessWidget {
  final Map<String, String> data;
  final String characterLabel;
  final String Function(String morseCode) getSoundDescription;
  final void Function(String character)? onPlayPressed;

  const MorseReferenceTable({
    super.key,
    required this.data,
    required this.characterLabel,
    required this.getSoundDescription,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hasPlay = onPlayPressed != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Table(
          border: TableBorder.all(),
          columnWidths: {
            0: const FlexColumnWidth(2),
            1: const FlexColumnWidth(3),
            2: const FlexColumnWidth(3),
            if (hasPlay) 3: const FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest),
              children: [
                _tableHeader(characterLabel, context),
                _tableHeader("Коды", context),
                _tableHeader("Дыбысы", context),
                if (hasPlay) _tableHeader("Тыңдау", context),
              ],
            ),
            ...data.entries.map(
              (entry) => TableRow(
                children: [
                  _tableCell(entry.key, context),
                  _tableCell(entry.value, context),
                  _tableCell(
                    getSoundDescription(entry.value),
                    context,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  if (hasPlay)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: IconButton(
                        icon: const Icon(Icons.play_arrow, size: 20),
                        onPressed: () => onPlayPressed!(entry.key),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _tableCell(String text, BuildContext context, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
