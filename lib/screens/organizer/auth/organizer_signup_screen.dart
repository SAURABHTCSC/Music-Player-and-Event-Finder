import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../organizer_dashboard_screen.dart';

class OrganizerSignupScreen extends StatefulWidget {
  const OrganizerSignupScreen({super.key});

  @override
  State<OrganizerSignupScreen> createState() => _OrganizerSignupScreenState();
}

class _OrganizerSignupScreenState extends State<OrganizerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Sign Up in Auth System
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        data: {'role': 'organizer'}, // Metadata to identify user type
      );

      if (authResponse.user == null) throw "Sign up failed. Please try again.";

      // 2. Insert into event_masters table
      await Supabase.instance.client.from('event_masters').insert({
        'id': authResponse.user!.id,
        'full_name': _nameCtrl.text.trim(),
        'contact_number': _phoneCtrl.text.trim(),
        'pan_card_number': _panCtrl.text.trim(),
        'aadhaar_number': _aadhaarCtrl.text.trim(),
        'permanent_address': _addressCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Become an Organizer", style: GoogleFonts.poppins(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Create your Event Master Account", style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 20),

              _buildTextField("Full Name", _nameCtrl, Icons.person),
              _buildTextField("Email", _emailCtrl, Icons.email),
              _buildTextField("Password", _passwordCtrl, Icons.lock, isPassword: true),
              _buildTextField("Contact Number", _phoneCtrl, Icons.phone, isNumber: true),

              const Divider(color: Colors.white24, height: 40),
              const Text("Verification Details", style: TextStyle(color: Colors.orangeAccent, fontSize: 14)),
              const SizedBox(height: 10),

              _buildTextField("Aadhaar Number", _aadhaarCtrl, Icons.fingerprint, isNumber: true),
              _buildTextField("PAN Card Number", _panCtrl, Icons.credit_card),
              _buildTextField("Permanent Address", _addressCtrl, Icons.home, maxLines: 2),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register & Dashboard", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon,
      {bool isPassword = false, bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          filled: true,
          fillColor: const Color(0xFF2C2C3E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (val) => val!.isEmpty ? "$label is required" : null,
      ),
    );
  }
}