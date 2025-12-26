// lib/models/song_model.dart
class Song {
  final String id;
  final String title;
  final String artist;
  final String imageUrl;
  final String songUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.songUrl,
  });

  // Creates a Song object from a database record
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['song_id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      imageUrl: map['image_url'] as String,
      songUrl: map['song_url'] as String,
    );
  }
}