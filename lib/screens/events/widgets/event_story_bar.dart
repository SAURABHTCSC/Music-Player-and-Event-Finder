import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/event_model.dart';
import 'story_view_screen.dart'; // ✅ Import the new screen

class EventStoryBar extends StatelessWidget {
  const EventStoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FutureBuilder(
        future: Supabase.instance.client
            .from('events')
            .select()
            .eq('status', 'approved') // Only approved stories
            .gte('event_date', DateTime.now().toIso8601String())
            .limit(10),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final List<dynamic> rawData = snapshot.data as List<dynamic>;
          final events = rawData.map((e) => EventModel.fromJson(e)).toList();

          if (events.isEmpty) {
            return const Center(child: Text("No upcoming events", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            padding: const EdgeInsets.only(left: 10),
            itemBuilder: (context, index) {
              final event = events[index];
              String imgUrl = event.imageUrls.isNotEmpty
                  ? event.imageUrls[0]
                  : 'https://via.placeholder.com/150';

              return GestureDetector(
                onTap: () {
                  // ✅ Navigate to the Instagram-style Story Player
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => StoryViewScreen(event: event)),
                  );
                },
                child: _buildStoryItem(context, event.eventName, imgUrl),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStoryItem(BuildContext context, String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black),
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(imagePath),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 75,
            height: 20,
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}