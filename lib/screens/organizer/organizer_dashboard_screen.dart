import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// ✅ Imports for your screens and widgets
import 'organizer_auth_screen.dart'; // Required for logout redirection
import 'organizer_add_event_screen.dart';
import 'widgets/organizer_stats_card.dart';
import 'widgets/organizer_event_list.dart';

class OrganizerDashboardScreen extends StatefulWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  State<OrganizerDashboardScreen> createState() => _OrganizerDashboardScreenState();
}

class _OrganizerDashboardScreenState extends State<OrganizerDashboardScreen> {
  final String _userId = Supabase.instance.client.auth.currentUser!.id;
  String organizerName = "Event Master";

  // Stats
  int adminResponseCount = 0;
  int totalBookedGlobal = 0;
  double totalRevenueGlobal = 0.0;

  // Data
  List<Map<String, dynamic>> eventListWithStats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch Profile Name
      final profile = await client.from('event_masters').select('full_name').eq('id', _userId).maybeSingle();
      if (profile != null) organizerName = profile['full_name'] ?? "Event Master";

      // 2. Fetch Events for this Organizer
      final eventsData = await client.from('events').select().eq('creator_id', _userId);
      final List<dynamic> rawEvents = eventsData;

      // 3. Fetch Tickets (Source of Truth for Revenue & Seats)
      List<int> eventIds = rawEvents.map<int>((e) => e['id'] as int).toList();
      Map<int, int> bookedMap = {};
      Map<int, double> revenueMap = {};

      if (eventIds.isNotEmpty) {
        // Get all tickets associated with these events
        final tickets = await client.from('tickets').select('event_id, final_price').inFilter('event_id', eventIds);

        for (var t in tickets) {
          int eid = t['event_id'];
          double price = (t['final_price'] as num).toDouble();

          bookedMap[eid] = (bookedMap[eid] ?? 0) + (t['quantity'] as int? ?? 1);
          revenueMap[eid] = (revenueMap[eid] ?? 0.0) + price;
        }
      }

      // 4. Merge Stats into Event List
      List<Map<String, dynamic>> processedEvents = [];
      int globalBooked = 0;
      double globalRevenue = 0.0;

      for (var e in rawEvents) {
        int eid = e['id'];
        int booked = bookedMap[eid] ?? 0;
        double rev = revenueMap[eid] ?? 0.0;

        globalBooked += booked;
        globalRevenue += rev;

        Map<String, dynamic> newEvent = Map.from(e);
        newEvent['booked_count'] = booked;
        newEvent['event_revenue'] = rev;
        processedEvents.add(newEvent);
      }

      // 5. Fetch Admin Responses (Queries that are NOT pending)
      final queries = await client.from('organizer_queries').select('id').eq('organizer_id', _userId).neq('status', 'pending');

      if (mounted) {
        setState(() {
          eventListWithStats = processedEvents;
          totalBookedGlobal = globalBooked;
          totalRevenueGlobal = globalRevenue;
          adminResponseCount = queries.length;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading dashboard: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  // --- 1. POPUP: Admin Responses ---
  void _showAdminResponses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Admin Responses", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder(
                  stream: Supabase.instance.client
                      .from('organizer_queries')
                      .stream(primaryKey: ['id'])
                      .eq('organizer_id', _userId)
                      .order('created_at'),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No queries found"));

                    final items = snapshot.data!;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final q = items[index];
                        // Colors based on status
                        Color statusColor = q['status'] == 'approved' ? Colors.green : (q['status'] == 'rejected' ? Colors.red : Colors.orange);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(child: Text(q['subject'], style: const TextStyle(fontWeight: FontWeight.bold))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4)),
                                      child: Text(q['status'].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text("Req: ${q['description']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                if (q['admin_response'] != null) ...[
                                  const Divider(),
                                  Text("Admin: ${q['admin_response']}", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- 2. POPUP: Request Edit Form ---
  void _showRequestForm(Map<String, dynamic> event) {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Request Change: ${event['event_name']}", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: "Subject")),
            TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (subjectCtrl.text.isEmpty) return;

              await Supabase.instance.client.from('organizer_queries').insert({
                'organizer_id': _userId,
                'event_id': event['id'],
                'event_name': event['event_name'],
                'subject': subjectCtrl.text,
                'description': descCtrl.text,
                'status': 'pending'
              });

              if(mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Request Sent! Admin will review it.")));
                _fetchDashboardData(); // Refresh to update Admin Response count potentially
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text("Send Request", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // --- 3. POPUP: Date Range Filter (Revenue) ---
  Future<void> _showRevenueFilter() async {
    DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(primaryColor: const Color(0xFF6C63FF)),
          child: child!
      ),
    );

    if (pickedRange != null) {
      if(mounted) showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));

      try {
        // Fetch Tickets within Range for CURRENT USER'S events
        final myEvents = await Supabase.instance.client.from('events').select('id').eq('creator_id', _userId);
        final List<int> myEventIds = (myEvents as List).map<int>((e) => e['id'] as int).toList();

        if (myEventIds.isEmpty) {
          if(mounted) Navigator.pop(context); // Close loader
          return;
        }

        final response = await Supabase.instance.client
            .from('tickets')
            .select('quantity, final_price')
            .inFilter('event_id', myEventIds) // ✅ Filter by MY events
            .gte('created_at', pickedRange.start.toIso8601String())
            .lte('created_at', pickedRange.end.toIso8601String());

        if (mounted) Navigator.pop(context); // Close Loader

        int rangeBooked = 0;
        double rangeRevenue = 0.0;

        for (var t in response) {
          rangeBooked += (t['quantity'] as int? ?? 1);
          rangeRevenue += (t['final_price'] as num).toDouble();
        }

        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Revenue Report"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Period: ${DateFormat('dd MMM').format(pickedRange.start)} - ${DateFormat('dd MMM').format(pickedRange.end)}"),
                  const Divider(),
                  _statRow("Seats Booked", "$rangeBooked"),
                  _statRow("Total Revenue", "₹${rangeRevenue.toInt()}", isBold: true),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
            ),
          );
        }
      } catch (e) {
        if(mounted) Navigator.pop(context);
        debugPrint("Error revenue filter: $e");
      }
    }
  }

  Widget _statRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: isBold ? Colors.green : Colors.black, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back,", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
            Text(organizerName, style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ FIXED LOGOUT LOGIC
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                // Remove all screens from stack and go to Auth
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const OrganizerAuthScreen()),
                      (route) => false,
                );
              }
            },
          )
        ],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. STATS CARD (Clickable)
            OrganizerStatsCard(
              adminResponses: adminResponseCount,
              totalRevenue: totalRevenueGlobal,
              totalBooked: totalBookedGlobal,
              onResponseTap: _showAdminResponses, // ✅ Opens bottom sheet
              onRevenueTap: _showRevenueFilter,   // ✅ Opens date picker
            ),

            const SizedBox(height: 20),

            // 2. ADD EVENT BUTTON
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerAddEventScreen())).then((_) => _fetchDashboardData()),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(15)),
                child: const Center(child: Text("+ Add New Event", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ),
            ),

            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text("Your Events", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),

            // 3. EVENT LIST (With Per-Event Stats)
            OrganizerEventList(
              events: eventListWithStats,
              onRequestEdit: _showRequestForm,
            ),
          ],
        ),
      ),
    );
  }
}