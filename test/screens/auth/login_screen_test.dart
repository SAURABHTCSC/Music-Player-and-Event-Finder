import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/screens/auth/login_screen.dart';
import 'package:musicmitra/screens/auth/signup_screen.dart';

void main() {
  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('LoginScreen Widget Tests', () {

    /// -------------------------------
    /// 1. UI Rendering
    /// -------------------------------
    testWidgets(
        '1. Renders all essential UI elements and initial text',
            (WidgetTester tester) async {
          await pumpLoginScreen(tester);

          // Title & subtitle
          expect(find.text('Login'), findsWidgets);
          expect(find.text('Sign in to continue.'), findsOneWidget);

          // Two input fields (Email + Password)
          expect(find.byType(TextFormField), findsNWidgets(2));

          // Login button
          expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

          // Signup link
          expect(find.text('Signup!'), findsOneWidget);
        });

    /// -------------------------------
    /// 2. Back button navigation
    /// -------------------------------
    testWidgets(
        '2. "Back" button pops the route',
            (WidgetTester tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text('Open Login'),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open Login'));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          expect(find.text('Open Login'), findsOneWidget);
        });

    /// -------------------------------
    /// 3. Signup navigation
    /// -------------------------------
    testWidgets(
        '3. "Signup" navigates to SignUpScreen',
            (WidgetTester tester) async {
          await pumpLoginScreen(tester);

          await tester.tap(find.text('Signup!'));
          await tester.pumpAndSettle();

          expect(find.byType(SignUpScreen), findsOneWidget);
        });

    /// -------------------------------
    /// 4. Validation blocks login when empty
    /// -------------------------------
    testWidgets(
        '4. Prevents login when fields are empty',
            (WidgetTester tester) async {
          await pumpLoginScreen(tester);

          await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
          await tester.pumpAndSettle();

          // Still on LoginScreen → validation worked
          expect(find.byType(LoginScreen), findsOneWidget);
        });
  });
}
