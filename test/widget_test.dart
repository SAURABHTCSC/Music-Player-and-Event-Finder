import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/main.dart';

void main() {
  testWidgets('MusicMitra app loads correctly', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const MusicMitraApp());

    // Check if app bar contains title "MusicMitra"
    expect(find.text('MusicMitra'), findsOneWidget);

    // Check if "For You" section is present
    expect(find.text('For You'), findsOneWidget);

    // Check if "Coming Soon……" text is present
    expect(find.text('Coming Soon……'), findsOneWidget);
  });
}
