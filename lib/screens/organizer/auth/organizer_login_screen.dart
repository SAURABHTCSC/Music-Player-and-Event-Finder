import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../organizer_dashboard_screen.dart';
import 'organizer_signup_screen.dart';

class OrganizerLoginScreen extends StatefulWidget {
  const OrganizerLoginScreen({super.key});

  @override
  State<OrganizerLoginScreen> createState() => _OrganizerLoginScreenState();
}

class _OrganizerLoginScreenState extends State<OrganizerLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      if (response.user != null) {
        // Check if this user is actually an organizer
        final organizerData = await Supabase.instance.client
            .from('event_masters')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        if (organizerData != null && mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()));
        } else {
          throw "Access Denied. Not an Organizer account.";
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.business_center, size: 80, color: Color(0xFF6C63FF)),
            const SizedBox(height: 20),
            Text("Organizer Portal", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),

            TextField(
              controller: _emailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Email / Contact Email",
                prefixIcon: const Icon(Icons.email, color: Colors.white70),
                fillColor: const Color(0xFF2C2C3E), filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                fillColor: const Color(0xFF2C2C3E), filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isLoading ? const CircularProgressIndicator() : const Text("Login", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerSignupScreen())),
              child: const Text("New Organizer? Sign Up Here", style: TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }
}