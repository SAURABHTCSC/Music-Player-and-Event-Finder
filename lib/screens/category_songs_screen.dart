import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/player_controller.dart';
import '../data/category_songs_data.dart';
import 'full_music_player_screen.dart'; // Import the full player screen

class CategorySongsScreen extends StatefulWidget {
  final String categoryName;
  final VoidCallback onBack;

  const CategorySongsScreen({
    super.key,
    required this.categoryName,
    required this.onBack,
  });

  @override
  State<CategorySongsScreen> createState() => _CategorySongsScreenState();
}

class _CategorySongsScreenState extends State<CategorySongsScreen> {
  @override
  Widget build(BuildContext context) {
    final player = context.read<PlayerController>();
    final List<Map<String, String>>? categoryData =
    categorySongsData[widget.categoryName];

    if (categoryData == null || categoryData.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        ),
        body: const Center(
          child: Text('No songs available in this category.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView.builder(
        itemCount: categoryData.length,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemBuilder: (context, index) {
          final song = categoryData[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: song['image'] != null &&
                  song['image']!.startsWith('http')
                  ? Image.network(
                song['image']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.music_note,
                    size: 40, color: Colors.grey),
              )
                  : Image.asset(
                song['image'] ?? 'assets/default.jpg',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(song['title'] ?? ''),
            subtitle: Text(song['artist'] ?? ''),
            onTap: () {
              // This starts playing the song
              player.setPlaylist(categoryData, index);
              // This opens the full player screen
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