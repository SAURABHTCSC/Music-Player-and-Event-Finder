import 'package:flutter/material.dart';
import 'package:musicmitra/controllers/player_controller.dart'; // Import controller
import 'package:provider/provider.dart'; // Import provider
import '../widgets/music_player_bar.dart';
import 'category_songs_screen.dart';

class HomeMusic extends StatelessWidget {
  const HomeMusic({super.key});

  @override
  Widget build(BuildContext context) {
    final categoryList = ['Top Trends', 'Relax', 'Drive', 'Workout', 'Chill'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Mitra'),
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Buttons
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final title = categoryList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategorySongsScreen(
                              categoryName: title,
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(title),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Songs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Song List
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Example count
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      leading: const Icon(Icons.music_note, color: Colors.white),
                      title: Text(
                        'Song Title ${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          // TODO: Hook into PlayerController here
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ✅ FIX: Conditionally show the MusicPlayerBar
      bottomNavigationBar: Consumer<PlayerController>(
        builder: (context, player, child) {
          // Only show the bar if a song is playing
          if (player.currentSong == null) {
            return const SizedBox.shrink(); // Show nothing
          }
          // The MusicPlayerBar doesn't need any parameters now
          return const MusicPlayerBar();
        },
      ),
    );
  }
}