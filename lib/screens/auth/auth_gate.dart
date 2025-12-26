import 'package:flutter/material.dart';
import 'package:musicmitra/main.dart';
import 'package:musicmitra/screens/auth/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:musicmitra/controllers/player_controller.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final session = snapshot.data?.session;

        if (session == null) {
          context.read<PlayerController>().clearUserSession();
          return const AuthScreen();
        } else {
          context.read<PlayerController>().initializeUserSession();
          // ✅ FIX: Call the MusicMitraHome constructor without any parameters.
          return const MusicMitraHome();
        }
      },
    );
  }
}