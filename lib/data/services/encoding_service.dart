import 'dart:convert';

class EncodingService {
  // Base64
  String encodeBase64(String input) {
    return base64.encode(utf8.encode(input));
  }

  String decodeBase64(String input) {
    try {
      return utf8.decode(base64.decode(input));
    } catch (e) {
      return 'Қате: Жарамсыз Base64 форматы';
    }
  }

  // Caesar Cipher
  String encodeCaesar(String input, int shift) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      var charCode = input.codeUnitAt(i);
      // Basic implementation for A-Z and a-z
      if (charCode >= 65 && charCode <= 90) {
        buffer.writeCharCode((charCode - 65 + shift) % 26 + 65);
      } else if (charCode >= 97 && charCode <= 122) {
        buffer.writeCharCode((charCode - 97 + shift) % 26 + 97);
      } else {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }

  String decodeCaesar(String input, int shift) {
    return encodeCaesar(input, 26 - (shift % 26));
  }

  // Vigenere Cipher
  String encodeVigenere(String input, String key) {
    if (key.isEmpty) return input;
    final buffer = StringBuffer();
    final cleanKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (cleanKey.isEmpty) return input;

    int keyIndex = 0;
    for (var i = 0; i < input.length; i++) {
      var charCode = input.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        int shift = cleanKey.codeUnitAt(keyIndex % cleanKey.length) - 65;
        buffer.writeCharCode((charCode - 65 + shift) % 26 + 65);
        keyIndex++;
      } else if (charCode >= 97 && charCode <= 122) {
        int shift = cleanKey.codeUnitAt(keyIndex % cleanKey.length) - 65;
        buffer.writeCharCode((charCode - 97 + shift) % 26 + 97);
        keyIndex++;
      } else {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }

  String decodeVigenere(String input, String key) {
    if (key.isEmpty) return input;
    final buffer = StringBuffer();
    final cleanKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (cleanKey.isEmpty) return input;

    int keyIndex = 0;
    for (var i = 0; i < input.length; i++) {
      var charCode = input.codeUnitAt(i);
      if (charCode >= 65 && charCode <= 90) {
        int shift = cleanKey.codeUnitAt(keyIndex % cleanKey.length) - 65;
        buffer.writeCharCode((charCode - 65 - shift + 26) % 26 + 65);
        keyIndex++;
      } else if (charCode >= 97 && charCode <= 122) {
        int shift = cleanKey.codeUnitAt(keyIndex % cleanKey.length) - 65;
        buffer.writeCharCode((charCode - 97 - shift + 26) % 26 + 97);
        keyIndex++;
      } else {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }

  // URL
  String encodeUrl(String input) {
    return Uri.encodeComponent(input);
  }

  String decodeUrl(String input) {
    try {
      return Uri.decodeComponent(input);
    } catch (e) {
      return 'Қате: Жарамсыз URL форматы';
    }
  }

  // Binary (0101)
  String encodeBinary(String input) {
    return input.codeUnits.map((char) => char.toRadixString(2).padLeft(8, '0')).join(' ');
  }

  String decodeBinary(String input) {
    try {
      return String.fromCharCodes(input.split(' ').map((bin) => int.parse(bin, radix: 2)));
    } catch (e) {
      return 'Қате: Жарамсыз екілік формат';
    }
  }

  // ASCII
  String encodeAscii(String input) {
    return input.codeUnits.join(' ');
  }

  String decodeAscii(String input) {
    try {
      return String.fromCharCodes(input.split(' ').map((ascii) => int.parse(ascii)));
    } catch (e) {
      return 'Қате: Жарамсыз ASCII коды';
    }
  }

  // Auto-detect if input might be Base64
  bool isLikelyBase64(String input) {
    if (input.isEmpty || input.length % 4 != 0) return false;
    final regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
    return regex.hasMatch(input);
  }
}
