import 'package:flutter/material.dart';
import 'package:musicmitra/screens/auth/login_screen.dart';
import 'package:musicmitra/screens/profile/profile_screen.dart';
import 'package:musicmitra/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _contactController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }
    if (_selectedGender == null) {
      showSnackBar(context, 'Please select a gender', isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'role': 'user', // Default role
        },
      );

      // After auth signup, update the profile table with extra info
      if (response.user != null) {
        await supabase.from('profiles').update({
          'full_name': _nameController.text.trim(),
          'contact_number': _contactController.text.trim(),
          'gender': _selectedGender,
        }).eq('id', response.user!.id);
      }

      if (mounted) {
        showSnackBar(context, 'Sign Up Successful! Check your email for verification.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
              (route) => false,
        );
      }
    } on AuthException catch (e) {
      if (mounted) showSnackBar(context, e.message, isError: true);
    } catch (e) {
      if (mounted) showSnackBar(context, 'An unexpected error occurred.', isError: true);
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, color: kTextColor),
                          Text('Back', style: TextStyle(color: kTextColor)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Create new\nAccount', style: kHeadlineTextStyle),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already Registered? ',
                        style: kBodyTextStyle,
                        children: const [
                          TextSpan(
                            text: 'Log in here.',
                            style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthTextField(label: 'Name', controller: _nameController),
                  const SizedBox(height: 16),
                  AuthTextField(label: 'Email', controller: _emailController),
                  const SizedBox(height: 16),
                  AuthTextField(label: 'Password', controller: _passwordController, isPassword: true),
                  const SizedBox(height: 16),
                  AuthTextField(label: 'Confirm Password', controller: _confirmPasswordController, isPassword: true),
                  const SizedBox(height: 16),
                  AuthTextField(label: 'Contact Number', controller: _contactController),
                  const SizedBox(height: 16),
                  _buildGenderDropdown(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign Up', style: TextStyle(color: kTextColor, fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GENDER',
          style: kBodyTextStyle.copyWith(fontSize: 12, color: kTextColor),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          hint: const Text('Select Gender', style: TextStyle(color: kSecondaryTextColor)),
          dropdownColor: kTextFieldColor,
          style: const TextStyle(color: kTextColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: kTextFieldColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: ['Male', 'Female', 'Other']
              .map((label) => DropdownMenuItem(child: Text(label), value: label))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          validator: (value) => value == null ? 'Please select a gender' : null,
        ),
      ],
    );
  }
}