class Booking {
  final String id;       // MongoDB _id is a string
  final String userId;
  final String hotelId;  // MongoDB hotel ref is a string
  final String checkIn;
  final String checkOut;
  final int guests;
  final double totalPrice;
  final String status; // pending, confirmed, cancelled, completed
  final String createdAt;
  final String? hotelName;   // populated from backend
  final String? hotelCity;
  final String? hotelImageUrl;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.hotelName,
    this.hotelCity,
    this.hotelImageUrl,
  });

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Hotel may be a nested object or an ID string
    final hotelRaw = json['hotel'];
    String hotelId = '';
    String? hotelName;
    String? hotelCity;
    String? hotelImageUrl;
    if (hotelRaw is Map<String, dynamic>) {
      hotelId = (hotelRaw['_id'] ?? hotelRaw['id'] ?? '').toString();
      hotelName = hotelRaw['name']?.toString();
      final loc = hotelRaw['location'] as Map<String, dynamic>?;
      hotelCity = loc?['city']?.toString();
      final imgs = hotelRaw['images'] as List?;
      if (imgs != null && imgs.isNotEmpty) {
        hotelImageUrl = imgs[0].toString();
      } else {
        hotelImageUrl = hotelRaw['image_url']?.toString() ?? hotelRaw['image']?.toString();
      }
    } else if (hotelRaw != null) {
      hotelId = hotelRaw.toString();
    }
    // Fallback to hotelId field
    if (hotelId.isEmpty) {
      hotelId = (json['hotelId'] ?? json['hotel_id'] ?? '').toString();
    }

    return Booking(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: (json['user'] ?? json['userId'] ?? json['user_id'] ?? '').toString(),
      hotelId: hotelId,
      checkIn: (json['checkIn'] ?? json['check_in'] ?? '').toString(),
      checkOut: (json['checkOut'] ?? json['check_out'] ?? '').toString(),
      guests: _toInt(json['totalGuests'] ?? json['guests'] ?? 1),
      totalPrice: _toDouble(json['totalPrice'] ?? json['total_price'] ?? 0),
      status: (json['status'] ?? 'pending').toString(),
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
      hotelName: hotelName,
      hotelCity: hotelCity,
      hotelImageUrl: hotelImageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
    'hotelId': hotelId,
    'checkIn': checkIn,
    'checkOut': checkOut,
    'totalGuests': guests,
    'totalPrice': totalPrice,
    'status': status,
  };

  /// Human-readable card title (hotel name when populated).
  String get displayTitle {
    if (hotelName != null && hotelName!.trim().isNotEmpty) {
      return hotelName!.trim();
    }
    if (hotelCity != null && hotelCity!.trim().isNotEmpty) {
      return 'Hotel in ${hotelCity!.trim()}';
    }
    return 'Hotel Booking';
  }

  String get formattedPrice {
    if (totalPrice % 1 == 0) return '\$${totalPrice.toInt()}';
    return '\$${totalPrice.toStringAsFixed(2)}';
  }

  String get formattedDateRange =>
      '${formatDisplayDate(checkIn)} – ${formatDisplayDate(checkOut)}';

  static String formatDisplayDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '—';
    try {
      final date = DateTime.parse(value).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      if (value.length >= 10) return value.substring(0, 10);
      return value;
    }
  }
}
