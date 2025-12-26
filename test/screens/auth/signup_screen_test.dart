import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/screens/auth/signup_screen.dart';
import 'package:musicmitra/screens/auth/login_screen.dart';

void main() {
  Future<void> pumpSignUpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SignUpScreen Widget Tests', () {

    /// -------------------------------
    /// 1. UI Rendering
    /// -------------------------------
    testWidgets(
        '1. Renders all essential UI elements',
            (WidgetTester tester) async {
          await pumpSignUpScreen(tester);

          // Title
          expect(find.textContaining('Create new'), findsOneWidget);

          // 5 input fields (Name, Email, Password, Confirm, Contact)
          expect(find.byType(TextFormField), findsNWidgets(5));

          // Gender dropdown
          expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);

          // Sign up button
          expect(find.widgetWithText(ElevatedButton, 'Sign Up'), findsOneWidget);
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
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  child: const Text('Open Signup'),
                ),
              ),
            ),
          );

          await tester.tap(find.text('Open Signup'));
          await tester.pumpAndSettle();

          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();

          expect(find.text('Open Signup'), findsOneWidget);
        });

    /// -------------------------------
    /// 3. Login navigation (RichText)
    /// -------------------------------
    testWidgets(
        '3. "Log in here" navigates to LoginScreen',
            (WidgetTester tester) async {
          await pumpSignUpScreen(tester);

          // Find RichText containing "Log in here."
          final richTextFinder = find.byWidgetPredicate(
                (widget) =>
            widget is RichText &&
                widget.text.toPlainText().contains('Log in here.'),
          );

          expect(richTextFinder, findsOneWidget);

          await tester.tap(richTextFinder);
          await tester.pumpAndSettle();

          expect(find.byType(LoginScreen), findsOneWidget);
        });

    /// -------------------------------
    /// 4. Validation blocks signup when empty
    /// -------------------------------
    testWidgets(
        '4. Prevents signup when fields are empty',
            (WidgetTester tester) async {
          await pumpSignUpScreen(tester);

          await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
          await tester.pumpAndSettle();

          expect(find.byType(SignUpScreen), findsOneWidget);
        });

    /// -------------------------------
    /// 5. Gender not selected blocks signup
    /// -------------------------------
    testWidgets(
        '5. Prevents signup when gender is not selected',
            (WidgetTester tester) async {
          await pumpSignUpScreen(tester);

          await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
          await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
          await tester.enterText(find.byType(TextFormField).at(2), 'password123');
          await tester.enterText(find.byType(TextFormField).at(3), 'password123');
          await tester.enterText(find.byType(TextFormField).at(4), '9876543210');

          await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
          await tester.pumpAndSettle();

          expect(find.byType(SignUpScreen), findsOneWidget);
        });
  });
}
