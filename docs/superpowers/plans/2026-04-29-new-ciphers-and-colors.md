# Добавление новых шифров и цветового конвертера

> **Для агентных исполнителей:** ТРЕБУЕМЫЙ ПОД-НАВЫК: Используйте superpowers:subagent-driven-development (рекомендуется) или superpowers:executing-plans для пошагового выполнения этого плана. Шаги используют синтаксис чекбоксов (`- [ ]`) для отслеживания.

**Цель:** Добавить в приложение шифры Цезаря, Виженера, Атбаш (с поддержкой казахского алфавита) и конвертер цветов HEX/RGB/CMYK.

**Архитектура:** Логика выносится в отдельные сервисы `CipherService` и `ColorService`. UI реализуется в виде отдельных экранов в папке `lib/ui/screens/tools/`. Регистрация сервисов через `GetIt` в `di.dart`.

**Стек технологий:** Flutter (Dart), GetIt для DI.

---

### Задача 1: Создание CipherService

**Файлы:**
- Создать: `lib/data/services/cipher_service.dart`

- [ ] **Шаг 1: Реализовать базовую логику алфавитов и шифр Атбаш**
```dart
class CipherService {
  static const String latinUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String kazakhUpper = 'АӘБВГҒДЕЁЖЗИЙКҚЛМНҢОӨПРСТУҰҮФХҺЦЧШЩЪЫІЬЭЮЯ';

  String atbash(String input) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      String upperChar = char.toUpperCase();
      bool isLower = char != upperChar;

      if (latinUpper.contains(upperChar)) {
        int index = latinUpper.indexOf(upperChar);
        String reversed = latinUpper[latinUpper.length - 1 - index];
        result.write(isLower ? reversed.toLowerCase() : reversed);
      } else if (kazakhUpper.contains(upperChar)) {
        int index = kazakhUpper.indexOf(upperChar);
        String reversed = kazakhUpper[kazakhUpper.length - 1 - index];
        result.write(isLower ? reversed.toLowerCase() : reversed);
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }
}
```

- [ ] **Шаг 2: Реализовать шифр Цезаря**
```dart
  String caesar(String input, int shift, {bool decrypt = false}) {
    StringBuffer result = StringBuffer();
    int effectiveShift = decrypt ? -shift : shift;

    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      String upperChar = char.toUpperCase();
      bool isLower = char != upperChar;

      if (latinUpper.contains(upperChar)) {
        int len = latinUpper.length;
        int index = (latinUpper.indexOf(upperChar) + effectiveShift) % len;
        if (index < 0) index += len;
        String shifted = latinUpper[index];
        result.write(isLower ? shifted.toLowerCase() : shifted);
      } else if (kazakhUpper.contains(upperChar)) {
        int len = kazakhUpper.length;
        int index = (kazakhUpper.indexOf(upperChar) + effectiveShift) % len;
        if (index < 0) index += len;
        String shifted = kazakhUpper[index];
        result.write(isLower ? shifted.toLowerCase() : shifted);
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }
```

- [ ] **Шаг 3: Реализовать шифр Виженера**
```dart
  String vigenere(String input, String key, {bool decrypt = false}) {
    if (key.isEmpty) return input;
    StringBuffer result = StringBuffer();
    int keyIndex = 0;
    String upperKey = key.toUpperCase();

    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      String upperChar = char.toUpperCase();
      bool isLower = char != upperChar;

      int shift = 0;
      String keyChar = upperKey[keyIndex % upperKey.length];
      if (latinUpper.contains(keyChar)) {
        shift = latinUpper.indexOf(keyChar);
      } else if (kazakhUpper.contains(keyChar)) {
        shift = kazakhUpper.indexOf(keyChar);
      }

      int effectiveShift = decrypt ? -shift : shift;

      if (latinUpper.contains(upperChar)) {
        int len = latinUpper.length;
        int index = (latinUpper.indexOf(upperChar) + effectiveShift) % len;
        if (index < 0) index += len;
        result.write(isLower ? latinUpper[index].toLowerCase() : latinUpper[index]);
        keyIndex++;
      } else if (kazakhUpper.contains(upperChar)) {
        int len = kazakhUpper.length;
        int index = (kazakhUpper.indexOf(upperChar) + effectiveShift) % len;
        if (index < 0) index += len;
        result.write(isLower ? kazakhUpper[index].toLowerCase() : kazakhUpper[index]);
        keyIndex++;
      } else {
        result.write(char);
      }
    }
    return result.toString();
  }
```

