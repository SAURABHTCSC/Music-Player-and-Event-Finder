import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/ticket_model.dart';
import '../models/event_model.dart'; // Need this to fetch event name
import '../screens/events/ticket_details_screen.dart'; // To navigate to download

class TicketListCard extends StatelessWidget {
  final TicketModel ticket;
  final EventModel? event; // Event details for display

  const TicketListCard({super.key, required this.ticket, this.event});

  @override
  Widget build(BuildContext context) {
    // Determine the event name (use a placeholder if event data is not provided)
    final eventName = event?.eventName ?? 'Unknown Event';
    final ticketType = ticket.isVip ? 'VIP' : 'Standard';

    return GestureDetector(
      onTap: () {
        // Navigate to the details screen for viewing/downloading the ticket
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailsScreen(ticket: ticket)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueGrey, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Name & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    eventName,
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('BOOKED', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Booking Details
            _buildDetailRow(Icons.calendar_today, 'Date', DateFormat('d MMM yyyy').format(ticket.bookingDate)),
            _buildDetailRow(Icons.confirmation_number, 'Tickets', '${ticket.quantity} ($ticketType)'),
            _buildDetailRow(Icons.money, 'Total Paid', '₹${ticket.finalPrice.toStringAsFixed(0)}', color: Colors.yellow),

            const SizedBox(height: 10),
            Center(
              child: Text(
                'TICKET ID: ${ticket.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey, size: 16),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}