import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizerEventList extends StatelessWidget {
  final List<Map<String, dynamic>> events; // Now contains 'booked' and 'revenue' keys
  final Function(Map<String, dynamic>) onRequestEdit;

  const OrganizerEventList({super.key, required this.events, required this.onRequestEdit});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(padding: EdgeInsets.only(top: 40), child: Center(child: Text("No events created yet.", style: TextStyle(color: Colors.grey))));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final booked = event['booked_count'] ?? 0;
        final revenue = event['event_revenue'] ?? 0;
        final totalSeats = event['total_seats'] ?? 0;
        final price = event['ticket_price'] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      (event['image_urls'] as List).isNotEmpty ? event['image_urls'][0] : '',
                      width: 60, height: 60, fit: BoxFit.cover,
                      errorBuilder: (c,e,s) => Container(color: Colors.grey[200], width: 60, child: const Icon(Icons.event)),
                    ),
                  ),
                  title: Text(event['event_name'], style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text("Price: ₹$price", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_note, color: Colors.orange),
                    tooltip: "Request Edit",
                    onPressed: () => onRequestEdit(event),
                  ),
                ),
                const Divider(),
                // ✅ Detailed Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _miniStat("Total Seats", "$totalSeats"),
                    _miniStat("Booked", "$booked", color: Colors.green),
                    _miniStat("Revenue", "₹$revenue", color: Colors.blueAccent),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniStat(String label, String value, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}