

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import 'payment_screen.dart';

class BookTicketScreen extends StatefulWidget {
  final EventModel event;
  const BookTicketScreen({super.key, required this.event});

  @override
  State<BookTicketScreen> createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  int _quantity = 1;
  bool _isVip = false;
  final double _vipPremium = 0.50; // 50% extra for VIP

  double get _basePrice => widget.event.ticketPrice.toDouble();

  double get _totalPrice {
    double pricePerTicket = _basePrice;
    if (_isVip) {
      pricePerTicket *= (1 + _vipPremium);
    }
    return pricePerTicket * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Book: ${widget.event.eventName}", style: GoogleFonts.poppins()),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Info Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.event.eventName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text("Base Price: ₹${_basePrice.toInt()}", style: const TextStyle(color: Colors.white70)),
                  Text("Location: ${widget.event.locationAddress}", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 1. Quantity Selection
            Text("Select Quantity", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildQuantityButton(Icons.remove, () {
                  if (_quantity > 1) setState(() => _quantity--);
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("$_quantity", style: const TextStyle(color: Colors.white, fontSize: 24)),
                ),
                _buildQuantityButton(Icons.add, () => setState(() => _quantity++)),
              ],
            ),
            const SizedBox(height: 25),

            // 2. VIP Option
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: _isVip ? Colors.yellow.withOpacity(0.1) : Colors.grey[900],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _isVip ? Colors.yellow : Colors.transparent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("VIP Access", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text("+\u20B9${(_basePrice * _vipPremium).toInt()} per ticket (50% premium)", style: const TextStyle(color: Colors.yellow, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isVip,
                    onChanged: (val) => setState(() => _isVip = val),
                    activeColor: Colors.yellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 3. Total Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TOTAL PRICE:", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                Text("₹${_totalPrice.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.greenAccent, fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Next Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF42A5F5), // Blue
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                // inside the onPressed for the "Proceed to Payment" button:

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        // The fix is here:
                        eventId: widget.event.id.toString(), // ✅ Convert int to String
                        quantity: _quantity,
                        isVip: _isVip,
                        finalPrice: _totalPrice,
                      ),
                    ),
                  );
                },
                child: Text("Proceed to Payment", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(10),
      ),
      child: Icon(icon, size: 24),
    );
  }
}