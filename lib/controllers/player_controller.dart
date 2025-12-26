import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart'; // ✅ ADDED: For background audio
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';

class PlayerController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final _supabase = Supabase.instance.client;

  // State
  Song? _currentSong;
  List<Song> _currentPlaylist = [];
  int _currentPlaylistIndex = 0;
  bool _isPlaying = false;
  double _progress = 0;
  double _duration = 1;
  bool _isLooping = false; // Single song loop
  bool _isPlaylistLooping = true;
  List<Song> _favouriteSongs = [];
  List<UserPlaylist> _savedPlaylists = [];

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  double get progress => _progress;
  double get duration => _duration;
  bool get isLooping => _isLooping;
  bool get isPlaylistLooping => _isPlaylistLooping;
  List<Song> get favouriteSongs => _favouriteSongs;
  List<UserPlaylist> get savedPlaylists => _savedPlaylists;
  bool get isLiked => _currentSong != null && _favouriteSongs.any((s) => s.id == _currentSong!.id);

  PlayerController() {
    _player.positionStream.listen((p) {
      _progress = p.inMilliseconds.toDouble();
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d?.inMilliseconds.toDouble() ?? 1;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.completed) {
        if (_isLooping) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          playNext();
        }
      }
      notifyListeners();
    });
  }

  Future<void> setPlaylist(List<Map<String, String>> playlistData, int startIndex) async {
    _currentPlaylist = playlistData.map((songMap) => Song(
      id: songMap['id']!, title: songMap['title']!, artist: songMap['artist']!, imageUrl: songMap['image']!, songUrl: songMap['file']!,
    )).toList();

    _currentPlaylistIndex = startIndex;
    if (_currentPlaylist.isNotEmpty) {
      await _playSong(_currentPlaylist[_currentPlaylistIndex]);
    }
  }

  // ✅ UPDATED: This method now supports background audio notifications
  Future<void> _playSong(Song song) async {
    _currentSong = song;
    await _player.stop();

    // Create the MediaItem that will be displayed in the notification
    final mediaItem = MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      artUri: Uri.parse(
        // The package needs a special format for local asset images
          song.imageUrl.startsWith('http') ? song.imageUrl : 'asset:///${song.imageUrl}'
      ),
    );

    // Create the audio source, tagging it with our MediaItem
    final audioSource = AudioSource.uri(
      Uri.parse(
        // Also use a special format for local asset audio files
          song.songUrl.startsWith('http') ? song.songUrl : 'asset:///${song.songUrl}'
      ),
      tag: mediaItem,
    );

    try {
      // Use setAudioSource, which is required for the background service
      await _player.setAudioSource(audioSource);
      await _player.play();
    } catch (e) {
      print("Error playing song: $e");
    }
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentPlaylist.isEmpty) return;

    if (_currentPlaylistIndex < _currentPlaylist.length - 1) {
      _currentPlaylistIndex++;
    } else {
      if (_isPlaylistLooping) {
        _currentPlaylistIndex = 0;
      } else {
        return;
      }
    }
    await _playSong(_currentPlaylist[_currentPlaylistIndex]);
  }

  Future<void> playPrevious() async {
    if (_currentPlaylist.isEmpty) return;

    if (_currentPlaylistIndex > 0) {
      _currentPlaylistIndex--;
    } else {
      if (_isPlaylistLooping) {
        _currentPlaylistIndex = _currentPlaylist.length - 1;
      } else {
        return;
      }
    }
    await _playSong(_currentPlaylist[_currentPlaylistIndex]);
  }

  void togglePlay() => _player.playing ? _player.pause() : _player.play();
  void seek(double position) => _player.seek(Duration(milliseconds: position.toInt()));
  void toggleLooping() {
    _isLooping = !_isLooping;
    notifyListeners();
  }
  void togglePlaylistLooping() {
    _isPlaylistLooping = !_isPlaylistLooping;
    notifyListeners();
  }

  Future<void> initializeUserSession() async {
    if (_supabase.auth.currentUser == null) return;
    await Future.wait([ fetchFavourites(), fetchSavedPlaylists() ]);
  }

  void clearUserSession() {
    _favouriteSongs = [];
    _savedPlaylists = [];
    notifyListeners();
  }

  // === SUPABASE FAVORITES LOGIC ===
  Future<void> fetchFavourites() async {
    if (_supabase.auth.currentUser == null) return;
    try {
      final response = await _supabase.from('liked_songs').select().eq('user_id', _supabase.auth.currentUser!.id).order('created_at', ascending: false);
      _favouriteSongs = response.map((item) => Song.fromMap(item)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching favourites: $e");
    }
  }

  void toggleLike() {
    if (_currentSong == null || _supabase.auth.currentUser == null) return;

    if (isLiked) {
      _removeFromFavourites(_currentSong!);
    } else {
      _addToFavourites(_currentSong!);
    }
  }

  Future<void> _addToFavourites(Song song) async {
    _favouriteSongs.insert(0, song);
    notifyListeners();
    try {
      await _supabase.from('liked_songs').insert({
        'user_id': _supabase.auth.currentUser!.id, 'song_id': song.id, 'title': song.title, 'artist': song.artist, 'image_url': song.imageUrl, 'song_url': song.songUrl,
      });
    } catch (e) {
      _favouriteSongs.removeWhere((s) => s.id == song.id);
      notifyListeners();
    }
  }

  Future<void> removeFromFavourites(Song song) async {
    _removeFromFavourites(song);
  }

  Future<void> _removeFromFavourites(Song song) async {
    _favouriteSongs.removeWhere((s) => s.id == song.id);
    notifyListeners();
    try {
      await _supabase.from('liked_songs').delete().match({'user_id': _supabase.auth.currentUser!.id, 'song_id': song.id});
    } catch (e) {
      _favouriteSongs.add(song);
      notifyListeners();
    }
  }

  // === SUPABASE PLAYLIST LOGIC ===
  Future<void> fetchSavedPlaylists() async {
    if (_supabase.auth.currentUser == null) return;
    try {
      final response = await _supabase.from('user_playlists').select().eq('user_id', _supabase.auth.currentUser!.id).order('created_at', ascending: false);
      _savedPlaylists = response.map((item) => UserPlaylist.fromMap(item)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching playlists: $e");
    }
  }

  Future<void> saveArtistPlaylist(String artistName, List<Map<String, String>> songs) async {
    if (_supabase.auth.currentUser == null) return;
    final imageUrl = songs.isNotEmpty ? songs.first['image'] : null;
    try {
      final response = await _supabase.from('user_playlists').insert({
        'user_id': _supabase.auth.currentUser!.id, 'playlist_name': artistName, 'image_url': imageUrl, 'songs': songs,
      }).select();
      if (response.isNotEmpty) {
        _savedPlaylists.insert(0, UserPlaylist.fromMap(response.first));
        notifyListeners();
      }
    } catch (e) {
      print("Error saving playlist: $e");
    }
  }

  Future<void> removePlaylist(UserPlaylist playlist) async {
    _savedPlaylists.removeWhere((p) => p.id == playlist.id);
    notifyListeners();
    try {
      await _supabase.from('user_playlists').delete().match({'id': playlist.id});
    } catch (e) {
      _savedPlaylists.add(playlist);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}