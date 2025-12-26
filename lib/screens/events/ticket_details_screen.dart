import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/ticket_model.dart';
import '../../models/event_model.dart';

class TicketDetailsScreen extends StatelessWidget {
  final TicketModel ticket;
  final EventModel? event; // ✅ Accepts event data to show name/location

  const TicketDetailsScreen({super.key, required this.ticket, this.event});

  Future<void> _downloadTicket(BuildContext context) async {
    // 1. Simulate generation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Preparing ticket for share..."), duration: Duration(seconds: 1)),
    );

    // 2. Prepare Data
    final ticketIdShort = ticket.id.substring(0, 8).toUpperCase();
    final realEventName = event?.eventName ?? "Event Name Unavailable";

    final shareMessage =
        '🎟️ MY TICKET\n\n'
        'Event: $realEventName\n'
        'Quantity: ${ticket.quantity}\n'
        'Type: ${ticket.isVip ? "VIP" : "Standard"}\n'
        'Total Paid: ₹${ticket.finalPrice.toStringAsFixed(0)}\n'
        'Booking ID: $ticketIdShort\n\n'
        'See you there! #MusicMitra';

    // 3. Share/Download
    await Share.share(shareMessage, subject: 'MusicMitra Ticket');
  }

  @override
  Widget build(BuildContext context) {
    final eventName = event?.eventName ?? "Event Name";
    final bookingDate = DateFormat('d MMM yyyy, h:mm a').format(ticket.bookingDate);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Ticket Details", style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text(
              "Booking Confirmed!",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Show this at the entrance.",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Ticket Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(eventName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.white24, height: 30),

                  _buildDetailRow("Ticket ID", ticket.id.substring(0, 8).toUpperCase(), Icons.qr_code),
                  _buildDetailRow("Quantity", "${ticket.quantity}", Icons.confirmation_number),
                  _buildDetailRow("Type", ticket.isVip ? "VIP" : "Standard", Icons.star_border, color: ticket.isVip ? Colors.yellow : null),
                  _buildDetailRow("Total Paid", "₹${ticket.finalPrice.toStringAsFixed(0)}", Icons.payments, color: Colors.greenAccent),
                  _buildDetailRow("Booked On", bookingDate, Icons.calendar_today),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Download Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share, color: Colors.white),
                label: Text("Share / Download Ticket", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _downloadTicket(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }
}