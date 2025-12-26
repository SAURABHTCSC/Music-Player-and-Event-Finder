import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musicmitra/screens/auth/login_screen.dart';
import 'package:musicmitra/screens/auth/signup_screen.dart';
import 'package:musicmitra/screens/auth/role_selection_screen.dart';

// --- Utility function for pumping the widget with a navigation stack ---
Future<void> pumpRoleSelectionScreen(WidgetTester tester, bool isLogin) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RoleSelectionScreen(isLogin: isLogin)));
          },
          child: const Text('Previous Screen'), // Key text for verifying pop
        ),
      ),
    ),
  );

  // Navigate to the RoleSelectionScreen (setting up the stack)
  await tester.tap(find.text('Previous Screen'));
  await tester.pumpAndSettle();
}

void main() {

  group('Role Selection: Login Flow (isLogin: true)', () {

    const bool isLogin = true;

    testWidgets('1. Renders the screen title as "Login As"', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);
      expect(find.text('Login As'), findsOneWidget);
    });

    testWidgets('2. "User" button navigates to the LoginScreen', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);

      // Use find.text for reliability
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Login As'), findsNothing);
    });

    testWidgets('3. "Event Organizer" button shows "Coming Soon..." SnackBar', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);

      // Use find.text for reliability
      await tester.tap(find.text('Event Organizer'));
      await tester.pump(); // Start SnackBar animation

      expect(find.text('Coming Soon...'), findsOneWidget);
      await tester.pumpAndSettle();
    });
  });

  group('Role Selection: Sign Up Flow (isLogin: false)', () {

    const bool isLogin = false;

    testWidgets('1. Renders the screen title as "Sign Up As"', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);
      expect(find.text('Sign Up As'), findsOneWidget);
    });

    testWidgets('2. "User" button navigates to the SignUpScreen', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);

      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      expect(find.byType(SignUpScreen), findsOneWidget);
      expect(find.text('Sign Up As'), findsNothing);
    });

    testWidgets('3. Back button returns to the previous screen (via mocked stack)', (WidgetTester tester) async {
      await pumpRoleSelectionScreen(tester, isLogin);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.text('Previous Screen'), findsOneWidget);
      expect(find.byType(RoleSelectionScreen), findsNothing);
    });
  });
}