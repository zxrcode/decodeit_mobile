import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/models/morse_code_data.dart';
import '../../data/services/morse_audio_service.dart';

enum LearnCategory { letters, numbers, punctuation }

class MorseLearnScreen extends StatefulWidget {
  final MorseAudioService audioService;

  const MorseLearnScreen({super.key, required this.audioService});

  @override
  State<MorseLearnScreen> createState() => _MorseLearnScreenState();
}

class _MorseLearnScreenState extends State<MorseLearnScreen> {
  LearnCategory _category = LearnCategory.letters;
  String _targetChar = '';
  String _userInput = '';
  bool? _isCorrect;
  bool _hideTarget = false;
  final Random _random = Random();

  // Progress tracking: character -> {correct: int, wrong: int}
  final Map<String, Map<String, int>> _progress = {};

  Map<String, String> get _currentMap {
    switch (_category) {
      case LearnCategory.letters:
        return MorseCodeData.alphabetMap;
      case LearnCategory.numbers:
        return MorseCodeData.numberMap;
      case LearnCategory.punctuation:
        return MorseCodeData.punctuationMap;
    }
  }

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    final keys = _currentMap.keys.toList();
    setState(() {
      _targetChar = keys[_random.nextInt(keys.length)];
      _userInput = '';
      _isCorrect = null;
    });
  }

  void _addSymbol(String symbol) {
    setState(() {
      _userInput += symbol;
      _isCorrect = null;
    });
  }

  void _addSpace() {
    if (_userInput.isNotEmpty && !_userInput.endsWith(' ')) {
      setState(() {
        _userInput += ' ';
        _isCorrect = null;
      });
    }
  }

  void _deleteLastSymbol() {
    if (_userInput.isNotEmpty) {
      setState(() {
        _userInput = _userInput.substring(0, _userInput.length - 1);
        _isCorrect = null;
      });
    }
  }

  void _checkAnswer() {
    final correctMorse = _currentMap[_targetChar];
    if (correctMorse == null) return;

    final correct = _userInput.trim() == correctMorse;
    setState(() {
      _isCorrect = correct;
      _progress.putIfAbsent(_targetChar, () => {'correct': 0, 'wrong': 0});
      if (correct) {
        _progress[_targetChar]!['correct'] =
            _progress[_targetChar]!['correct']! + 1;
      } else {
        _progress[_targetChar]!['wrong'] =
            _progress[_targetChar]!['wrong']! + 1;
      }
    });
  }

  void _exportProgress() {
    if (_progress.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('Character,Correct,Wrong,Accuracy');
    for (final entry in _progress.entries) {
      final correct = entry.value['correct']!;
      final wrong = entry.value['wrong']!;
      final total = correct + wrong;
      final accuracy = total > 0 ? (correct / total * 100).toStringAsFixed(1) : '0.0';
      buffer.writeln('${entry.key},$correct,$wrong,$accuracy%');
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Прогресс CSV алмасу буферіне көшірілді'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Морзе үйрену'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Category selector
              Wrap(
                spacing: 8,
                children: LearnCategory.values.map((cat) {
                  String label = '';
                  switch (cat) {
                    case LearnCategory.letters:
                      label = 'Әліпби';
                    case LearnCategory.numbers:
                      label = 'Сандар';
                    case LearnCategory.punctuation:
                      label = 'Тыныс белгілері';
                  }
                  return ChoiceChip(
                    label: Text(label),
                    selected: _category == cat,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _category = cat);
                        _nextQuestion();
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // Hide target toggle
              Row(
                children: [
                  const Text('Таңбаны жасыру (қиынырақ)'),
                  Switch(
                    value: _hideTarget,
                    onChanged: (v) => setState(() => _hideTarget = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Target character display
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _isCorrect == null
                      ? Theme.of(context).colorScheme.primaryContainer
                      : _isCorrect!
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCorrect == null
                        ? Theme.of(context).colorScheme.primary
                        : _isCorrect!
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _hideTarget ? '?' : _targetChar,
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    if (_isCorrect == false) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Дұрыс: ${_currentMap[_targetChar]}',
                        style: const TextStyle(
                            fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // User input display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _userInput.isEmpty ? '(морзе кодын енгізіңіз)' : _userInput,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _userInput.isEmpty ? Colors.grey : null,
                    letterSpacing: 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              // Input buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _inputButton('Нүкте (.)', () => _addSymbol('.')),
                  _inputButton('Сызықша (-)', () => _addSymbol('-')),
                  _inputButton('Бос орын', _addSpace),
                  _inputButton('Өшіру', _deleteLastSymbol,
                      color: Theme.of(context).colorScheme.error),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _checkAnswer,
                    icon: const Icon(Icons.check),
                    label: const Text('Тексеру'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextQuestion,
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Өткізіп жіберу'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        widget.audioService.playCharacter(_targetChar),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Тыңдау'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Progress table
              if (_progress.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Прогресс',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      onPressed: _exportProgress,
                      tooltip: 'CSV экспорттау',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest),
                      children: const [
                        _ProgressHeader('Таңба'),
                        _ProgressHeader('Дұрыс'),
                        _ProgressHeader('Қате'),
                        _ProgressHeader('Пайыз'),
                      ],
                    ),
                    ..._progress.entries.map((entry) {
                      final correct = entry.value['correct']!;
                      final wrong = entry.value['wrong']!;
                      final total = correct + wrong;
                      final rate = total > 0
                          ? '${(correct / total * 100).toStringAsFixed(0)}%'
                          : '-';
                      return TableRow(children: [
                        _ProgressCell(entry.key),
                        _ProgressCell('$correct',
                            color: Theme.of(context).colorScheme.primary),
                        _ProgressCell('$wrong',
                            color: Theme.of(context).colorScheme.error),
                        _ProgressCell(rate),
                      ]);
                    }),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputButton(String label, VoidCallback onPressed, {Color? color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final String text;
  const _ProgressHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center),
    );
  }
}

class _ProgressCell extends StatelessWidget {
  final String text;
  final Color? color;
  const _ProgressCell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(text,
          style: TextStyle(color: color ?? Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center),
    );
  }
}