- [ ] **Шаг 4: Закоммитить сервис**
```bash
git add lib/data/services/cipher_service.dart
git commit -m "feat: add CipherService with Caesar, Vigenere and Atbash"
```

---

### Задача 2: Создание ColorService

**Файлы:**
- Создать: `lib/data/services/color_service.dart`

- [ ] **Шаг 1: Реализовать конвертацию HEX, RGB, CMYK**
```dart
import 'dart:ui';

class ColorService {
  Color? hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) hex = 'FF' + hex;
    if (hex.length != 8) return null;
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return null;
    }
  }

  Map<String, int> colorToRgb(Color color) {
    return {'r': color.red, 'g': color.green, 'b': color.blue};
  }

  Map<String, double> rgbToCmyk(int r, int g, int b) {
    double rf = r / 255;
    double gf = g / 255;
    double bf = b / 255;

    double k = 1 - [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    if (k == 1) return {'c': 0, 'm': 0, 'y': 0, 'k': 1};

    double c = (1 - rf - k) / (1 - k);
    double m = (1 - gf - k) / (1 - k);
    double y = (1 - bf - k) / (1 - k);

    return {'c': c, 'm': m, 'y': y, 'k': k};
  }

  String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
```

- [ ] **Шаг 2: Закоммитить сервис**
```bash
git add lib/data/services/color_service.dart
git commit -m "feat: add ColorService for HEX/RGB/CMYK conversion"
```

---

### Задача 3: Регистрация в DI

**Файлы:**
- Изменить: `lib/core/di.dart`

- [ ] **Шаг 1: Зарегистрировать новые сервисы**
```dart
// В начало файла
import '../data/services/cipher_service.dart';
import '../data/services/color_service.dart';

// В функцию setupServiceLocator
getIt.registerLazySingleton<CipherService>(() => CipherService());
getIt.registerLazySingleton<ColorService>(() => ColorService());
```

- [ ] **Шаг 2: Закоммитить изменения**
```bash
git add lib/core/di.dart
git commit -m "feat: register CipherService and ColorService in DI"
```

---

### Задача 4: Экран шифра Цезаря

**Файлы:**
- Создать: `lib/ui/screens/tools/caesar_cipher_screen.dart`

- [ ] **Шаг 1: Создать экран с вводом текста и слайдером сдвига**
(Реализовать Stateful widget, использующий `CipherService`)

---

### Задача 2: Экран шифра Виженера

**Файлы:**
- Создать: `lib/ui/screens/tools/vigenere_cipher_screen.dart`

- [ ] **Шаг 1: Создать экран с вводом текста и поля ключа**
(Реализовать Stateful widget, использующий `CipherService`)

---

### Задача 6: Экран Атбаш

**Файлы:**
- Создать: `lib/ui/screens/tools/atbash_cipher_screen.dart`

- [ ] **Шаг 1: Создать простой экран для Атбаш**

---

### Задача 7: Экран конвертера цветов

**Файлы:**
- Создать: `lib/ui/screens/tools/color_converter_screen.dart`

- [ ] **Шаг 1: Создать экран конвертера**
(Поле ввода HEX, отображение RGB и CMYK, предпросмотр цвета)

---

### Задача 8: Интеграция в MainScreen

**Файлы:**
- Изменить: `lib/ui/screens/main_screen.dart`

- [ ] **Шаг 1: Добавить новые карточки инструментов в GridView**
```dart
      _ToolItem('Цезарь шифры', Icons.text_rotation_none, Colors.blueGrey, const CaesarCipherScreen()),
      _ToolItem('Виженер шифры', Icons.vpn_key, Colors.deepPurple, const VigenereCipherScreen()),
      _ToolItem('Атбаш (Зеркало)', Icons.compare_arrows, Colors.blueAccent, const AtbashCipherScreen()),
      _ToolItem('Түс конвертері', Icons.palette, Colors.pinkAccent, const ColorConverterScreen()),
```

- [ ] **Шаг 2: Закоммитить финальные изменения**
```bash
git add .
git commit -m "feat: integrate all new tools into MainScreen"
```
