import 'package:flutter/material.dart';
import 'package:musicmitra/utils/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitFeedback() async {
    final content = _feedbackController.text.trim();
    if (content.isEmpty) {
      showSnackBar(context, 'Feedback cannot be empty.', isError: true);
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      // ✅ Get the current user's ID
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User is not logged in.');
      }

      // ✅ Insert feedback into Supabase table
      await Supabase.instance.client.from('feedback').insert({
        'content': content,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(), // extra feature: timestamp
      });

      if (mounted) {
        showSnackBar(context, 'Thank you for your feedback!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(
          context,
          'Failed to submit feedback. Please try again.',
          isError: true,
        );
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Submit Feedback',
            style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: kTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We value your feedback 💬",
              style: TextStyle(
                color: kTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 8,
              maxLength: 100, // ✅ old feature kept
              style: const TextStyle(color: kTextColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: kTextFieldColor,
                hintText:
                'Tell me to add your choice song, share the link, or suggest changes...',
                hintStyle: const TextStyle(color: kSecondaryTextColor),
                counterStyle: const TextStyle(color: kSecondaryTextColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.send, color: Colors.white),
                label: Text(
                  _isSubmitting ? "Submitting..." : "Submit",
                  style: const TextStyle(fontSize: 18, color: kTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
