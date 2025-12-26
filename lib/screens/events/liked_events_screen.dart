import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_model.dart';
import 'widgets/event_post_card.dart'; // Reuse your existing card

class LikedEventsScreen extends StatefulWidget {
  const LikedEventsScreen({super.key});

  @override
  State<LikedEventsScreen> createState() => _LikedEventsScreenState();
}

class _LikedEventsScreenState extends State<LikedEventsScreen> {
  bool _isLoading = true;
  List<EventModel> _likedEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchLikedEvents();
  }

  Future<void> _fetchLikedEvents() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch events where the 'event_likes' table contains the current user's ID
      // !inner join ensures we only get events that match the filter on the child table
      final response = await Supabase.instance.client
          .from('events')
          .select('*, event_likes!inner(user_id)')
          .eq('event_likes.user_id', user.id);

      final data = response as List<dynamic>;

      if (mounted) {
        setState(() {
          _likedEvents = data.map((e) => EventModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching likes: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Liked Events", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _likedEvents.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, color: Colors.grey, size: 60),
            const SizedBox(height: 10),
            Text("No liked events yet", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _likedEvents.length,
        itemBuilder: (context, index) {
          // Reuse the existing card logic for consistency
          return EventPostCard(event: _likedEvents[index]);
        },
      ),
    );
  }
}