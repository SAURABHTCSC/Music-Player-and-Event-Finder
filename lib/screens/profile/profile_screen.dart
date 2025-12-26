import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

// ✅ Imports (Pointing to EXISTING files)
import '../events/ticket_list_screen.dart';      // <--- USE THIS instead of YourTicketsScreen
import '../events/booking_history_screen.dart';
import '../events/liked_events_screen.dart';
import '../organizer/organizer_auth_screen.dart';
import 'change_password_screen.dart';
import 'feedback_screen.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
final SupabaseClient supabase = Supabase.instance.client;
Map<String, dynamic>? _profileData;
bool _isLoading = true;

@override
void initState() {
super.initState();
_fetchProfile();
}

Future<void> _fetchProfile() async {
try {
final userId = supabase.auth.currentUser?.id;
if (userId == null) return;

final data = await supabase.from('event_masters').select().eq('id', userId).maybeSingle();

if (mounted) {
setState(() {
_profileData = data;
_isLoading = false;
});
}
} catch (e) {
if (mounted) setState(() => _isLoading = false);
}
}

Future<void> _signOut() async {
await supabase.auth.signOut();
if (mounted) {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const OrganizerAuthScreen()),
(route) => false,
);
}
}

Future<void> _shareApp() async {
await Share.share("Check out MusicMitra! Download it here: https://play.google.com/store/apps/details?id=com.musicmitra.app");
}

@override
Widget build(BuildContext context) {
String fullName = _profileData?['full_name'] ?? supabase.auth.currentUser?.userMetadata?['full_name'] ?? "Guest";
String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'M';

return Scaffold(
backgroundColor: const Color(0xFFF5F5F5),
appBar: AppBar(
title: Text('Profile', style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold)),
backgroundColor: Colors.white,
elevation: 0,
iconTheme: const IconThemeData(color: Colors.black),
leading: BackButton(
onPressed: () => Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (_) => const MusicMitraHome()),
(route) => false,
),
),
),
body: _isLoading
? const Center(child: CircularProgressIndicator())
    : ListView(
children: [
// HEADER
Container(
color: Colors.white,
padding: const EdgeInsets.symmetric(vertical: 30),
child: Column(
children: [
CircleAvatar(
radius: 50,
backgroundColor: const Color(0xFF6C63FF),
child: Text(initial, style: GoogleFonts.poppins(fontSize: 40, color: Colors.white)),
),
const SizedBox(height: 16),
Text('Welcome, $fullName', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
],
),
),

// MY EVENTS
_header('My Events'),

// ✅ Pointing to TicketListScreen
_tile(Icons.confirmation_number, 'Your Tickets', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketListScreen()))),

_tile(Icons.history, 'Booking History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()))),
_tile(Icons.favorite, 'Liked Events', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedEventsScreen()))),

// SETTINGS
_header('Settings'),
_tile(Icons.lock, 'Change Password', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))),
_tile(Icons.logout, 'Log out', _signOut, isRed: true),

// INFO
_header('Information'),
_tile(Icons.info_outline, 'About App', () => _showAboutDialog(context)),
_tile(Icons.feedback, 'Send Feedback', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()))),
_tile(Icons.share, 'Share App', _shareApp),
],
),
);
}

Widget _header(String title) {
return Padding(
padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
child: Text(title.toUpperCase(), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600])),
);
}

Widget _tile(IconData icon, String title, VoidCallback onTap, {bool isRed = false}) {
return Container(
color: Colors.white,
margin: const EdgeInsets.only(bottom: 1),
child: ListTile(
leading: Icon(icon, color: isRed ? Colors.red : Colors.black54),
title: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: isRed ? Colors.red : Colors.black)),
trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
onTap: onTap,
),
);
}

void _showAboutDialog(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Text("About MusicMitra"),
content: const Text("Developed by Saurabh, Bipin, Avinash."),
actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
),
);
}
}