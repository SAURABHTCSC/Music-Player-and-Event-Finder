import 'package:flutter/material.dart';
import 'package:musicmitra/screens/auth/login_screen.dart';
import 'package:musicmitra/screens/auth/signup_screen.dart';
import 'package:musicmitra/utils/constants.dart';

class RoleSelectionScreen extends StatelessWidget {
  final bool isLogin;
  const RoleSelectionScreen({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: kTextColor),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLogin ? 'Login As' : 'Sign Up As',
                style: kHeadlineTextStyle,
              ),
              const SizedBox(height: 40),
              // User Button
              _buildRoleButton(
                context,
                icon: Icons.person,
                label: 'User',
                onPressed: () {
                  if (isLogin) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
                  }
                },
              ),
              const SizedBox(height: 20),
              // Event Organizer Button
              _buildRoleButton(
                context,
                icon: Icons.event,
                label: 'Event Organizer',
                onPressed: () {
                  showSnackBar(context, 'Coming Soon...');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: kTextColor),
        label: Text(label, style: const TextStyle(color: kTextColor, fontSize: 18)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}