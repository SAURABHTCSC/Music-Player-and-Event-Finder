class FavouritesManager {
  FavouritesManager._privateConstructor();

  static final FavouritesManager instance =
  FavouritesManager._privateConstructor();

  final List<Map<String, String>> _favouriteSongs = [];

  List<Map<String, String>> get favouriteSongs => _favouriteSongs;

  void addSong(Map<String, String> song) {
    if (!_favouriteSongs.contains(song)) {
      _favouriteSongs.add(song);
    }
  }

  void removeSong(Map<String, String> song) {
    _favouriteSongs.remove(song);
  }
}
