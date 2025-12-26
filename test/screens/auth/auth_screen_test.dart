import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/screens/auth/auth_screen.dart';

/// Fake Home Screen to replace MusicMitraHome in tests
class FakeHomeScreen extends StatelessWidget {
  const FakeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('HOME_SCREEN')),
    );
  }
}

Future<void> pumpAuthScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const AuthScreen(),

      /// 🔑 CRITICAL: must NEVER return null
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const FakeHomeScreen(),
        );
      },
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthScreen Widget Tests', () {
    testWidgets('1. UI renders correctly', (tester) async {
      await pumpAuthScreen(tester);

      expect(find.text('MusicMitra.'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('2. Login button is tappable', (tester) async {
      await pumpAuthScreen(tester);

      await tester.tap(find.text('Login'));
      await tester.pump();
    });

    testWidgets('3. Sign Up button is tappable', (tester) async {
      await pumpAuthScreen(tester);

      await tester.tap(find.text('Sign Up'));
      await tester.pump();
    });

    /// ✅ FIXED FOREVER
    testWidgets(
      '4. Continue as Guest navigates to home screen',
          (tester) async {
        await pumpAuthScreen(tester);

        await tester.tap(find.text('Continue as Guest'));
        await tester.pumpAndSettle();

        /// ✔ Navigation confirmed without touching real MusicMitraHome
        expect(find.text('HOME_SCREEN'), findsOneWidget);
      },
    );
  });
}
