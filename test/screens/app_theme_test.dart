import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicmitra/theme/app_theme.dart'; // Import the file containing lightTheme and darkTheme

void main() {
  // We use TestWidgets since ThemeData is often used in the widget tree,
  // though we mostly verify object properties directly.

  group('App Theme Definitions', () {

    // --- Light Theme Tests ---
    group('Light Theme Configuration', () {
      final theme = lightTheme;

      test('1. Light Theme has correct Brightness and Scaffold Color', () {
        expect(theme.brightness, Brightness.light);
        expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F6F6));
      });

      test('2. Light Theme AppBar has correct colors', () {
        expect(theme.appBarTheme.backgroundColor, Colors.white);
        expect(theme.appBarTheme.foregroundColor, Colors.black);
        expect(theme.appBarTheme.elevation, 1);
      });

      test('3. Light Theme TextTheme uses DancingScript and defines headlines', () {
        // Check if the base font theme matches GoogleFonts.dancingScriptTextTheme()
        expect(theme.textTheme.bodyLarge?.fontFamily, GoogleFonts.dancingScript().fontFamily);

        // Check a specific headline style
        expect(theme.textTheme.headlineLarge?.fontSize, 32);
        expect(theme.textTheme.headlineLarge?.fontWeight, FontWeight.bold);
        expect(theme.textTheme.headlineMedium?.fontSize, 26);
      });

      test('4. Light Theme ColorScheme has correct primary and secondary colors', () {
        expect(theme.colorScheme.primary, Colors.deepPurple);
        expect(theme.colorScheme.secondary, Colors.purpleAccent);
      });
    });

    // --- Dark Theme Tests ---
    group('Dark Theme Configuration', () {
      final theme = darkTheme;

      test('1. Dark Theme has correct Brightness and Scaffold Color', () {
        expect(theme.brightness, Brightness.dark);
        expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
      });

      test('2. Dark Theme AppBar has correct colors', () {
        expect(theme.appBarTheme.backgroundColor, const Color(0xFF1E1E1E));
        expect(theme.appBarTheme.foregroundColor, Colors.white);
        expect(theme.appBarTheme.elevation, 1);
      });

      test('3. Dark Theme TextTheme defines headlines with white color', () {
        // Check if the base font theme matches GoogleFonts.dancingScriptTextTheme()
        expect(theme.textTheme.bodyLarge?.fontFamily, GoogleFonts.dancingScript().fontFamily);

        // Check a specific headline style, including the required white color
        expect(theme.textTheme.headlineLarge?.fontSize, 32);
        expect(theme.textTheme.headlineLarge?.color, Colors.white);

        // Check body color
        expect(theme.textTheme.bodyMedium?.color, Colors.white70);
      });

      test('4. Dark Theme ColorScheme has correct primary and secondary colors', () {
        expect(theme.colorScheme.primary, Colors.deepPurple[200]);
        expect(theme.colorScheme.secondary, Colors.purpleAccent);
      });
    });
  });
}