import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'organizer_dashboard_screen.dart';

class OrganizerAuthScreen extends StatefulWidget {
  const OrganizerAuthScreen({super.key});

  @override
  State<OrganizerAuthScreen> createState() => _OrganizerAuthScreenState();
}

class _OrganizerAuthScreenState extends State<OrganizerAuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;

  // Password Visibility Toggles
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  // ✅ 1. RESET PASSWORD LOGIC
  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email in the field first!")));
      return;
    }

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reset link sent! Check your email."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError("Error: $e");
      }
    }
  }

  // ✅ 2. SHOW FORGOT PASSWORD DIALOG
  void _showForgotPasswordDialog() {
    final dialogEmailCtrl = TextEditingController(text: _emailCtrl.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C3E), // Dark Theme Match
        title: Text("Reset Password", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Enter your email to receive a reset link.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: dialogEmailCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email Address",
                labelStyle: TextStyle(color: Colors.white60),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF6C63FF))),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () async {
              _emailCtrl.text = dialogEmailCtrl.text; // Sync with main controller
              await _resetPassword();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && _passCtrl.text != _confirmPassCtrl.text) {
      _showError("Passwords do not match!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- LOGIN ---
        final response = await Supabase.instance.client.auth.signInWithPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );

        if (response.user != null) {
          await _checkOrganizerAccess(response.user!.id);
        }
      } else {
        // --- SIGN UP ---
        final response = await Supabase.instance.client.auth.signUp(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
          data: {'role': 'organizer'},
        );

        if (response.user != null) {
          // Robust Data Insert
          await Supabase.instance.client.from('event_masters').insert({
            'id': response.user!.id,
            'full_name': _nameCtrl.text.trim(),
            'contact_number': _phoneCtrl.text.trim(),
            'pan_card_number': _panCtrl.text.trim(),
            'aadhaar_number': _aadhaarCtrl.text.trim(),
            'permanent_address': _addressCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Logging in...")));
            await _checkOrganizerAccess(response.user!.id);
          }
        }
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("An unexpected error occurred: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkOrganizerAccess(String userId) async {
    final data = await Supabase.instance.client
        .from('event_masters')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (mounted) {
      if (data != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()));
      } else {
        _showError("Access Denied: Not an Organizer account.");
        await Supabase.instance.client.auth.signOut();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C), // Dark Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, size: 60, color: Color(0xFF6C63FF)),
                const SizedBox(height: 20),
                Text(
                  _isLogin ? "Organizer Login" : "Partner Registration",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                _buildField("Email Address", _emailCtrl, Icons.email),

                // Password Field
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration("Password", Icons.lock).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                        onPressed: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (val) => (val != null && val.length < 6) ? "Min 6 chars required" : null,
                  ),
                ),

                // ✅ 3. FORGOT PASSWORD BUTTON (Only in Login Mode)
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPasswordDialog,
                      child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFF6C63FF), fontWeight: FontWeight.bold)),
                    ),
                  ),

                // Fields for Sign Up Only
                if (!_isLogin) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextFormField(
                      controller: _confirmPassCtrl,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Confirm Password", Icons.lock_outline).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.white54),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? "Confirm your password" : null,
                    ),
                  ),
                  _buildField("Full Name", _nameCtrl, Icons.person),
                  _buildField("Contact Number", _phoneCtrl, Icons.phone, isNumber: true),
                  _buildField("Aadhaar Number", _aadhaarCtrl, Icons.fingerprint, isNumber: true),
                  _buildField("PAN Card Number", _panCtrl, Icons.credit_card),
                  _buildField("Permanent Address", _addressCtrl, Icons.home),
                ],

                const SizedBox(height: 25),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(_isLogin ? "Login" : "Register Partner", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),

                const SizedBox(height: 15),

                // Toggle Login/Signup
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin ? "New here? Create Partner Account" : "Already registered? Login",
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label, icon),
        validator: (val) => val!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF2C2C3E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      labelStyle: const TextStyle(color: Colors.white60),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }
}