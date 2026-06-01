import 'dart:math';
import 'package:flutter/material.dart';

class ScrambledText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final bool animateOnStart;

  const ScrambledText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 1000),
    this.animateOnStart = true,
  });

  @override
  State<ScrambledText> createState() => _ScrambledTextState();
}

class _ScrambledTextState extends State<ScrambledText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#%^&*';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animateOnStart) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ScrambledText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        String displayedText = '';
        double progress = _controller.value;
        
        for (int i = 0; i < widget.text.length; i++) {
          // If progress is far enough, show the real character
          if (progress > (i / widget.text.length)) {
            displayedText += widget.text[i];
          } else {
            // Otherwise show a random character
            displayedText += _chars[_random.nextInt(_chars.length)];
          }
        }
        
        return Text(
          displayedText,
          style: widget.style,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
