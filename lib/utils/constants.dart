import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- App Colors ---
const Color kPrimaryColor = Color(0xFF6A5AE0); // Bright purple for buttons
const Color kBackgroundColor = Color(0xFF1B1D30); // Dark navy background
const Color kTextFieldColor = Color(0xFF43455C); // Lighter navy for text fields
const Color kTextColor = Colors.white;
const Color kSecondaryTextColor = Colors.white70;

// --- Text Styles ---
final kHeadlineTextStyle = GoogleFonts.poppins(
  color: kTextColor,
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

final kBodyTextStyle = GoogleFonts.poppins(
  color: kSecondaryTextColor,
  fontSize: 16,
);

// ✅ Light mode overrides for Profile Screen or pages with white background
final kHeadlineTextStyleLight = GoogleFonts.poppins(
  color: Colors.black,
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

final kBodyTextStyleLight = GoogleFonts.poppins(
  color: Colors.black87,
  fontSize: 16,
);

// --- Reusable Widgets & Functions ---

/// A simple styled text field for our forms
class AuthTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isPassword;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: kBodyTextStyle.copyWith(
            fontSize: 12,
            color: kTextColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: kTextColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: kTextFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// A helper function to show a SnackBar
void showSnackBar(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
    ),
  );
}

// A handy constant for Supabase client
final supabase = Supabase.instance.client;
