import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/player_controller.dart';
import '../data/artist_songs_data.dart';
import 'full_music_player_screen.dart'; // Import the full player screen

class ArtistSongsScreen extends StatefulWidget {
  final String artistName;
  final VoidCallback onBack;

  const ArtistSongsScreen({
    super.key,
    required this.artistName,
    required this.onBack,
  });

  @override
  State<ArtistSongsScreen> createState() => _ArtistSongsScreenState();
}

class _ArtistSongsScreenState extends State<ArtistSongsScreen> {
  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerController>();
    final List<Map<String, String>>? artistData = artistSongsData[widget.artistName];

    if (artistData == null || artistData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.artistName),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        ),
        body: const Center(
          child: Text('No songs available for this artist.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artistName),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: widget.onBack),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Colors.white),
            tooltip: 'Save Playlist',
            onPressed: () {
              player.saveArtistPlaylist(widget.artistName, artistData);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${widget.artistName} playlist saved to Library")),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: artistData.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          final song = artistData[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                song['image']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(song['title'] ?? ''),
            subtitle: Text(song['artist'] ?? ''),
            onTap: () {
              // This starts playing the song
              player.setPlaylist(artistData, index);

              // ✅ This line opens the full player screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FullMusicPlayerScreen()),
              );
            },
          );
        },
      ),
    );
  }
}