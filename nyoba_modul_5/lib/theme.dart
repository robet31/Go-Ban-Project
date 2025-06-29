// Di theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFF41B06E), // Hijau utama
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF41B06E),
    secondary: Color(0xFF8DECB4), // Hijau muda
  ),
  scaffoldBackgroundColor: const Color(0xFFFFF5E0), // Krem
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF141E46)), // Biru tua
    bodyMedium: TextStyle(color: Color(0xFF141E46)),
  ),
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF41B06E),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF41B06E),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontFamily: 'Poppins'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
    ),
  ),
);




