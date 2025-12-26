import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ✅ Import the new screens
import '../booking_history_screen.dart';
import '../liked_events_screen.dart';

class EventDrawer extends StatefulWidget {
  const EventDrawer({super.key});

  @override
  State<EventDrawer> createState() => _EventDrawerState();
}

class _EventDrawerState extends State<EventDrawer> {
  String _userName = "Music Lover";
  String _email = "user@example.com";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Try to get name from metadata or your custom table
      String? name = user.userMetadata?['full_name'];

      // Optional: Fetch from a 'users' table if you have one
      if (name == null) {
        // Fallback logic if needed
      }

      if (mounted) {
        setState(() {
          _email = user.email ?? "";
          _userName = name ?? "Music Lover";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. PROFILE HEADER
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834DF)]),
            ),
            accountName: Text(_userName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            accountEmail: Text(_email, style: GoogleFonts.poppins(fontSize: 12)),
            currentAccountPicture: const CircleAvatar(
              backgroundImage: AssetImage('assets/profile.png'),
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),

          // 2. EVENTS SECTION
          _sectionTitle("My Events"),

          _drawerItem(Icons.confirmation_number, "Your Tickets", () {
            // Same as Booking History or separate ticket UI
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()));
          }),

          // ✅ ACTIVATED: Booking History
          _drawerItem(Icons.history, "Booking History", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingHistoryScreen()));
          }),

          // ✅ ACTIVATED: Liked Events
          _drawerItem(Icons.favorite, "Liked Events", () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedEventsScreen()));
          }),

          const Divider(color: Colors.white24),

          // 3. SETTINGS SECTION
          _sectionTitle("App Settings"),
          _drawerItem(Icons.settings, "Preferences", () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preferences Coming Soon")));
          }),
          _drawerItem(Icons.help_outline, "Help & Support", () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Support Coming Soon")));
          }),

          const Divider(color: Colors.white24),

          // 4. LOGOUT
          _drawerItem(Icons.logout, "Logout", () async {
            await Supabase.instance.client.auth.signOut();
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            }
          }, color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: GoogleFonts.poppins(color: color)),
      onTap: () {
        Navigator.pop(context); // Close drawer first
        onTap();
      },
    );
  }
}