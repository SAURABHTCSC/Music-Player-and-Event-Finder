import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Fetch tickets and join with the 'events' table to get event details
      final response = await Supabase.instance.client
          .from('tickets')
          .select('*, events(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _bookings = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Booking History", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _bookings.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number_outlined, color: Colors.grey, size: 60),
            const SizedBox(height: 10),
            Text("No bookings yet", style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final ticket = _bookings[index];
          final event = ticket['events'] ?? {};
          final eventName = event['event_name'] ?? "Unknown Event";
          final eventImage = (event['image_urls'] as List?)?.isNotEmpty == true ? event['image_urls'][0] : null;
          final bookingDate = DateTime.tryParse(ticket['created_at'].toString());
          final formattedDate = bookingDate != null ? DateFormat('d MMM yyyy, h:mm a').format(bookingDate) : "";

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: eventImage != null
                      ? Image.network(eventImage, width: 100, height: 110, fit: BoxFit.cover)
                      : Container(width: 100, height: 110, color: Colors.grey[800], child: const Icon(Icons.event, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                // Ticket Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(eventName, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("Booked on: $formattedDate", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _badge(Icons.confirmation_number, "${ticket['quantity']} Tickets", Colors.blueAccent),
                            const SizedBox(width: 8),
                            _badge(Icons.currency_rupee, "${ticket['final_price']}", Colors.green),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}