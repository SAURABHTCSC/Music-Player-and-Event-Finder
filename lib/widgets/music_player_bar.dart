import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/player_controller.dart';
import '../screens/full_music_player_screen.dart';

class MusicPlayerBar extends StatelessWidget {
  // ✅ FIX: Removed the unused constructor parameters.
  const MusicPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerController>(
      builder: (context, player, _) {
        // ✅ FIX: Get the current song object.
        final song = player.currentSong;

        // If no song is playing, don't build the widget.
        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FullMusicPlayerScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: const BoxDecoration(
              color: Colors.black87,
              // This borderRadius might be better on the parent Container in main.dart
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      // ✅ FIX: Use song.imageUrl
                      child: _buildSongImage(song.imageUrl),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // ✅ FIX: Use song.title
                      child: Text(
                        song.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        player.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        size: 28,
                        color: Colors.white,
                      ),
                      onPressed: player.togglePlay,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(player.progress),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: player.progress,
                    max: player.duration > 0 ? player.duration : 1,
                    onChanged: (value) => player.seek(value),
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.white),
      );
    } else {
      return Image.asset(path, width: 36, height: 36, fit: BoxFit.cover);
    }
  }

  String _formatTime(double milliseconds) {
    final duration = Duration(milliseconds: milliseconds.toInt());
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}