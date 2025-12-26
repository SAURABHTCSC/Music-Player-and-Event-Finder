import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/player_controller.dart';
import '../screens/full_music_player_screen.dart';
import '../screens/category_songs_screen.dart';
import '../screens/artist_songs_screen.dart';

// 🔹 Import central data files
import '../data/home_songs_data.dart';
import '../data/category_songs_data.dart';
import '../data/artist_songs_data.dart';
import '../data/artists.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, String>> _allSongs = [];
  List<Map<String, String>> _filteredSongs = [];
  String _query = '';
  String _categoryResult = '';
  String _artistResult = '';

  @override
  void initState() {
    super.initState();
    _buildAllSongs();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _buildAllSongs() {
    final seenFiles = <String>{};

    void addSong(Map<String, String> s, {String category = ''}) {
      final file = s['file'] ?? '';
      if (file.isEmpty) return;
      if (seenFiles.add(file)) {
        _allSongs.add({
          'title': s['title'] ?? '',
          'artist': s['artist'] ?? '',
          'image': s['image'] ?? '',
          'file': file,
          'category': category,
        });
      }
    }

    for (final s in homeSongsData) {
      addSong(Map<String, String>.from(s));
    }

    categorySongsData.forEach((category, list) {
      for (final s in list) {
        addSong(Map<String, String>.from(s), category: category);
      }
    });

    for (final list in artistSongsData.values) {
      for (final s in list) {
        addSong(Map<String, String>.from(s));
      }
    }
  }

  void _onQueryChanged(String q) {
    setState(() {
      _query = q;
      final needle = q.trim().toLowerCase();
      _categoryResult = '';
      _artistResult = '';
      _filteredSongs = [];

      if (needle.isEmpty) return;

      // check category match
      final matchingCategory = categorySongsData.keys.firstWhere(
            (c) => c.toLowerCase().contains(needle),
        orElse: () => '',
      );

      // check artist match
      final matchingArtist = artistSongsData.keys.firstWhere(
            (a) => a.toLowerCase().contains(needle),
        orElse: () => '',
      );

      if (matchingCategory.isNotEmpty) {
        _categoryResult = matchingCategory;
      } else if (matchingArtist.isNotEmpty) {
        _artistResult = matchingArtist;
      } else {
        _filteredSongs = _allSongs.where((s) {
          final title = (s['title'] ?? '').toLowerCase();
          final artist = (s['artist'] ?? '').toLowerCase();
          return title.contains(needle) || artist.contains(needle);
        }).toList();
      }
    });
  }

  void _playFromResults(BuildContext context, int index) {
    final player = context.read<PlayerController>();
    player.setPlaylist(_filteredSongs, index);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FullMusicPlayerScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: true,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search here',
            ),
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                _onQueryChanged('');
              },
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: SafeArea(
        child: _query.isEmpty
            ? _EmptySearchHint(isDark: isDark)
            : (_categoryResult.isNotEmpty
            ? ListTile(
          leading: const Icon(
            Icons.my_library_music_sharp,
            size: 40,
            color: Colors.blue,
          ),
          title: Text("$_categoryResult related songs"),
          subtitle: const Text("Tap to view songs"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategorySongsScreen(
                  categoryName: _categoryResult,
                  onBack: () => Navigator.pop(context),
                ),
              ),
            );
          },
        )
            : (_artistResult.isNotEmpty
            ? _buildArtistResultTile()
            : (_filteredSongs.isEmpty
            ? _NoResults(isDark: isDark)
            : ListView.separated(
          padding: EdgeInsets.only(
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom +
                16,
          ),
          shrinkWrap: true,
          itemCount: _filteredSongs.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark
                ? Colors.white10
                : Colors.black12,
          ),
          itemBuilder: (context, index) {
            final song = _filteredSongs[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  song['image'] ?? '',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(
                      Icons.my_library_music_rounded,
                      size: 36),
                ),
              ),
              title: Text(song['title'] ?? ''),
              subtitle: Text(song['artist'] ?? ''),
              onTap: () =>
                  _playFromResults(context, index),
            );
          },
        )))),
      ),
    );
  }

  /// 🔹 Build Artist search result with correct logo from artists.dart
  Widget _buildArtistResultTile() {
    final artist = artists.firstWhere(
          (a) => a["name"] == _artistResult,
      orElse: () => {"image": "", "name": _artistResult},
    );

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: artist["image"]!.isNotEmpty
            ? Image.asset(
          artist["image"]!,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.person, size: 40, color: Colors.green),
        )
            : const Icon(Icons.person, size: 40, color: Colors.green),
      ),
      title: Text("${artist["name"]} songs"),
      subtitle: const Text("Tap to view songs"),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArtistSongsScreen(
              artistName: artist["name"]!,
              onBack: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }
}

class _EmptySearchHint extends StatelessWidget {
  const _EmptySearchHint({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search,
                size: 56, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 16),
            Text(
              'Play what you love',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Search for artists, songs, or categories.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No results found',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }
}