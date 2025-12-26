// lib/models/playlist_model.dart
import 'song_model.dart';

class UserPlaylist {
  final int id;
  final String name;
  final String? imageUrl;
  final List<Song> songs;

  UserPlaylist({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.songs,
  });

  // A factory constructor to create a UserPlaylist from a database record
  factory UserPlaylist.fromMap(Map<String, dynamic> map) {
    // The 'songs' field from Supabase is a JSON list of maps
    final List<dynamic> songData = map['songs'] ?? [];

    // We need to convert each map into a Song object
    final List<Song> songObjects = songData.map((songMap) {
      // The song data inside the JSON does not have the same keys as the database table
      return Song(
        id: songMap['id'] as String,
        title: songMap['title'] as String,
        artist: songMap['artist'] as String,
        imageUrl: songMap['image'] as String,
        songUrl: songMap['file'] as String,
      );
    }).toList();

    return UserPlaylist(
      id: map['id'] as int,
      name: map['playlist_name'] as String,
      imageUrl: map['image_url'] as String?,
      songs: songObjects,
    );
  }
}