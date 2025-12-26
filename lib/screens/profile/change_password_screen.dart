import 'package:flutter/material.dart';
import 'package:musicmitra/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text.trim()),
      );
      if (mounted) {
        showSnackBar(context, 'Password updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Failed to update password. Please try again.', isError: true);
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(color: kTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: kTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update your password', style: kHeadlineTextStyle.copyWith(fontSize: 24)),
              const SizedBox(height: 8),
              Text('Enter a new password below.', style: kBodyTextStyle),
              const SizedBox(height: 40),
              AuthTextField(
                label: 'New Password',
                controller: _newPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                label: 'Confirm New Password',
                controller: _confirmPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Password', style: TextStyle(fontSize: 18, color: kTextColor)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}