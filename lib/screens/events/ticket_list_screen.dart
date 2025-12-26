import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/ticket_model.dart';
import '../../models/event_model.dart';
import '../../widgets/ticket_list_card.dart';
import 'ticket_details_screen.dart'; // ✅ Links to your details screen

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  Stream<List<Map<String, dynamic>>> _getTicketsWithEvents() async* {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) yield [];

    final data = await Supabase.instance.client
        .from('tickets')
        .select('*, events(*)') // Fetch tickets and their event data
        .eq('user_id', userId!)
        .order('booking_date', ascending: false);

    yield List<Map<String, dynamic>>.from(data as List);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Your Tickets", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getTicketsWithEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.confirmation_number_outlined, color: Colors.grey, size: 60),
                  const SizedBox(height: 10),
                  Text("No tickets booked yet.", style: GoogleFonts.poppins(color: Colors.grey)),
                ],
              ),
            );
          }

          final ticketDataList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ticketDataList.length,
            itemBuilder: (context, index) {
              final rawTicket = ticketDataList[index];
              final ticket = TicketModel.fromJson(rawTicket);

              // Parse Event Data safely
              final eventData = rawTicket['events'];
              final event = (eventData != null && eventData is Map<String, dynamic>)
                  ? EventModel.fromJson(eventData)
                  : null;

              // ✅ CLICK TO OPEN DETAILS
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TicketDetailsScreen(ticket: ticket, event: event),
                    ),
                  );
                },
                child: TicketListCard(ticket: ticket, event: event),
              );
            },
          );
        },
      ),
    );
  }
}