import 'package:flutter/material.dart';

import '../models/destination_model.dart';
import '../models/review_model.dart';
import '../flights/flight_landing_screen_v2.dart';
import '../models/hotel_model.dart';
import '../services/api_service.dart';
import '../services/destination_catalog_service.dart';
import '../hotels/hotel_details_screen.dart';
import '../services/image_service.dart';

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

  List<String> _galleryImages = [];
  late DestinationModel _destination;
  bool _activitiesLoading = true;

  @override
  void initState() {
    super.initState();
    _destination = widget.destination;
    _fetchReviews();
    _checkIfFavorited();
    _fetchHotels();
    _loadDestinationWithActivities();
  }

  /// Deduplicate by title — NOT by imageUrl, since multiple activities
  /// may legitimately share a category fallback image.
  List<ActivityModel> _dedupeActivities(List<ActivityModel> activities) {
    final seen = <String>{};
    final out = <ActivityModel>[];
    for (final a in activities) {
      final key = a.title.trim().toLowerCase();
      if (key.isEmpty || seen.add(key)) out.add(a);
    }
    return out;
  }

  Future<void> _loadDestinationWithActivities() async {
    setState(() => _activitiesLoading = true);

    try {
      final slug = _destination.slug.isNotEmpty
          ? _destination.slug
          : DestinationCatalogService.toSlug(_destination.name);

      final detail = await DestinationCatalogService.destinationDetailFromApi(
        slug: slug,
        name: _destination.name,
      );

      final catalog = detail.destination;
      if (catalog == null) {
        if (mounted) setState(() => _activitiesLoading = false);
        return;
      }

      final activities = _dedupeActivities(catalog.activities);

      if (mounted) {
        setState(() {
          _destination = DestinationModel(
            id: _destination.id.isNotEmpty
                ? _destination.id
                : (catalog.id.isNotEmpty ? catalog.id : catalog.slug),
            name: catalog.name,
            nameAr: catalog.nameAr,
            slug: catalog.slug,
            country: catalog.country,
            countryAr: catalog.countryAr,
            region: catalog.region,
            description: catalog.description,
            highlights: catalog.highlights,
            imageUrl: catalog.imageUrl,
            images: catalog.images,
            isFeatured: catalog.isFeatured,
            activities: activities,
          );
          if (detail.topHotels.isNotEmpty && _hotels.isEmpty) {
            _hotels.addAll(detail.topHotels);
          }
          _activitiesLoading = false;
          _rebuildCityMedia();
        });
      }
    } catch (e) {
      debugPrint('[DestinationDetails] Failed to load activities: $e');
      if (mounted) {
        setState(() => _activitiesLoading = false);
      }
    }
  }

  /// Gallery: city hero + distinct activity + hotel shots (no duplicate pile).
  List<String> _buildCityMediaPool() {
    final seen = <String>{};
    final pool = <String>[];

    void add(String? raw, {String? type, String? hotelSlug}) {
      if (raw == null || raw.trim().isEmpty) return;
      final url = ImageService.urlForWidget(
        raw,
        citySlug: _destination.slug,
        cityName: _destination.name,
        type: type,
        hotelSlug: hotelSlug,
      );
      if (url.isNotEmpty && seen.add(ImageService.dedupeKey(url))) {
        pool.add(url);
      }
    }

    add(_destination.imageUrl, type: 'destination');

    var activitySlots = 0;
    for (final activity in _destination.activities) {
      if (activitySlots >= 4 || pool.length >= 6) break;
      final before = pool.length;
      add(activity.imageUrl, type: 'activity');
      if (pool.length > before) activitySlots++;
    }

    for (final hotel in _hotels) {
      if (pool.length >= 6) break;
      final thumb = hotel.generalImages.isNotEmpty
          ? hotel.generalImages.first
          : hotel.imageUrl;
      add(thumb, type: 'hotel');
    }

    return pool;
  }

  void _rebuildCityMedia() {
    _galleryImages = _buildCityMediaPool();
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
    // Add realistic dummy reviews since backend might not provide them
    _reviews.addAll([
      Review(
        id: 1,
        targetId: 1,
        targetType: 'destination',
        userId: 'John Doe',
        rating: 5,
        comment:
            'Absolutely stunning! The experiences were unforgettable and the locals were very friendly.',
        createdAt: DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      ),
      Review(
        id: 2,
        targetId: 1,
        targetType: 'destination',
        userId: 'Sarah Smith',
        rating: 4,
        comment:
            'Great place for a vacation. Highly recommended for couples and families alike.',
        createdAt: DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      ),
    ]);
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
      final res = await ApiService.getHotels(
        city: _destination.name,
        limit: 8,
      );
      
      List? hotelsRaw;
      final raw = res['hotels'] ?? res['data'] ?? res['results'] ?? res['items'];
      if (raw is List) {
        hotelsRaw = raw;
      } else if (raw is Map && raw.values.any((v) => v is List)) {
        hotelsRaw = raw.values.firstWhere((v) => v is List, orElse: () => null) as List?;
      }

      final results = <Hotel>[];
      if (hotelsRaw != null) {
        for (final item in hotelsRaw) {
          if (item is! Map) continue;
          try {
            results.add(
              Hotel.fromJson(Map<String, dynamic>.from(item)),
            );
          } catch (e) {
            debugPrint('[DestinationDetails] Skip hotel parse: $e');
          }
        }
      }
      if (mounted) {
        setState(() {
          if (results.isNotEmpty) {
            _hotels
              ..clear()
              ..addAll(results);
          }
          _isHotelsLoading = false;
          _rebuildCityMedia();
        });
      }
    } catch (e) {
      debugPrint('[DestinationDetails] _fetchHotels error: $e');
      if (mounted) {
        setState(() {
          _isHotelsLoading = false;
          if (_hotels.isEmpty) {
            _hotelsError = e.toString();
          }
          _rebuildCityMedia();
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
                        image: _destination.coverImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: ImageService.getNetworkImage(
                                  _destination.coverImageUrl,
                                  type: 'destination',
                                  citySlug: _destination.slug,
                                  cityName: _destination.name,
                                ),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  debugPrint(
                                    'Failed to load destination header image: ${_destination.imageUrl}',
                                  );
                                },
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
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
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
                            '${_destination.city}, ${_destination.country}',
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _destination.name,
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About ${_destination.name}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          _destination.description,
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

                // Things to Do (Dynamic Image Cards)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Things to Do',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: _activitiesLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _destination.activities.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'No activities available for ${_destination.name} yet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: _destination.activities.length,
                          itemBuilder: (context, index) {
                            final activity = _destination.activities[index];

                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ImageService.buildNetworkImage(
                                      imageUrl: activity.imageUrl,
                                      width: 220,
                                      height: 250,
                                      fit: BoxFit.cover,
                                      type: 'activity',
                                    ),
                                  // Dark gradient overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.3),
                                          Colors.black.withValues(alpha: 0.85),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Text content
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          activity.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (activity.description.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              activity.description,
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.75,
                                                ),
                                                fontSize: 10,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            );
                          },
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
                        Center(
                          child: Text('Failed to load hotels: $_hotelsError'),
                        )
                      else if (_hotels.isEmpty)
                        const Center(
                          child: Text('No hotels found for this destination'),
                        )
                      else
                        ..._hotels
                            .take(10)
                            .expand(
                              (h) => [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HotelDetailsScreen(hotel: h),
                                      ),
                                    );
                                  },
                                  child: _buildHotelCard(
                                    h.generalImages.isNotEmpty
                                        ? h.generalImages.first
                                        : h.imageUrl.isNotEmpty
                                            ? h.imageUrl
                                            : '',
                                    h.name,
                                    h.rating,
                                    h.price > 0
                                        ? '\$${h.price}/night'
                                        : 'Price on request',
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ],
                            )
                            .toList()
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
                      _buildGalleryGrid(),
                    ],
                  ),
                ),
                SizedBox(height: 56),

                // Loved By Thousand Travelers
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Loved By Thousand Travelers',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                        color: const Color(0xFF1A94C4).withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                  padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
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
                        'Find the best flight deals to ${_destination.city},\n${_destination.country}',
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
                color: Colors.black.withValues(alpha: 0.35),
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
                color: Colors.black.withValues(alpha: 0.35),
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

  List<String> get _galleryDisplayImages =>
      _galleryImages.take(6).toList();

  Widget _buildGalleryGrid() {
    final images = _galleryDisplayImages;
    if (images.isEmpty) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text(
          'Photos will appear when hotels load for ${_destination.name}',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    final heights = [160.0, 120.0, 100.0, 180.0, 140.0, 140.0];
    String? at(int i) => i < images.length ? images[i] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              if (at(0) != null) _buildGalleryImage(at(0)!, heights[0]),
              if (at(0) != null && at(1) != null) const SizedBox(height: 8),
              if (at(1) != null) _buildGalleryImage(at(1)!, heights[1]),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              if (at(2) != null) _buildGalleryImage(at(2)!, heights[2]),
              if (at(2) != null && at(3) != null) const SizedBox(height: 8),
              if (at(3) != null) _buildGalleryImage(at(3)!, heights[3]),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              if (at(4) != null) _buildGalleryImage(at(4)!, heights[4]),
              if (at(4) != null && at(5) != null) const SizedBox(height: 8),
              if (at(5) != null) _buildGalleryImage(at(5)!, heights[5]),
            ],
          ),
        ),
      ],
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: ImageService.buildNetworkImage(
              imageUrl: imageUrl,
              width: 250,
              height: 140,
              fit: BoxFit.cover,
              type: 'hotel',
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
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 14),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ImageService.buildNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
