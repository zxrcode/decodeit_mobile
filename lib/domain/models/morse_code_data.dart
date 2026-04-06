class MorseCodeData {
  static const Map<String, String> morseCodeMap = {
    // Letters
    'A': '.-',
    'B': '-...',
    'C': '-.-.',
    'D': '-..',
    'E': '.',
    'F': '..-.',
    'G': '--.',
    'H': '....',
    'I': '..',
    'J': '.---',
    'K': '-.-',
    'L': '.-..',
    'M': '--',
    'N': '-.',
    'O': '---',
    'P': '.--.',
    'Q': '--.-',
    'R': '.-.',
    'S': '...',
    'T': '-',
    'U': '..-',
    'V': '...-',
    'W': '.--',
    'X': '-..-',
    'Y': '-.--',
    'Z': '--..',
    // Numbers
    '0': '-----',
    '1': '.----',
    '2': '..---',
    '3': '...--',
    '4': '....-',
    '5': '.....',
    '6': '-....',
    '7': '--...',
    '8': '---..',
    '9': '----.',
    // Punctuation
    '.': '.-.-.-',
    ',': '--..--',
    '?': '..--..',
    '!': '-.-.--',
    '/': '-..-.',
    '(': '-.--.',
    ')': '-.--.-',
    '&': '.-...',
    ':': '---...',
    ';': '-.-.-.',
    '=': '-...-',
    '+': '.-.-.',
    '-': '-....-',
    '"': '.-..-.',
    '\'': '.----.',
    '@': '.--.-.',
    // Space
    ' ': '/',
  };

  static final Map<String, String> reverseMorseMap =
      morseCodeMap.map((key, value) => MapEntry(value, key));

  static Map<String, String> get alphabetMap => Map.fromEntries(
        morseCodeMap.entries
            .where((e) => RegExp(r'^[A-Z]$').hasMatch(e.key)),
      );

  static Map<String, String> get numberMap => Map.fromEntries(
        morseCodeMap.entries
            .where((e) => RegExp(r'^[0-9]$').hasMatch(e.key)),
      );

  static Map<String, String> get punctuationMap => Map.fromEntries(
        morseCodeMap.entries
            .where((e) => RegExp(r'''[.,?!/()&:;=+\-"'@]''').hasMatch(e.key)),
      );

  static String getMorseSound(String morseCode) {
    if (morseCode == '/') return '(space)';
    final parts = morseCode.split('');
    final sounds = <String>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i] == '.') {
        sounds.add(i == parts.length - 1 ? 'dit' : 'di');
      } else if (parts[i] == '-') {
        sounds.add('dah');
      }
    }
    return sounds.join('-');
  }

  static String textToMorse(String text) {
    return text
        .toUpperCase()
        .split('')
        .map((char) => morseCodeMap[char] ?? '')
        .where((code) => code.isNotEmpty)
        .join(' ');
  }

  static String morseToText(String morse) {
    return morse
        .split(' ')
        .map((code) => reverseMorseMap[code] ?? '')
        .join('');
  }

  static const List<Map<String, String>> quickExamples = [
    {'label': 'SOS', 'text': 'SOS'},
    {'label': 'I LOVE YOU', 'text': 'I LOVE YOU'},
    {'label': 'HELP', 'text': 'HELP'},
    {'label': 'HELLO', 'text': 'HELLO'},
    {'label': 'HI', 'text': 'HI'},
  ];
}
