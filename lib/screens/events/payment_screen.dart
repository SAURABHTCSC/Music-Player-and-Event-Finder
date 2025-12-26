import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:google_fonts/google_fonts.dart';
import 'package:musicmitra/models/ticket_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart'; // ✅ NEW IMPORT for dynamic QR code
import 'ticket_details_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String eventId; // Passed as String from BookTicketScreen
  final int quantity;
  final bool isVip;
  final double finalPrice;

  const PaymentScreen({
    super.key,
    required this.eventId,
    required this.quantity,
    required this.isVip,
    required this.finalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _isProcessing = false;

  // Controller for UPI input
  final TextEditingController _upiController = TextEditingController();

  // Merchant details (Replace with your actual values)
  final String _merchantUpiId = 'avinashprajapati9335@okaxis';
  final String _merchantName = 'MusicMitra Events';

  // ✅ Dynamic UPI Link Generator to pre-set the amount
  String get _dynamicUpiLink {
    final amount = widget.finalPrice.toStringAsFixed(2);
    // Format: upi://pay?pa=ADDRESS&pn=NAME&am=AMOUNT&cu=INR
    return 'upi://pay?pa=$_merchantUpiId&pn=$_merchantName&am=$amount&cu=INR';
  }

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _processPaymentAndBook() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a payment method.")));
      return;
    }

    // UPI Validation
    if (_selectedMethod == "UPI" && _upiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your UPI ID.")));
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to book a ticket.")));
      return;
    }

    setState(() => _isProcessing = true);

    // --- Simulate Payment Processing (3 seconds) ---
    await Future.delayed(const Duration(seconds: 3));

    try {
      final uniqueTicketId = const Uuid().v4();

      final newTicket = TicketModel(
        id: uniqueTicketId,
        eventId: widget.eventId,
        userId: userId,
        quantity: widget.quantity,
        isVip: widget.isVip,
        finalPrice: widget.finalPrice,
        paymentMethod: _selectedMethod!,
        bookingDate: DateTime.now(),
      );

      // --- Database Insert ---
      final ticketJson = newTicket.toJson();

      // ✅ CRITICAL FIX: Convert eventId string back to int for the DB insert
      ticketJson['event_id'] = int.parse(widget.eventId);

      await Supabase.instance.client.from('tickets').insert(ticketJson);

      // Navigate to Ticket Details Screen and clear the stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailsScreen(ticket: newTicket)),
              (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Booking failed: Did you create the 'tickets' table? Error: ${e.toString().split('hint: null').first}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Final Payment", style: GoogleFonts.poppins()),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Amount Due:", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                Text("₹${widget.finalPrice.toStringAsFixed(0)}", style: GoogleFonts.poppins(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 30),

            Text("Select Payment Method", style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),

            // Payment Option: QR Code (Dynamic)
            _buildPaymentOption(
              icon: Icons.qr_code_2,
              title: "Scan QR Code",
              subtitle: "Amount pre-filled. Open any UPI app and scan to pay.",
              value: "QR",
            ),
            const SizedBox(height: 15),

            // Payment Option: UPI ID (Manual)
            _buildPaymentOption(
              icon: Icons.payments,
              title: "Pay via UPI ID",
              subtitle: _selectedMethod == "UPI" && _upiController.text.isNotEmpty
                  ? "Your ID: ${_upiController.text}"
                  : "Tap to enter your UPI ID",
              value: "UPI",
            ),
            const SizedBox(height: 15),

            // Conditional QR View (Dynamic)
            if (_selectedMethod == "QR")
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QrImageView(
                      data: _dynamicUpiLink,
                      version: QrVersions.auto,
                      size: 220.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),

            // Conditional UPI Input View
            if (_selectedMethod == "UPI")
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Our UPI ID: $_merchantUpiId", style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _merchantUpiId));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("UPI ID copied to clipboard!")));
                      },
                      child: const Text("Tap to Copy", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    ),
                    const SizedBox(height: 10),
                    // UPI ID Input Field
                    TextField(
                      controller: _upiController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Enter your UPI ID (for confirmation)',
                        labelStyle: TextStyle(color: Colors.grey[400]),
                        hintText: 'e.g., yourname@bank',
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text('By clicking "Confirm Payment", you confirm payment has been made manually to the UPI ID shown above.', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                ),
              ),

            const Spacer(),

            // Confirm Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isProcessing ? Colors.grey : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isProcessing ? null : _processPaymentAndBook,
                child: _isProcessing
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text("Confirming Booking...", style: TextStyle(color: Colors.white)),
                  ],
                )
                    : Text("Confirm Payment", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required IconData icon, required String title, required String subtitle, required String value}) {
    final isSelected = _selectedMethod == value;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethod = value;
      }),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.white70, size: 30),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}