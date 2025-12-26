// lib/models/ticket_model.dart

class TicketModel {
  final String id;
  final String eventId;
  final String userId;
  final int quantity;
  final bool isVip;
  final double finalPrice;
  final String paymentMethod;
  final DateTime bookingDate;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.quantity,
    required this.isVip,
    required this.finalPrice,
    required this.paymentMethod,
    required this.bookingDate,
  });

  // lib/models/ticket_model.dart (check the fromJson constructor)

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,

      // 🛑 Check this line! If the error is here, you need to call toString()
      // If the DB returns BIGINT (int) for event_id, and the Dart model expects String:
      eventId: json['event_id'].toString(), // ✅ FIX HERE IF eventId is a String in the model

      userId: json['user_id'] as String,
      quantity: json['quantity'] as int,
      isVip: json['is_vip'] as bool,
      finalPrice: (json['final_price'] as num).toDouble(), // Use num for safety
      paymentMethod: json['payment_method'] as String,
      bookingDate: DateTime.parse(json['booking_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'user_id': userId,
      'quantity': quantity,
      'is_vip': isVip,
      'final_price': finalPrice,
      'payment_method': paymentMethod,
      'booking_date': bookingDate.toIso8601String(),
    };
  }
}