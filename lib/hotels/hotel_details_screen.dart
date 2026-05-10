import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:sufar_project/models/hotel_model.dart';
import 'package:sufar_project/models/review_model.dart';
import 'package:sufar_project/hotels/hotel_booking_process_screen.dart';

class HotelDetailsScreen extends StatefulWidget {
  final Hotel hotel;

  const HotelDetailsScreen({super.key, required this.hotel});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  final List<Review> _reviews = [];
  bool _isReviewsLoading = true;
  final bool _isFavorited = false;
  final bool _isBookingLoading = false;

  // Map state
  LatLng? _hotelLocation;
  bool _isMapLoading = true;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _checkIfFavorited();
    _resolveHotelLocation();
  }

  /// Resolve hotel location: use stored coordinates or geocode city name
  Future<void> _resolveHotelLocation() async {
    // If hotel already has coordinates, use them directly
    if (widget.hotel.latitude != null && widget.hotel.longitude != null) {
      if (mounted) {
        setState(() {
          _hotelLocation = LatLng(
            widget.hotel.latitude!,
            widget.hotel.longitude!,
          );
          _isMapLoading = false;
        });
      }
      return;
    }

    // Otherwise geocode from city name using Nominatim (OpenStreetMap free API)
    try {
      final query = Uri.encodeComponent(
        '${widget.hotel.name}, ${widget.hotel.city}',
      );
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'SufarApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.tryParse(data[0]['lat'].toString());
          final lon = double.tryParse(data[0]['lon'].toString());
          if (lat != null && lon != null && mounted) {
            setState(() {
              _hotelLocation = LatLng(lat, lon);
              _isMapLoading = false;
            });
            return;
          }
        }
      }

      // Fallback: geocode city only
      final cityQuery = Uri.encodeComponent(widget.hotel.city);
      final cityUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$cityQuery&format=json&limit=1',
      );
      final cityResponse = await http.get(
        cityUrl,
        headers: {'User-Agent': 'SufarApp/1.0'},
      );

      if (cityResponse.statusCode == 200) {
        final List<dynamic> cityData = json.decode(cityResponse.body);
        if (cityData.isNotEmpty) {
          final lat = double.tryParse(cityData[0]['lat'].toString());
          final lon = double.tryParse(cityData[0]['lon'].toString());
          if (lat != null && lon != null && mounted) {
            setState(() {
              _hotelLocation = LatLng(lat, lon);
              _isMapLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }

    if (mounted) {
      setState(() => _isMapLoading = false);
    }
  }

  /// Open location in Google Maps
  Future<void> _openInGoogleMaps() async {
    if (_hotelLocation == null) return;
    final lat = _hotelLocation!.latitude;
    final lon = _hotelLocation!.longitude;
    final name = Uri.encodeComponent(widget.hotel.name);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon&query_place_id=$name',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _checkIfFavorited() async {
    // Backend API for favorites not implemented yet
  }

  Future<void> _toggleFavorite() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorites feature coming soon!')),
    );
  }

  Future<void> _bookRoom(String roomTitle, int pricePerNight) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HotelBookingProcessScreen(
          hotel: widget.hotel,
          roomTitle: roomTitle,
          pricePerNight: pricePerNight,
        ),
      ),
    );
  }

  Future<void> _fetchReviews() async {
    if (mounted) {
      setState(() {
        _isReviewsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0D1C52)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : const Color(0xFF0D1C52),
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Color(0xFF0D1C52)),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Builder(
              builder: (context) {
                return widget.hotel.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.hotel.imageUrl,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.hotel,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        height: 250,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.hotel,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
              },
            ),

            Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.hotel.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 4),
                            Text(
                              widget.hotel.rating.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    widget.hotel.description,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 24),

                  if (widget.hotel.images.length > 1) ...[
                    Text(
                      'Hotel Gallery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.hotel.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.hotel.images[index],
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 120,
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: Icon(Icons.image, color: Colors.grey),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  SizedBox(height: 32),

                  // Map Section — Real Interactive Map
                  _buildRealMap(),

                  SizedBox(height: 32),

                  // Share Rating
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Your Rating',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star,
                              size: 32,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              'Send Now',
                              style: TextStyle(
                                
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Welcome text
                  Text(
                    'Welcome to Your Perfect Stay',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Experience comfort and elegance in a hotel designed to meet all your needs. Our hotel offers a perfect balance between modern design and practical services, creating a relaxing atmosphere for both leisure and business travelers. Enjoy well-equipped rooms, attentive staff, and a calm environment that helps you unwind from the moment you arrive.',
                    style: TextStyle(color: Colors.grey[700], height: 1.6),
                  ),

                  SizedBox(height: 48),

                  // Top Facilities
                  Text(
                    'Top Facilities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildFacilityItem(Icons.restaurant, 'restaurant'),
                      _buildFacilityItem(Icons.spa, 'Spa & Wellness Center'),
                      _buildFacilityItem(Icons.pool, 'Swimming Pool'),
                      _buildFacilityItem(Icons.room_service, 'Room Service'),
                      _buildFacilityItem(Icons.wifi, 'free Wifi'),
                      _buildFacilityItem(
                        Icons.support_agent,
                        'Concierge Service',
                      ),
                      _buildFacilityItem(Icons.waves, 'Sea View'),
                      _buildFacilityItem(Icons.star, 'Premium Amenities'),
                    ],
                  ),

                  SizedBox(height: 48),

                  // Our Rooms
                  Text(
                    'Our Rooms',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildRoomGrid(),

                  SizedBox(height: 60),

                  // Reviews
                  Text(
                    'what customers say about this hotel',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_isReviewsLoading)
                    Center(child: CircularProgressIndicator())
                  else if (_reviews.isEmpty)
                    Text(
                      'No reviews yet. Be the first to review!',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          return _buildReviewCard(
                            'User ${review.userId}', // We can fetch name later
                            'Traveler',
                            review.comment,
                            review.rating,
                            isHighlighted: index % 2 == 1,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location label
        Row(
          children: [
            Icon(Icons.location_on,  size: 18),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                '${widget.hotel.name}, ${widget.hotel.city}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),

        // Map container
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 220,
            child: _isMapLoading
                ? Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF1A94C4)),
                          SizedBox(height: 12),
                          Text(
                            'Loading map...',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : _hotelLocation == null
                ? Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 50,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Location not available',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _hotelLocation!,
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [
                      // OpenStreetMap tiles (free, no API key needed)
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sufar.sufar_project',
                        maxZoom: 19,
                      ),
                      // Hotel location marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _hotelLocation!,
                            width: 60,
                            height: 70,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.hotel.name.length > 8
                                        ? '${widget.hotel.name.substring(0, 8)}...'
                                        : widget.hotel.name,
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFFE53935),
                                  size: 36,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),

        // "View larger map" button
        if (!_isMapLoading && _hotelLocation != null) ...[
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: _openInGoogleMaps,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4AFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new, color: Theme.of(context).cardColor, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'View larger map',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFacilityItem(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(icon,  size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomGrid() {
    final roomImage = widget.hotel.images.length > 1 
        ? widget.hotel.images[1] 
        : (widget.hotel.imageUrl.isNotEmpty ? widget.hotel.imageUrl : 'https://placehold.co/400x200/png?text=Room');
    final altRoomImage = widget.hotel.images.length > 2
        ? widget.hotel.images[2]
        : roomImage;

    return Column(
      children: [
        _buildRoomCard(
          roomImage,
          'Standard Double Room',
          '\$${widget.hotel.price} per night',
        ),
        SizedBox(height: 16),
        _buildRoomCard(
          roomImage,
          'Standard Double Room',
          '\$${widget.hotel.price} per night',
          isNotAvailable: true,
        ),
        SizedBox(height: 16),
        _buildRoomCard(
          altRoomImage,
          'Penthouse suite with balcony view',
          '\$${(widget.hotel.price * 1.5).toInt()} per night',
        ),
        SizedBox(height: 16),
        _buildRoomCard(
          altRoomImage,
          'Penthouse suite with balcony view',
          '\$${(widget.hotel.price * 1.5).toInt()} per night',
          isNotAvailable: true,
        ),
      ],
    );
  }

  Widget _buildRoomCard(
    String imageUrl,
    String title,
    String price, {
    bool isNotAvailable = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.bed, color: Colors.grey),
                  ),
                ),
              ),
              if (isNotAvailable)
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.3),
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Not Available',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 16),
                _buildBulletDetail('1 bathroom'),
                SizedBox(height: 4),
                _buildBulletDetail('2 beds'),
                SizedBox(height: 4),
                _buildBulletDetail('2 people'),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '220 \$', // Hardcoded original price to strikethrough like screenshot
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A94C4),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: isNotAvailable
                          ? null
                          : () => _bookRoom(title, 200),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isNotAvailable
                            ? Colors.grey
                            : const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        _isBookingLoading ? '...' : 'BOOK NOW',
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletDetail(String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: Colors.grey),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildReviewCard(
    String name,
    String role,
    String comment,
    double rating, {
    bool isHighlighted = false,
  }) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      color: index < rating
                          ? const Color(0xFF1A94C4)
                          : Colors.grey[300],
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Color(0xFFDDE1E6),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
                  ),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
