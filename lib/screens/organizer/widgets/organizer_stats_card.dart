import 'package:flutter/material.dart';

class OrganizerStatsCard extends StatelessWidget {
  final int adminResponses;
  final double totalRevenue;
  final int totalBooked;
  final VoidCallback onResponseTap;
  final VoidCallback onRevenueTap;

  const OrganizerStatsCard({
    super.key,
    required this.adminResponses,
    required this.totalRevenue,
    required this.totalBooked,
    required this.onResponseTap,
    required this.onRevenueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFF4834DF)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(onTap: onResponseTap, child: _item("Admin Resp.", "$adminResponses", Icons.message)),
          _divider(),
          GestureDetector(onTap: onRevenueTap, child: _item("Revenue", "₹${totalRevenue.toInt()}", Icons.currency_rupee)),
          _divider(),
          _item("Booked Seats", "$totalBooked", Icons.chair),
        ],
      ),
    );
  }

  Widget _divider() => Container(height: 40, width: 1, color: Colors.white30);

  Widget _item(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}