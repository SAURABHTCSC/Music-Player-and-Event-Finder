import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// ✅ Import Profile Screen (New App Level Profile)
import '../profile/profile_screen.dart';

// Organizer Screens
import '../organizer/organizer_auth_screen.dart';
import '../organizer/organizer_dashboard_screen.dart';

// Widgets & Models
import 'widgets/event_post_card.dart';
import 'widgets/event_story_bar.dart';
import '../../models/event_model.dart';

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({super.key});

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  // Filter States
  String _selectedCategory = "All";
  String _currentCity = "";
  double _maxPrice = 5000;

  // UI States
  bool _isLoadingLocation = false;
  String _userName = "Music Lover";

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchUserName();
  }

  // --- 1. FETCH USER NAME ---
  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Try metadata first
      String? name = user.userMetadata?['full_name'];

      // If null, check organizer table (fallback)
      if (name == null) {
        final data = await Supabase.instance.client
            .from('event_masters')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        if (data != null) name = data['full_name'];
      }

      if (name != null && mounted) {
        setState(() => _userName = name!);
      }
    }
  }

  // --- 2. ORGANIZER NAVIGATION LOGIC ---
  void _handlePlusButton() async {
    final user = Supabase.instance.client.auth.currentUser;
    // Check if user is logged in AND is an organizer
    if (user != null) {
      final data = await Supabase.instance.client
          .from('event_masters')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        // Go to Dashboard if already an organizer
        Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerDashboardScreen()));
        return;
      }
    }
    // Otherwise go to Auth/Registration
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerAuthScreen()));
    }
  }

  // --- 3. GET CITY LOCATION ---
  Future<void> _getUserLocation() async {
    setState(() => _isLoadingLocation = true);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty && mounted) {
        // Get City Name (e.g., Mumbai, Pune)
        String city = placemarks.first.locality ?? placemarks.first.subAdministrativeArea ?? "";
        setState(() => _currentCity = city);
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  // --- 4. FETCH & FILTER EVENTS ---
  Stream<List<EventModel>> _getEvents() {
    // Fetch ONLY Approved events
    var query = Supabase.instance.client
        .from('events')
        .select()
        .eq('status', 'approved')
        .order('created_at', ascending: false);

    return query.asStream().map((data) {
      final events = (data as List).map((e) => EventModel.fromJson(e)).toList();

      // Apply Client-Side Filters
      return events.where((e) {
        // A. Category Filter
        if (_selectedCategory != "All" && e.eventType != _selectedCategory) return false;

        // B. Price Filter
        if (e.ticketPrice > _maxPrice) return false;

        // C. City Filter
        // Check if the event address contains the current city string
        if (_currentCity.isNotEmpty) {
          if (!e.locationAddress.toLowerCase().contains(_currentCity.toLowerCase())) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  // --- 5. FILTER DIALOG ---
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C), // Dark Grey
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filter Events", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Category Dropdown
                const Text("Event Type", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: const Color(0xFF2C2C3E),
                    isExpanded: true,
                    underline: const SizedBox(),
                    style: const TextStyle(color: Colors.white),
                    items: ["All", "DJ Night", "Concert", "College Fest", "Comedy", "Workshop", "Sports", "Gaming", "Food Fest"]
                        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                        .toList(),
                    onChanged: (val) => setModalState(() => _selectedCategory = val!),
                  ),
                ),

                const SizedBox(height: 20),

                // Price Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Max Ticket Price", style: TextStyle(color: Colors.grey)),
                    Text("₹${_maxPrice.toInt()}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
                Slider(
                  value: _maxPrice, min: 0, max: 10000, divisions: 20,
                  activeColor: const Color(0xFF6C63FF), inactiveColor: Colors.grey,
                  onChanged: (val) => setModalState(() => _maxPrice = val),
                ),

                const SizedBox(height: 20),

                // Apply Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                    onPressed: () { setState(() {}); Navigator.pop(context); },
                    child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // App Theme
      // ❌ DRAWER REMOVED
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Column(
                children: [
                  // --- TOP BAR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ 1. PROFILE BUTTON (Replaces Menu)
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.white, size: 28),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                      ),

                      // ✅ 2. GREETING
                      Column(
                        children: [
                          Text("Hello, $_userName", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                          Text("Event Finder", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),

                      // ✅ 3. ORGANIZER BUTTON
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                        onPressed: _handlePlusButton,
                      ),
                    ],
                  ),

                  // --- FILTER & LOCATION BAR ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Filter Icon
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.white, size: 26),
                        onPressed: _showFilterDialog,
                      ),

                      // ✅ Location Display (City Name)
                      GestureDetector(
                        onTap: _getUserLocation,
                        child: Row(
                          children: [
                            if (_isLoadingLocation)
                              const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            else
                              Text(
                                  _currentCity.isEmpty ? "All Locations" : _currentCity,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)
                              ),
                            const SizedBox(width: 5),
                            const Icon(Icons.location_on_outlined, color: Colors.white, size: 26),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- STORIES ---
            const SizedBox(height: 125, child: EventStoryBar()),
            const Divider(color: Colors.white12, thickness: 1, height: 1),

            // --- EVENT FEED ---
            Expanded(
              child: StreamBuilder<List<EventModel>>(
                stream: _getEvents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_busy, color: Colors.grey, size: 60),
                          const SizedBox(height: 10),
                          Text(
                              _currentCity.isEmpty ? "No Events Found" : "No events in $_currentCity",
                              style: GoogleFonts.poppins(color: Colors.grey)
                          ),
                          if (_currentCity.isNotEmpty)
                            TextButton(
                                onPressed: () => setState(() => _currentCity = ""),
                                child: const Text("Show All Locations", style: TextStyle(color: Color(0xFF6C63FF)))
                            )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => EventPostCard(event: snapshot.data![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}