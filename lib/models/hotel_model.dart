import '../services/image_service.dart';

class Hotel {
  final String id;
  final String slug;
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
    this.slug = '',
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
    final list = generalImages;
    if (list.isEmpty) return '';
    return list.firstWhere((img) => img.trim().isNotEmpty, orElse: () => '');
  }

  static List<String> _dedupeUrls(Iterable<String> urls) {
    final seen = <String>{};
    final out = <String>[];
    for (final raw in urls) {
      final u = raw.trim();
      if (u.isEmpty) continue;
      if (seen.add(ImageService.dedupeKey(u))) out.add(u);
    }
    return out;
  }

  /// Hotel exterior / lobby photos from `.../general/`.
  List<String> get generalImages {
    final general = ImageService.hotelGeneralImages(images);
    final list = general.isNotEmpty
        ? _dedupeUrls(general)
        : _dedupeUrls(images.where((u) => !u.contains('/rooms/')));
    final fallbackList = list.isNotEmpty ? list : _dedupeUrls(images.take(1));
    return fallbackList;
  }

  /// Room photos from `.../rooms/` only, with a resilient fallback to any room-related
  /// image URLs that are present in the hotel payload.
  List<String> get roomImages {
    final roomPhotos = _dedupeUrls(ImageService.hotelRoomImages(images));
    if (roomPhotos.isNotEmpty) return roomPhotos;

    final fallback = _dedupeUrls(
      images.where((u) {
        final value = u.toLowerCase();
        return value.contains('/rooms/') || value.contains('room') || value.contains('suite');
      }),
    );
    return fallback;
  }

  /// Deduplicated gallery (general shots only — not rooms).
  List<String> get uniqueImages => generalImages;

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
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown Hotel').toString(),
      city: (location['city'] ?? json['city'] ?? 'Unknown').toString(),
      country: (location['country'] ?? json['country'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      images: () {
        String? rawFrom(dynamic value) {
          if (value == null) return null;
          if (value is Map) {
            final raw =
                value['url'] ?? value['secure_url'] ?? value['src'] ?? '';
            return raw.toString();
          }
          return value.toString();
        }

        final cityName = (location['city'] ?? json['city'] ?? '').toString();
        final hotelSlug = (json['slug'] ?? '').toString();

        String normalize(String u, {required String type}) => ImageService.urlForWidget(
          u,
          type: type,
          cityName: cityName,
          hotelSlug: hotelSlug,
        );

        final urls = <String>[];
        final seen = <String>{};

        void add(dynamic value, {required String type}) {
          final raw = rawFrom(value);
          if (raw == null || raw.isEmpty) return;
          if (ImageService.isPexelsUrl(raw)) return;
          final n = normalize(raw, type: type);
          if (n.isEmpty) return;
          if (seen.add(ImageService.dedupeKey(n))) urls.add(n);
        }

        if (json['images'] is List) {
          for (final item in json['images'] as List) {
            add(item, type: 'hotel');
          }
        }

        if (json['generalImages'] is List) {
          for (final item in json['generalImages'] as List) {
            add(item, type: 'hotel-general');
          }
        }
        if (json['roomImages'] is List) {
          for (final item in json['roomImages'] as List) {
            add(item, type: 'hotel-room');
          }
        }

        add(
          json['image_url'] ?? json['image'] ?? json['imageUrl'],
          type: 'hotel',
        );

        if (json['gallery'] is List) {
          for (final item in json['gallery'] as List) {
            add(item, type: 'hotel-general');
          }
        }

        if (json['rooms'] is List) {
          for (final room in json['rooms'] as List) {
            if (room is! Map) continue;
            final roomMap = Map<String, dynamic>.from(room);
            if (roomMap['images'] is List) {
              for (final item in roomMap['images'] as List) {
                add(item, type: 'hotel-room');
              }
            }
          }
        }

        return urls;
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
