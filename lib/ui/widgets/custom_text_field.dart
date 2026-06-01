import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'scrambled_text.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool readOnly;
  final bool showPaste;
  final bool showCopy;
  final bool showShare;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = '',
    this.maxLines = 1,
    this.readOnly = false,
    this.showPaste = false,
    this.showCopy = false,
    this.showShare = false,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextField(
              controller: controller,
              maxLines: maxLines,
              readOnly: readOnly,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: readOnly && controller.text.isNotEmpty ? const TextStyle(color: Colors.transparent) : null,
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: _buildActionButtons(context),
              ),
            ),
            if (readOnly && controller.text.isNotEmpty)
              Positioned(
                left: 12,
                right: 48, // Room for icons
                child: IgnorePointer(
                  child: ScrambledText(
                    text: controller.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget? _buildActionButtons(BuildContext context) {
    if (!showPaste && !showCopy && !showShare) return null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showPaste && !readOnly)
          IconButton(
            icon: const Icon(Icons.paste),
            tooltip: 'Қою (Paste)',
            onPressed: () async {
              ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
              if (data != null && data.text != null) {
                controller.text = data.text!;
                if (onChanged != null) {
                  onChanged!(controller.text);
                }
              }
            },
          ),
        if (showCopy)
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Көшіру (Copy)',
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: controller.text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Алмасу буферіне көшірілді')),
                );
              }
            },
          ),
        if (showShare)
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Бөлісу (Share)',
            onPressed: () {
              if (controller.text.isNotEmpty) {
                SharePlus.instance.share(ShareParams(text: controller.text));
              }
            },
          ),
      ],
    );
  }
}
