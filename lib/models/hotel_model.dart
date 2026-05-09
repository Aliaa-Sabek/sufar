class Hotel {
  final String id;
  final String name;
  final String city;
  final String country;
  final String description;
  final List<String> images;
  final int stars;
  final double rating;
  final int reviewsCount;
  final double startingFrom;
  final String mealPlan;
  final String locationType;
  final String address;
  final double? latitude;
  final double? longitude;
  final List<String> facilities;
  final List<String> nearbyActivities;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.description,
    required this.images,
    required this.stars,
    required this.rating,
    required this.reviewsCount,
    required this.startingFrom,
    required this.mealPlan,
    required this.locationType,
    required this.address,
    this.latitude,
    this.longitude,
    required this.facilities,
    required this.nearbyActivities,
  });

  // Convenience getters for backward-compatible usage in screens
  String get imageUrl {
    if (images.isNotEmpty && images[0].isNotEmpty) {
      return images[0];
    }
    return '';
  }

  int get price => startingFrom.toInt();

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory Hotel.fromJson(Map<String, dynamic> json) {
    // Support both backend (_id) and Supabase (id) formats
    final id = (json['_id'] ?? json['id'] ?? '').toString();

    // Location object from backend
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final coords = location['coordinates'] as Map<String, dynamic>? ?? {};

    return Hotel(
      id: id,
      name: (json['name'] ?? 'Unknown Hotel').toString(),
      city: (location['city'] ?? json['city'] ?? 'Unknown').toString(),
      country: (location['country'] ?? json['country'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      images: () {
        if (json['images'] != null && (json['images'] as List).isNotEmpty) {
          return List<String>.from(json['images']);
        }
        if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
          return [json['image_url'].toString()];
        }
        if (json['image'] != null && json['image'].toString().isNotEmpty) {
          return [json['image'].toString()];
        }
        return <String>[];
      }(),
      stars: _toInt(json['stars'] ?? json['rating']),
      rating: _toDouble(json['rating']),
      reviewsCount: _toInt(json['reviewsCount'] ?? json['reviews_count'] ?? 0),
      startingFrom: _toDouble(json['startingFrom'] ?? json['price'] ?? 0),
      mealPlan: (json['mealPlan'] ?? 'Breakfast').toString(),
      locationType: (json['locationType'] ?? 'City Center').toString(),
      address: (location['address'] ?? json['address'] ?? '').toString(),
      latitude: coords['lat'] != null
          ? _toDouble(coords['lat'])
          : (json['latitude'] != null ? _toDouble(json['latitude']) : null),
      longitude: coords['lng'] != null
          ? _toDouble(coords['lng'])
          : (json['longitude'] != null ? _toDouble(json['longitude']) : null),
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
      nearbyActivities: json['nearbyActivities'] != null
          ? List<String>.from(json['nearbyActivities'])
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'location': {
      'city': city,
      'country': country,
      'address': address,
      'coordinates': {'lat': latitude, 'lng': longitude},
    },
    'description': description,
    'images': images,
    'stars': stars,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'startingFrom': startingFrom,
    'mealPlan': mealPlan,
    'locationType': locationType,
    'facilities': facilities,
    'nearbyActivities': nearbyActivities,
  };
}
