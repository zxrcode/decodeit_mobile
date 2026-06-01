import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const darkBgColor = Color(0xFF090D1A);
  static const darkCardColor = Color(0xFF121829);
  static const neonCyan = Color(0xFF00F0FF);
  static const neonPurple = Color(0xFF9D4EDD);
  static const neonGreen = Color(0xFF00F5D4);
  static const neonRed = Color(0xFFFF0055);
  static const borderColor = Color(0xFF1E2638);

  static ThemeData get lightTheme => _themeData(Brightness.light);
  static ThemeData get darkTheme => _themeData(Brightness.dark);

  static ThemeData _themeData(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primaryColor = isDark ? neonCyan : Colors.deepPurple;
    final secondaryColor = isDark ? neonPurple : Colors.purple;
    final accentColor = isDark ? neonGreen : Colors.teal;
    final bgColor = isDark ? darkBgColor : const Color(0xFFF8FAFC);
    final cardColor = isDark ? darkCardColor : Colors.white;

    final baseTheme = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bgColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        background: bgColor,
        surface: cardColor,
        error: isDark ? neonRed : Colors.red,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: isDark ? darkBgColor : Colors.deepPurple,
        elevation: 0,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? neonCyan : Colors.white,
          letterSpacing: 1.5,
        ),
        iconTheme: IconThemeData(
          color: isDark ? neonCyan : Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? borderColor : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? borderColor : Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? borderColor : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF0F1424) : Colors.grey.shade50,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
    );
  }
}
