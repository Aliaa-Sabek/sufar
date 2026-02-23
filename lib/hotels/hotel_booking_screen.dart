import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Model
class Hotel {
  final int id;
  final String name;
  final String city;
  final String country;
  final String address;
  final double rating;
  final double lat;
  final double lng;
  final List<String> amenities;

  Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.address,
    required this.rating,
    required this.lat,
    required this.lng,
    required this.amenities,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    return Hotel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Hotel',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      address: json['address'] ?? 'No address available',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }
}

// Helpers
IconData _amenityIcon(String amenity) {
  switch (amenity) {
    case 'free_wifi':         return Icons.wifi;
    case 'parking':           return Icons.local_parking;
    case 'gym':               return Icons.fitness_center;
    case 'spa':               return Icons.spa;
    case 'bar':               return Icons.local_bar;
    case 'restaurant':        return Icons.restaurant;
    case 'pool':              return Icons.pool;
    case 'front_desk_24h':    return Icons.access_time;
    case 'laundry':           return Icons.local_laundry_service;
    case 'meeting_rooms':     return Icons.meeting_room;
    case 'wheelchair_access': return Icons.accessible;
    default:                  return Icons.check_circle_outline;
  }
}

String _amenityLabel(String amenity) {
  return amenity
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
      .join(' ');
}

// the screen =
class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  static const String _baseUrl = 'https://api.hotels-api.com/v1/hotels/search';
  static const String _apiKey =
      '72bda0e16bc68d187c6296acad54918211911c2b2706b11bf26ee76808aaf343';

  final TextEditingController _cityController = TextEditingController();

  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;
  String? _rawDebugResponse;

  // ── API call ──────────────────────────────────────────────────────────────

  Future<void> _searchHotels() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _rawDebugResponse = null;
      _hotels = [];
      _hasSearched = true;
    });

    try {
      final uri = Uri.parse('$_baseUrl?city=${Uri.encodeComponent(city)}');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);

        List<dynamic> hotelList;
        if (decoded is List) {
          hotelList = decoded;
        } else if (decoded is Map) {
          if (decoded.containsKey('hotels')) {
            hotelList = decoded['hotels'] as List<dynamic>;
          } else if (decoded.containsKey('data')) {
            hotelList = decoded['data'] as List<dynamic>;
          } else if (decoded.containsKey('results')) {
            hotelList = decoded['results'] as List<dynamic>;
          } else {
            hotelList = [];
          }
        } else {
          hotelList = [];
        }

        setState(() {
          _hotels = hotelList
              .map((e) => Hotel.fromJson(e as Map<String, dynamic>))
              .toList();
          if (_hotels.isEmpty) {
            _rawDebugResponse =
            'Status: ${response.statusCode}\n\n${response.body}';
          }
        });
      } else {
        setState(() {
          _errorMessage =
          'Server error (${response.statusCode}). Please try again.';
          _rawDebugResponse =
          'Status: ${response.statusCode}\n\n${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  // screen builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C52),
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchHotels(),
              decoration: InputDecoration(
                hintText: 'Enter city name…',
                prefixIcon: const Icon(Icons.location_city),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _isLoading ? null : _searchHotels,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1C52),
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugBox() {
    if (_rawDebugResponse == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: SelectableText(
        _rawDebugResponse!,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            _buildDebugBox(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _searchHotels,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for hotels in any city',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hotels.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No hotels found. Raw API response:',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            _buildDebugBox(),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _hotels.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _HotelCard(hotel: _hotels[index]),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

// Hotel's card
class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hotel,
                      size: 30, color: Color(0xFF0D1C52)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1C52),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${hotel.city}, ${hotel.country}',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _RatingBadge(rating: hotel.rating),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              hotel.address,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (hotel.amenities.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: hotel.amenities.map((a) {
                  return Chip(
                    avatar: Icon(_amenityIcon(a),
                        size: 14, color: const Color(0xFF0D1C52)),
                    label: Text(
                      _amenityLabel(a),
                      style: const TextStyle(fontSize: 11),
                    ),
                    backgroundColor: const Color(0xFFE8ECF4),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D1C52),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// the badge of the rating
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade600,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
