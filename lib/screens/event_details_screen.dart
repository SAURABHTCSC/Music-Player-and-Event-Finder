import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// ✅ Import the CORRECT main model
import '../models/event_model.dart';
// ✅ Import BookTicketScreen if you want booking functionality here
import 'events/book_ticket_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  final EventModel event; // ✅ Changed from 'Event' to 'EventModel'

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(event.eventDate);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // 1. Image Header
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(event.eventName,
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              background: (event.imageUrls.isNotEmpty)
                  ? Image.network(event.imageUrls[0], fit: BoxFit.cover)
                  : Container(color: Colors.grey[900], child: const Icon(Icons.event, size: 80, color: Colors.white)),
            ),
          ),

          // 2. Details Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Type
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          event.eventName,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(10)),
                        child: Text(event.eventType, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Location & Date
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Expanded(child: Text(event.locationAddress, style: const TextStyle(color: Colors.grey))),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 5),
                      Text(formattedDate, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),

                  const SizedBox(height: 25),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 15),

                  // Description
                  Text("About Event", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),

                  const SizedBox(height: 30),

                  // Price & Booking
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Price", style: TextStyle(color: Colors.white54)),
                          Text("₹${event.ticketPrice.toInt()}", style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          // Navigate to Booking Screen
                          Navigator.push(context, MaterialPageRoute(builder: (_) => BookTicketScreen(event: event)));
                        },
                        child: const Text("Book Ticket", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}