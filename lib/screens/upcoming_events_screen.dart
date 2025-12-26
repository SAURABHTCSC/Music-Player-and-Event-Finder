import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ Fix Imports: Use main model and new Organizer Dashboard
import '../models/event_model.dart';
import 'package:musicmitra/screens//organizer/organizer_dashboard_screen.dart'; // Redirects here instead of AddEventScreen
import 'events/widgets/event_post_card.dart';

class UpcomingEventsScreen extends StatefulWidget {
  const UpcomingEventsScreen({super.key});

  @override
  State<UpcomingEventsScreen> createState() => _UpcomingEventsScreenState();
}

class _UpcomingEventsScreenState extends State<UpcomingEventsScreen> {

  // Fetch real events from Supabase instead of a hardcoded list
  Stream<List<EventModel>> _getUpcomingEvents() {
    return Supabase.instance.client
        .from('events')
        .select()
        .gte('event_date', DateTime.now().toIso8601String()) // Only future events
        .order('event_date', ascending: true)
        .asStream()
        .map((data) => (data as List).map((e) => EventModel.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Upcoming Events", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // ✅ Updated Action: Go to Organizer Dashboard to Add Events
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()));
            },
            tooltip: "Organizer Dashboard",
          )
        ],
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _getUpcomingEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, color: Colors.grey, size: 50),
                  const SizedBox(height: 10),
                  const Text("No upcoming events found.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final events = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: events.length,
            itemBuilder: (context, index) {
              return EventPostCard(event: events[index]);
            },
          );
        },
      ),
    );
  }
}