import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Ensure the following paths are correct for your project
import 'package:musicmitra/screens/category_songs_screen.dart';
import 'package:musicmitra/controllers/player_controller.dart';
import 'package:musicmitra/screens/full_music_player_screen.dart';
import 'package:musicmitra/data/category_songs_data.dart'; // Required for global data access

// --- MOCKING SETUP ---

// CRITICAL: Tells the builder to generate the mock class
@GenerateMocks([PlayerController])
// CRITICAL: Import the generated mock file. Assuming the file is in the same directory (test/screens/).
import 'category_song_screen_test.mocks.dart';

// Global mock instance
final mockPlayerController = MockPlayerController();

// A test wrapper to inject the mock controller and provide a back navigation context
Widget createCategorySongsScreen({
  required String categoryName,
  required VoidCallback onBack,
}) {
  return MaterialApp(
    home: InheritedProvider<PlayerController>( // Inject the mock using Provider
      create: (_) => mockPlayerController,
      child: CategorySongsScreen(categoryName: categoryName, onBack: onBack),
    ),
  );
}

// --- ACTUAL TEST SUITE ---

void main() {
  // Set up mock responses for the player controller before each test
  setUp(() {
    reset(mockPlayerController);
  });

  group('CategorySongsScreen Widget Tests', () {

    // Helper to simulate the onBack callback was called
    bool backCalled = false;
    void mockOnBack() {
      backCalled = true;
    }

    // --- Test Group 1: Data Availability ---

    testWidgets('1. Renders "No songs available" when category data is null/empty', (WidgetTester tester) async {
      // We rely on 'Nonexistent Category' not existing in your actual data map
      await tester.pumpWidget(createCategorySongsScreen(
        categoryName: 'Nonexistent Category',
        onBack: mockOnBack,
      ));

      expect(find.text('No songs available in this category.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    // --- Test Group 2: UI and Interaction ---

    testWidgets('2. Renders AppBar with correct title and back button', (WidgetTester tester) async {
      // We assume 'Pop Hits' exists in your global data for a successful list view
      const categoryName = 'Pop Hits';
      await tester.pumpWidget(createCategorySongsScreen(
        categoryName: categoryName,
        onBack: mockOnBack,
      ));

      expect(find.text(categoryName), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('3. Tapping back button executes the onBack callback', (WidgetTester tester) async {
      backCalled = false;
      await tester.pumpWidget(createCategorySongsScreen(
        categoryName: 'Pop Hits',
        onBack: mockOnBack,
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('4. Renders song list with correct title and artist', (WidgetTester tester) async {
      const categoryName = 'Pop Hits';
      await tester.pumpWidget(createCategorySongsScreen(
        categoryName: categoryName,
        onBack: mockOnBack,
      ));

      // Assuming the first song in the 'Pop Hits' category has the title 'Pop Song 1'
      // NOTE: You must verify this text exists in your actual category_songs_data.dart
      expect(find.text('Pop Song 1'), findsOneWidget);
      expect(find.text('Artist Y'), findsOneWidget);
    });

    testWidgets('5. Tapping a song calls player.setPlaylist and navigates to FullMusicPlayerScreen', (WidgetTester tester) async {
      const categoryName = 'Pop Hits';
      final List<Map<String, String>>? categoryData = categorySongsData[categoryName];

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedProvider<PlayerController>(
            create: (_) => mockPlayerController,
            child: CategorySongsScreen(categoryName: categoryName, onBack: mockOnBack),
          ),
        ),
      );

      if (categoryData == null || categoryData.isEmpty) {
        fail('Test skipped: Category data for "$categoryName" is missing, cannot verify song tap.');
      }

      // Tap the first song title
      await tester.tap(find.text(categoryData[0]['title']!));
      await tester.pumpAndSettle();

      // CRITICAL: We verify the mock controller was interacted with.
      verify(mockPlayerController.setPlaylist(categoryData, 0)).called(1);

      expect(find.byType(FullMusicPlayerScreen), findsOneWidget);
    });
  });
}