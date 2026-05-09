class TravelOfficeModel {
  final String id; // backend uses _id (string)
  final String name;
  final String? city;
  final String? country;
  final double? rating;
  final int? reviewsCount;
  final String? description;
  final String? priceRange;
  final String? workingHours;
  final List<String> services; // backend returns services as array
  final String? phone;
  final String? email;
  final String? website;
  final String? imageUrl;
  final String? logoUrl;
  final bool isActive;

  TravelOfficeModel({
    required this.id,
    required this.name,
    this.city,
    this.country,
    this.rating,
    this.reviewsCount,
    this.description,
    this.priceRange,
    this.workingHours,
    this.services = const [],
    this.phone,
    this.email,
    this.website,
    this.imageUrl,
    this.logoUrl,
    this.isActive = true,
  });

  // Backward-compatible getter so existing screens still compile
  String? get specialties => services.isNotEmpty ? services.join(', ') : null;

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

  factory TravelOfficeModel.fromJson(Map<String, dynamic> json) {
    // Backend returns nested location object
    final location = json['location'] as Map<String, dynamic>? ?? {};

    // services can be an array of strings
    List<String> servicesList = [];
    final rawServices = json['services'];
    if (rawServices is List) {
      servicesList = rawServices.map((e) => e.toString()).toList();
    }

    return TravelOfficeModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      city: (location['city'] ?? json['city'])?.toString(),
      country: (location['country'] ?? json['country'])?.toString(),
      rating: json['rating'] != null ? _toDouble(json['rating']) : null,
      reviewsCount: json['reviewsCount'] != null
          ? _toInt(json['reviewsCount'])
          : (json['reviews_count'] != null ? _toInt(json['reviews_count']) : null),
      description: json['description']?.toString(),
      priceRange: json['price_range']?.toString(),
      workingHours: json['working_hours']?.toString(),
      services: servicesList,
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      website: json['website']?.toString(),
      imageUrl: (json['image_url'] ?? json['logo'])?.toString(),
      logoUrl: (json['images'] != null && (json['images'] as List).isNotEmpty)
          ? json['images'][0].toString()
          : (json['logo_url'] ?? json['logo'])?.toString(),
      isActive: json['isActive'] == true || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'location': {'city': city, 'country': country},
    'rating': rating,
    'reviewsCount': reviewsCount,
    'description': description,
    'price_range': priceRange,
    'working_hours': workingHours,
    'services': services,
    'phone': phone,
    'email': email,
    'website': website,
    'image_url': imageUrl,
    'logo_url': logoUrl,
    'isActive': isActive,
  };
}
