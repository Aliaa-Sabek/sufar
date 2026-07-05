import 'package:flutter_test/flutter_test.dart';
import 'package:sufar_project/models/hotel_model.dart';

void main() {
  test('room images from room entries are detected as room images', () {
    final hotel = Hotel.fromJson({
      '_id': 'hotel-1',
      'slug': 'demo-hotel',
      'name': 'Demo Hotel',
      'city': 'Dubai',
      'country': 'UAE',
      'description': 'Demo description',
      'images': <String>[],
      'stars': 5,
      'rating': 4.8,
      'reviewsCount': 10,
      'startingFrom': 200,
      'mealPlan': 'Breakfast',
      'locationType': 'City Center',
      'address': 'Downtown',
      'facilities': <String>[],
      'nearbyActivities': <String>[],
      'rooms': [
        {
          'images': ['room-1.jpg'],
        },
      ],
    });

    expect(hotel.roomImages, isNotEmpty);
    expect(hotel.roomImages.first, contains('room-1.jpg'));
  });
}
