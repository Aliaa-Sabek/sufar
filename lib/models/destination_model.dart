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
  final bool isFeatured;

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
    this.isFeatured = false,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
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
      imageUrl: (json['image'] ?? json['image_url'] ?? '').toString(),
      isFeatured: json['isFeatured'] == true || json['is_featured'] == true,
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
  };
}
