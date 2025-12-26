import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/widgets/bottom_nav_bar.dart';

// Helper function to wrap the widget in a test environment with a specific theme
Widget createBottomNavBar(Brightness brightness) {
  return MaterialApp(
    theme: ThemeData(
      brightness: brightness,
      // Provide a Scaffold background color as the NavBar uses Theme.of(context).scaffoldBackgroundColor
      scaffoldBackgroundColor: brightness == Brightness.dark ? Colors.black : Colors.white,
    ),
    home: const Scaffold(
      body: Center(child: Text('Body')),
      bottomNavigationBar: BottomNavBar(),
    ),
  );
}

void main() {
  group('BottomNavBar Widget Tests', () {

    // --- Theme and Styling Tests ---

    testWidgets('1. Renders 3 items with correct labels and icons', (WidgetTester tester) async {
      await tester.pumpWidget(createBottomNavBar(Brightness.light));

      // Check for labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Shows'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);

      // Check for icons
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.theaters), findsOneWidget);
      expect(find.byIcon(Icons.library_music), findsOneWidget);
    });

    testWidgets('2. Light Theme: Home icon color is Colors.red', (WidgetTester tester) async {
      await tester.pumpWidget(createBottomNavBar(Brightness.light));

      // Find the Home icon (which is selected via currentIndex: 0)
      final iconFinder = find.byIcon(Icons.home);
      final Icon iconWidget = tester.widget<Icon>(iconFinder);

      // Verify the color matches Colors.red
      expect(iconWidget.color, Colors.red);
    });

    testWidgets('3. Dark Theme: Home icon color is Colors.red[300]', (WidgetTester tester) async {
      await tester.pumpWidget(createBottomNavBar(Brightness.dark));

      // Find the Home icon (which is selected via currentIndex: 0)
      final iconFinder = find.byIcon(Icons.home);
      final Icon iconWidget = tester.widget<Icon>(iconFinder);

      // Verify the color matches Colors.red[300]
      expect(iconWidget.color, Colors.red[300]);
    });

    // --- Interaction Tests ---

    testWidgets('4. Tapping the "Shows" item shows the "Coming Soon" SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(createBottomNavBar(Brightness.light));

      // Find the "Shows" item (index 1) and tap it
      await tester.tap(find.byIcon(Icons.theaters));

      // Pump to trigger the SnackBar display
      await tester.pump();

      // Verify the SnackBar text is displayed
      expect(find.text('Coming Soon'), findsOneWidget);
    });

    testWidgets('5. Tapping the "Library" item shows the "Coming Soon" SnackBar', (WidgetTester tester) async {
      await tester.pumpWidget(createBottomNavBar(Brightness.light));

      // Find the "Library" item (index 2) and tap it
      await tester.tap(find.byIcon(Icons.library_music));

      await tester.pump();

      // Verify the SnackBar text is displayed
      expect(find.text('Coming Soon'), findsOneWidget);
    });
  });
}