import 'package:flutter/material.dart';

import '../models/destination_model.dart';
import '../models/review_model.dart';
import '../flights/flight_landing_screen_v2.dart';
import '../models/hotel_model.dart';
import '../services/api_service.dart';
import '../hotels/hotel_details_screen.dart';

class DestinationDetailsScreen extends StatefulWidget {
  final DestinationModel destination;

  const DestinationDetailsScreen({super.key, required this.destination});

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  final List<Review> _reviews = [];
  bool _isReviewsLoading = true;
  final bool _isFavorited = false;

  final List<Hotel> _hotels = [];
  bool _isHotelsLoading = true;
  String? _hotelsError;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
    _checkIfFavorited();
    _fetchHotels();
  }

  Future<void> _checkIfFavorited() async {
    // Backend API for favorites not implemented yet
  }

  Future<void> _toggleFavorite() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorites feature coming soon!')),
    );
  }

  Future<void> _fetchReviews() async {
    if (mounted) {
      setState(() {
        _isReviewsLoading = false;
      });
    }
  }

  Future<void> _fetchHotels() async {
    setState(() {
      _isHotelsLoading = true;
      _hotelsError = null;
    });
    try {
      // Try to filter by destination name as city (backend supports city filter).
      final res = await ApiService.getHotels(city: widget.destination.name, limit: 10);
      final hotelList = res['hotels'] as List? ?? [];
      final parsed = hotelList.map((e) => Hotel.fromJson(e as Map<String, dynamic>)).toList();

      if (mounted) {
        setState(() {
          _hotels
            ..clear()
            ..addAll(parsed);
          _isHotelsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isHotelsLoading = false;
          _hotelsError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          // ── Scrollable content ──────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Image (no back button here anymore)
                Stack(
                  children: [
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: widget.destination.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(
                                  widget.destination.imageUrl,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.grey[300],
                      ),
                    ),
                    Container(
                      height: 380,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.destination.city}, ${widget.destination.country}',
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.destination.name,
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Weather Block
                Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.wb_sunny_outlined,
                            color: Colors.lightBlue[300],
                            size: 28,
                          ),
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weather',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '28°C - Tropical',
                              style: TextStyle(
                                
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // About Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About ${widget.destination.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.destination.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Things to Do
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Things to Do',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 260,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      ...(widget.destination.highlights.isNotEmpty
                              ? widget.destination.highlights
                              : const [
                                  'Explore the city center',
                                  'Try local food & cafes',
                                  'Visit popular attractions',
                                ])
                          .take(6)
                          .expand((h) => [
                                _buildThingToDoCard(
                                  widget.destination.imageUrl.isNotEmpty
                                      ? widget.destination.imageUrl
                                      : 'https://placehold.co/800x500/png?text=Things+to+do',
                                  h,
                                  widget.destination.country,
                                ),
                                const SizedBox(width: 16),
                              ])
                          .toList()
                        ..removeLast(),
                    ],
                  ),
                ),
                SizedBox(height: 40),

                // Top Hotels
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Top Hotels',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'View All Hotels →',
                          style: TextStyle(
                            color: Color(0xFF1A94C4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      if (_isHotelsLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (_hotelsError != null)
                        Center(child: Text('Failed to load hotels: $_hotelsError'))
                      else if (_hotels.isEmpty)
                        const Center(child: Text('No hotels found for this destination'))
                      else
                        ..._hotels.take(10).expand((h) => [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HotelDetailsScreen(hotel: h),
                                    ),
                                  );
                                },
                                child: _buildHotelCard(
                                  h.imageUrl,
                                  h.name,
                                  h.rating,
                                  '\$${h.price}/night',
                                ),
                              ),
                              const SizedBox(width: 16),
                            ]).toList()
                          ..removeLast(),
                    ],
                  ),
                ),
                SizedBox(height: 48),

                // Customer Gallery
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Visit our customers tour gallery',
                        style: TextStyle(
                          fontSize: 18,
                          
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
                                  160,
                                ),
                                SizedBox(height: 8),
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
                                  120,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1507525428034-b723cf961d3e',
                                  100,
                                ),
                                SizedBox(height: 8),
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1518548419970-58e3b4079812',
                                  180,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
                                  140,
                                ),
                                SizedBox(height: 8),
                                _buildGalleryImage(
                                  'https://images.unsplash.com/photo-1506929562872-bb421503ef21',
                                  140,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 56),

                // Loved By Thousand Travelers
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Loved By Thousand Travelers',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF1A94C4).withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_isReviewsLoading)
                          Center(child: CircularProgressIndicator())
                        else if (_reviews.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No reviews yet for this destination.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        else
                          // For now show the first review or a simpler list since the design is a single card
                          Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(
                                      Icons.star,
                                      color: index < _reviews[0].rating
                                          ? const Color(0xFF1A94C4)
                                          : Colors.grey[300],
                                      size: 28,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  _reviews[0].comment,
                                  style: TextStyle(
                                    color: Color(0xFF4A4A4A),
                                    height: 1.8,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_reviews.isNotEmpty)
                          Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EAF2),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(24),
                                bottomRight: Radius.circular(24),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  child: Icon(Icons.person),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User ${_reviews[0].userId}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Traveler',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60),

                // Call To Action
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 80,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A94C4), Color(0xFF0D1C52)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Ready to Go?',
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Find the best flight deals to ${widget.destination.city},\n${widget.destination.country}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FlightLandingPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0D1C52),
                          padding: EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Search Flights',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Fixed Back Button ─────────────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Theme.of(context).cardColor,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // ── Fixed Favorite Button ─────────────────────────────────────────
          Positioned(
            top: topPadding + 8,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.white,
                  size: 20,
                ),
                onPressed: _toggleFavorite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThingToDoCard(String imageUrl, String title, String subtitle) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(
    String imageUrl,
    String title,
    double rating,
    String price,
  ) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            rating.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  price,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A94C4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryImage(String url, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
    );
  }
}
