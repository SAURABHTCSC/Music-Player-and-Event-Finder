import 'package:flutter/material.dart'; // ✅ THIS LINE FIXES ALL ERRORS
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../controllers/player_controller.dart';

class FullMusicPlayerScreen extends StatelessWidget {
  const FullMusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, _) {
        final song = player.currentSong;
        final imageUrl = song?.imageUrl ?? '';
        final title = song?.title ?? 'No Song Playing';
        final artist = song?.artist ?? ' ';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                height: 300,
                width: 300,
                child: getSongImage(imageUrl, size: 300, radius: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                artist,
                style: const TextStyle(color: Colors.white70, fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Slider(
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                value: player.progress,
                max: player.duration > 0 ? player.duration : 1,
                onChanged: (value) => player.seek(value),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatTime(player.progress), style: const TextStyle(color: Colors.white70)),
                    Text(_formatTime(player.duration), style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.repeat, color: player.isLooping ? Colors.greenAccent : Colors.white),
                    onPressed: player.toggleLooping,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    onPressed: player.playPrevious,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: Icon(player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: Colors.white, size: 50),
                    onPressed: player.togglePlay,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    onPressed: player.playNext,
                    iconSize: 32,
                  ),
                  IconButton(
                    icon: Icon(
                      player.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: player.isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      final currentUser = Supabase.instance.client.auth.currentUser;
                      if (currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please log in to save favourite songs!'),
                            backgroundColor: Colors.amber,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        player.toggleLike();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget getSongImage(String path, {double size = 60, double radius = 12}) {
    if (path.isEmpty) {
      return Icon(Icons.music_note, size: size, color: Colors.white54);
    }
    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          path,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: size * 0.8, color: Colors.white),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(path, width: size, height: size, fit: BoxFit.cover),
      );
    }
  }
}