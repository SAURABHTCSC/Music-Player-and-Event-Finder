import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/player_controller.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import 'artist_songs_screen.dart';
import 'full_music_player_screen.dart'; // Import the full player screen

class FavouriteSongsScreen extends StatelessWidget {
  const FavouriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final favourites = player.favouriteSongs;
    final playlists = player.savedPlaylists;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => player.initializeUserSession(),
        child: const Icon(Icons.refresh),
        mini: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // --- Favourite Songs Section ---
          const Text("Favourite Songs ❤️", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (favourites.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No favourite songs yet."),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favourites.length,
              itemBuilder: (context, index) {
                final song = favourites[index];
                return SongTile(song: song, player: player);
              },
            ),

          const SizedBox(height: 24),

          // --- My Playlists Section ---
          const Text("My Playlists 🎵", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (playlists.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("No playlists saved yet."),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return PlaylistTile(playlist: playlist, player: player);
              },
            ),
        ],
      ),
    );
  }
}

// Widget for a single favourite song
class SongTile extends StatelessWidget {
  const SongTile({
    super.key,
    required this.song,
    required this.player,
  });

  final Song song;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: song.imageUrl.startsWith("http")
              ? Image.network(
            song.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          )
              : Image.asset(
            song.imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(song.title),
        subtitle: Text(song.artist),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            player.removeFromFavourites(song);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Removed from favourites")),
            );
          },
        ),
        onTap: () {
          final List<Map<String, String>> playlistData = player.favouriteSongs
              .map((s) => {
            'id': s.id,
            'title': s.title,
            'artist': s.artist,
            'image': s.imageUrl,
            'file': s.songUrl,
          })
              .toList();

          final startIndex = player.favouriteSongs.indexWhere((s) => s.id == song.id);

          player.setPlaylist(playlistData, startIndex);

          // This line opens the full player screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FullMusicPlayerScreen()),
          );
        },
      ),
    );
  }
}

// Widget for a single saved playlist
class PlaylistTile extends StatelessWidget {
  const PlaylistTile({
    super.key,
    required this.playlist,
    required this.player,
  });

  final UserPlaylist playlist;
  final PlayerController player;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty
              ? Image.asset(playlist.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
              : const Icon(Icons.music_note, size: 40),
        ),
        title: Text(playlist.name),
        subtitle: Text("${playlist.songs.length} song(s)"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            player.removePlaylist(playlist);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Playlist removed")),
            );
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ArtistSongsScreen(
                artistName: playlist.name,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        },
      ),
    );
  }
}