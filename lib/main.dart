import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musicmitra/theme/theme_manager.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Controllers & Widgets
import 'controllers/player_controller.dart';
import 'widgets/music_player_bar.dart';
import 'widgets/artist_tile.dart';
import 'screens/events/event_feed_screen.dart';

// Screens
import 'screens/full_music_player_screen.dart';
import 'screens/category_songs_screen.dart';
import 'screens/artist_songs_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favourite_songs_screen.dart';

// Auth & Profile
import 'screens/auth/auth_gate.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/profile/profile_screen.dart';

// Data
import 'data/artists.dart';
import 'data/home_songs_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ardbmwtpkdvydpcbxetr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFyZGJtd3Rwa2R2eWRwY2J4ZXRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1MjY1MjAsImV4cCI6MjA3MTEwMjUyMH0.AybRup_yO-9edMyFwqFiDJ98jqBS_vUG021TQ5Uku1k',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerController()),
        ChangeNotifierProvider(create: (_) => ThemeManager()),
      ],
      child: const MusicMitraApp(),
    ),
  );
}

class MusicMitraApp extends StatelessWidget {
  const MusicMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return MaterialApp(
      title: 'MusicMitra',
      theme: themeManager.isDarkMode ? darkTheme : lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/home': (context) => const MusicMitraHome(),
      },
    );
  }
}

class MusicMitraHome extends StatefulWidget {
  const MusicMitraHome({super.key});

  @override
  State<MusicMitraHome> createState() => _MusicMitraHomeState();
}

class _MusicMitraHomeState extends State<MusicMitraHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerController>();
    final themeManager = context.watch<ThemeManager>();
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 30),
            const SizedBox(width: 8),
            Text('MusicMitra', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            IconButton(
              icon: Icon(themeManager.isDarkMode ? Icons.wb_sunny : Icons.dark_mode),
              onPressed: () => context.read<ThemeManager>().toggleTheme(),
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
            ),
            GestureDetector(
              onTap: () {
                final destination = currentUser != null ? const ProfileScreen() : const AuthScreen();
                Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
              },
              child: const CircleAvatar(backgroundImage: AssetImage('assets/profile.png'), radius: 16),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomeContent(context, artists, player),
          const EventFeedScreen(),
          const FavouriteSongsScreen(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (player.currentSong != null)
            const MusicPlayerBar(),
          const Divider(height: 1),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.theaters), label: "Shows"),
              BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildHomeContent(BuildContext context, List<Map<String, String>> artists, PlayerController player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                categoryButton(context, "Top Trends"),
                categoryButton(context, "Relax"),
                categoryButton(context, "Drive"),
                categoryButton(context, "Workout"),
                categoryButton(context, "Haldi"),
                categoryButton(context, "Birthday"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text("For You", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: homeSongsData.length,
            itemBuilder: (context, index) {
              final song = homeSongsData[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 6),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(song['image']!, width: 50, height: 50, fit: BoxFit.cover),
                ),
                title: Text(song['title']!),
                subtitle: Text(song['artist']!),
                onTap: () {
                  player.setPlaylist(homeSongsData, index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FullMusicPlayerScreen()),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 40),
          Text("Artists", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),

          Builder(
            builder: (context) {
              // ✅ CHANGED THIS VALUE FROM 5 TO 4
              const int artistsPerRow = 4;

              final List<List<Map<String, String>>> artistRows = [];
              for (var i = 0; i < artists.length; i += artistsPerRow) {
                final end = (i + artistsPerRow > artists.length) ? artists.length : (i + artistsPerRow);
                artistRows.add(artists.sublist(i, end));
              }

              return Column(
                children: artistRows.map((rowArtists) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: rowArtists.map((artist) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: ArtistTile(
                              name: artist['name']!,
                              imagePath: artist['image']!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ArtistSongsScreen(
                                      artistName: artist['name']!,
                                      onBack: () => Navigator.pop(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget categoryButton(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategorySongsScreen(
                categoryName: title,
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade200,
          foregroundColor: Colors.black,
        ),
        child: Text(title),
      ),
    );
  }
}

// Theme Data...
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFFDF6F9),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
);