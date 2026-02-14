class HotelModel {
  final String id;
  final String name;
  final String location;
  final double pricePerNight;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final String currency;

  const HotelModel({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerNight,
    this.currency = '\$',
    this.imageUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  String get formattedPrice => '$currency${pricePerNight.toStringAsFixed(0)}';
}
