import '../services/image_service.dart';

class ActivityModel {
  final String title;
  final String description;
  final String imageUrl;

  ActivityModel({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory ActivityModel.fromJson(
    Map<String, dynamic> json, {
    String? citySlug,
  }) {
    String imageUrl = '';
    final possibleFields = [
      json['image'],
      json['image_url'],
      json['imageUrl'],
      json['thumbnail'],
      json['photo'],
    ];
    for (final field in possibleFields) {
      if (field == null) continue;
      final raw = field.toString().trim();
      if (raw.isEmpty) continue;
      // Activities: Pexels only (from activity_images.json / resolver).
      if (raw.startsWith('https://') && ImageService.isPexelsUrl(raw)) {
        imageUrl = raw;
        break;
      }
    }

    return ActivityModel(
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: imageUrl,
    );
  }
}

class DestinationModel {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String country;
  final String countryAr;
  final String region;
  final String description;
  final List<String> highlights;
  final String imageUrl;
  final List<String> images; // Multiple images for gallery
  final bool isFeatured;
  final List<ActivityModel> activities;

  /// City card / header hero — destination Cloudinary only (not activities/hotels).
  String get coverImageUrl {
    if (imageUrl.isNotEmpty) return imageUrl;
    for (final img in images) {
      if (img.isNotEmpty) return img;
    }
    return '';
  }

  // backward-compatible getters
  String get city => name;
  double get rating => 4.5;
  double get latitude => 0.0;
  double get longitude => 0.0;
  String get category => region;

  DestinationModel({
    required this.id,
    required this.name,
    this.nameAr = '',
    this.slug = '',
    required this.country,
    this.countryAr = '',
    this.region = '',
    required this.description,
    this.highlights = const [],
    required this.imageUrl,
    this.images = const [],
    this.isFeatured = false,
    this.activities = const [],
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final slug = (json['slug'] ?? '').toString();
    final cityName = (json['name'] ?? '').toString();

    // Get image from various possible fields
    String imageUrl = '';

    final localAsset = ImageService.getLocalAssetForSlug(slug);
    if (localAsset != null) {
      imageUrl = localAsset;
    } else {
      // Try primary image fields in order of preference
      final possibleImageFields = [
        json['image'],
        json['image_url'],
        json['imageUrl'],
        json['thumbnail'],
        json['thumbnail_url'],
      ];

      for (final field in possibleImageFields) {
        if (field == null) continue;
        final raw = field.toString().trim();
        if (ImageService.isPexelsUrl(raw)) continue;
        final normalized = ImageService.urlForWidget(
          raw,
          citySlug: slug,
          cityName: cityName,
          type: 'destination',
        );
        if (normalized.isNotEmpty) {
          imageUrl = normalized;
          break;
        }
      }
    }

    if (imageUrl.isEmpty && slug.isNotEmpty) {
      imageUrl = ImageService.cloudinaryDestinationUrl(slug);
    }

    // Parse images array (gallery)
    List<String> imagesList = [];
    if (json['images'] is List) {
      imagesList = (json['images'] as List)
          .map((e) {
            final raw = e.toString();
            if (ImageService.isPexelsUrl(raw)) return '';
            final norm = ImageService.urlForWidget(
              raw,
              citySlug: slug,
              cityName: cityName,
              type: 'destination',
            );
            return norm;
          })
          .where((u) => u.isNotEmpty)
          .toList();
    }
    final seenImg = imagesList.map(ImageService.dedupeKey).toSet();
    if (imageUrl.isNotEmpty && seenImg.add(ImageService.dedupeKey(imageUrl))) {
      imagesList.insert(0, imageUrl);
    }

    // Parse activities (or structured highlights with images)
    List<ActivityModel> activitiesList = [];
    if (json['activities'] is List) {
      activitiesList = (json['activities'] as List)
          .whereType<Map>()
          .map(
            (e) => ActivityModel.fromJson(
              Map<String, dynamic>.from(e),
              citySlug: slug,
            ),
          )
          .toList();
    } else if (json['highlights'] is List &&
        (json['highlights'] as List).isNotEmpty &&
        (json['highlights'] as List).first is Map) {
      activitiesList = (json['highlights'] as List)
          .whereType<Map>()
          .map(
            (e) => ActivityModel.fromJson(
              Map<String, dynamic>.from(e),
              citySlug: slug,
            ),
          )
          .toList();
    }

    return DestinationModel(
      id: id,
      name: (json['name'] ?? 'Unknown').toString(),
      nameAr: (json['name_ar'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      country: (json['country'] ?? 'Unknown').toString(),
      countryAr: (json['country_ar'] ?? '').toString(),
      region: (json['region'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      highlights: json['highlights'] != null
          ? List<String>.from(json['highlights'])
          : [],
      imageUrl: imageUrl,
      images: imagesList,
      isFeatured: json['isFeatured'] == true || json['is_featured'] == true,
      activities: activitiesList,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'name_ar': nameAr,
    'slug': slug,
    'country': country,
    'country_ar': countryAr,
    'region': region,
    'description': description,
    'highlights': highlights,
    'image': imageUrl,
    'isFeatured': isFeatured,
    'activities': activities
        .map(
          (a) => {
            'title': a.title,
            'description': a.description,
            'image': a.imageUrl,
          },
        )
        .toList(),
  };
}
