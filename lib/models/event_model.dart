import 'package:supabase_flutter/supabase_flutter.dart';

class EventModel {
  final int id;
  final String eventName;
  final DateTime eventDate;
  final String eventType;
  final String locationAddress;
  final String pincode;
  final double ticketPrice;
  final int availableSeats;
  final String description;
  final List<String> imageUrls;
  final String? videoUrl;
  final int likesCount;
  final String creatorId; // Note: This field caused the null error as it's required

  EventModel({
    required this.id,
    required this.eventName,
    required this.eventDate,
    required this.eventType,
    required this.locationAddress,
    required this.pincode,
    required this.ticketPrice,
    required this.availableSeats,
    required this.description,
    required this.imageUrls,
    this.videoUrl,
    required this.likesCount,
    required this.creatorId,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // 1. Safe parsing for ID (handling int or string from BigInt fields)
    final rawId = json['id'];
    int parsedId;
    if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    } else if (rawId is int) {
      parsedId = rawId;
    } else {
      parsedId = 0;
    }

    return EventModel(
      id: parsedId,

      // 2. Critical Fixes: Using fallback values for required String fields to prevent TypeError: null
      eventName: json['event_name'] ?? 'Unnamed Event',

      // Use DateTime.now() if 'event_date' is null, then format it safely
      eventDate: DateTime.tryParse(json['event_date'] ?? '') ?? DateTime.now(),

      eventType: json['event_type'] ?? 'General',
      locationAddress: json['location_address'] ?? 'Venue Not Specified',
      pincode: json['pincode'] ?? '000000',

      // Using 'num' for price casting to safely handle both int and double from DB
      ticketPrice: (json['ticket_price'] as num?)?.toDouble() ?? 0.0,

      availableSeats: json['available_seats'] ?? 0,
      description: json['description'] ?? 'No description available.',

      // Ensure List<String> is safe from null
      imageUrls: List<String>.from(json['image_urls'] ?? []),

      videoUrl: json['video_url'],

      likesCount: json['likes_count'] ?? 0,

      // ✅ CRITICAL FIX for 'Null is not a subtype of String'
      // This field is often missing in a joined query and needs a default value.
      creatorId: json['creator_id'] ?? 'unknown_creator_id',
    );
  }
}