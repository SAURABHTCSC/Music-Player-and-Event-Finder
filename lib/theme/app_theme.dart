import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF6F6F6),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
  ),
  textTheme: GoogleFonts.dancingScriptTextTheme().copyWith(
    headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
    headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
    bodyMedium: const TextStyle(fontSize: 16),
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Colors.deepPurple,
    secondary: Colors.purpleAccent,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 1,
  ),
  textTheme: GoogleFonts.dancingScriptTextTheme().copyWith(
    headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
    headlineMedium: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Colors.white),
    headlineSmall: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.white),
    bodyMedium: const TextStyle(fontSize: 16, color: Colors.white70),
  ),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
    primary: Colors.deepPurple[200],
    secondary: Colors.purpleAccent,
  ),
);
