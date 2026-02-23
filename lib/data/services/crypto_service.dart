import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoService {
  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String generateSha1(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  String generateSha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Құпия сөздің мықтылығын тексереді (Қазақша жауап)
  String evaluatePasswordStrength(String password) {
    if (password.isEmpty) return 'Енгізілмеген';
    int score = 0;
    if (password.length > 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 0:
      case 1:
        return 'Өте әлсіз';
      case 2:
        return 'Орташа';
      case 3:
        return 'Жақсы';
      case 4:
        return 'Мықты';
      default:
        return 'Енгізілмеген';
    }
  }
}
