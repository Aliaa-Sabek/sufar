import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/destination_catalog_service.dart';
import '../services/image_service.dart';
import '../ai_planner/ai_planner_screen.dart';
import '../travel_offices/travel_offices_directory.dart';
import '../travel_offices/office_details_screen.dart';
import '../destinations/destinations_screen.dart';
import '../models/destination_model.dart';
import '../models/travel_office_model.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToDestinations;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToFlights;

  const HomeScreen({
    super.key,
    required this.onNavigateToDestinations,
    required this.onNavigateToProfile,
    required this.onNavigateToChat,
    required this.onNavigateToFlights,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DestinationModel> _destinations = [];
  final List<TravelOfficeModel> _offices = [];
  bool _isLoadingDest = true;
  bool _isLoadingOffices = true;
  String? _loadError;
  String? _officesError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDestinations();
      _fetchOffices();
    });
  }

  Future<void> _fetchDestinations() async {
    setState(() => _loadError = null);
    try {
      final featured = await DestinationCatalogService.featuredDestinations();
      if (mounted) {
        setState(() {
          _destinations
            ..clear()
            ..addAll(featured);
          _isLoadingDest = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDest = false;
          _loadError = e.toString();
        });
      }
    }
  }

  Future<void> _fetchOffices() async {
    setState(() {
      _isLoadingOffices = true;
      _officesError = null;
    });
    try {
      final offices = await ApiService.fetchTravelOffices(limit: 6);
      if (!mounted) return;
      setState(() {
        _offices
          ..clear()
          ..addAll(offices.take(6));
        _isLoadingOffices = false;
      });
    } catch (e) {
      debugPrint('[HomeScreen] Travel offices failed: $e');
      if (mounted) {
        setState(() {
          _isLoadingOffices = false;
          _officesError = 'Could not load travel offices';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Navigation Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left Side: Logo
                  Image.asset(
                    'assets/Sufar Logo Blue.png',
                    height: 35,
                    fit: BoxFit.contain,
                  ),
                  // Right Icons: Chat & Profile
                  Row(
                    children: [
                      IconButton(
                        onPressed: widget.onNavigateToChat,
                        icon: Icon(Icons.chat_bubble_outline, size: 26),
                      ),
                      IconButton(
                        onPressed: widget.onNavigateToProfile,
                        icon: Icon(Icons.person_outline, size: 28),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Hero Section
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background Image
                        Container(
                          height: size.height * 0.45,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: const DecorationImage(
                              image: AssetImage('assets/home_bg.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Content Overlay
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                // Hero Text
                                Text(
                                  'Plan Your Journey\nSmarter with sufar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Discover destinations, book flights & hotels, get AI-\npowered recommendations, and connect with\ntrusted travel offices',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 24),

                                // Hero Buttons
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final startPlanningButton = ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AIPlannerPage(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1A94C4,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        minimumSize: const Size(140, 48),
                                      ),
                                      child: Text(
                                        'Start Planning',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );

                                    final exploreButton = ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const DestinationsScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF0D1C52,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        minimumSize: const Size(140, 48),
                                      ),
                                      child: Text(
                                        'Explore Destinations',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(child: startPlanningButton),
                                        SizedBox(width: 12),
                                        Expanded(child: exploreButton),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Floating Search Card
                        Positioned(
                          bottom: -35,
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 70,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Where to?',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.black12,
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      'Travel date',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: widget.onNavigateToFlights,
                                  icon: Icon(Icons.search, size: 20),
                                  label: Text(
                                    'Search',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A94C4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    elevation: 0,
                                    minimumSize: const Size(0, double.infinity),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacer for floating card
                  const SliverToBoxAdapter(child: SizedBox(height: 60)),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),

                  // Why Choose sufar Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Text(
                            'Why Choose sufar',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Everything you need for the perfect trip',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                          SizedBox(height: 48),
                          _buildFeatureItem(
                            icon: Icons.auto_awesome_outlined,
                            title: 'AI Travel Planner',
                            description:
                                'Get personalized itineraries powered by AI',
                          ),
                          SizedBox(height: 48),
                          _buildFeatureItem(
                            icon: Icons.business_outlined,
                            title: 'Trusted Travel Offices',
                            description:
                                'Connect with verified and rated travel agencies',
                          ),
                          SizedBox(height: 48),
                          _buildFeatureItem(
                            icon: Icons.flight_takeoff_outlined,
                            title: 'Hotel & Flight Comparison',
                            description:
                                'Find the best deals across multiple platforms',
                          ),
                          SizedBox(height: 48),
                          _buildFeatureItem(
                            icon: Icons.description_outlined,
                            title: 'Visa Advice & Requirements',
                            description:
                                'Know visa requirements for any destination',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),

                  // Top Destinations Section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              Text(
                                'Top Destinations',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Discover the world's most amazing places",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),
                        SizedBox(
                          height: 420,
                          child: _isLoadingDest
                              ? Center(child: CircularProgressIndicator())
                              : ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                  children: [
                                    if (_loadError != null)
                                      Center(
                                        child: Text(
                                          'Failed to load: $_loadError',
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    else if (_destinations.isEmpty)
                                      Center(
                                        child: Text('No destinations found'),
                                      )
                                    else
                                      ..._destinations.map(
                                        (dest) => _buildDestinationCard(
                                          context,
                                          dest.coverImageUrl,
                                          dest.name,
                                          dest.description,
                                          citySlug: dest.slug,
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 80)),

                  // Explore Travel Offices Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Explore Travel Offices',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Connect with trusted travel professionals',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TravelOfficesDirectory(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View All →',
                                  style: TextStyle(
                                    color: Color(0xFF1A94C4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32),
                          if (_isLoadingOffices)
                            const SizedBox(
                              height: 220,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_officesError != null)
                            Column(
                              children: [
                                Text(
                                  _officesError!,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextButton(
                                  onPressed: _fetchOffices,
                                  child: const Text('Retry'),
                                ),
                              ],
                            )
                          else if (_offices.isEmpty)
                            Center(
                              child: Text(
                                'No travel offices found',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            SizedBox(
                              height: 300,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                itemCount: _offices.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final office = _offices[index];
                                  return SizedBox(
                                    width: 300,
                                    child: _buildOfficeCard(
                                      context,
                                      office,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 60)),

                  // Bottom CTA
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.symmetric(
                        vertical: 40,
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).cardColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: Theme.of(context).cardColor,
                              size: 28,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Let AI Plan Your Perfect Trip',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Get personalized recommendations,\noptimized itineraries, and smart travel tips\npowered by artificial intelligence',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.4,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AIPlannerPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFE0E0),
                              foregroundColor: const Color(0xFF0D1C52),
                              padding: EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Ask Sufar AI',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F7FA),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, size: 40, color: const Color(0xFF1A94C4)),
        ),
        SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String imageUrl,
    String title,
    String description, {
    String? citySlug,
  }) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0).withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            child: imageUrl.isEmpty
                ? Container(
                    height: 220,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  )
                : SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: ImageService.buildNetworkCover(
                      imageUrl: imageUrl,
                      citySlug: citySlug,
                      cityName: title,
                      type: 'destination',
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DestinationsScreen(),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View Details →',
                      style: TextStyle(
                        color: Color(0xFF1A94C4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeCard(BuildContext context, TravelOfficeModel office) {
    final name = office.name;
    final location = office.city ?? office.country ?? 'Unknown';
    final rating = office.rating ?? 0.0;
    final reviews = office.reviewsCount ?? 0;
    final imageUrl = office.logoUrl ?? office.imageUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0).withOpacity(0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A94C4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  image: imageUrl != null && imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: imageUrl.startsWith('http')
                              ? NetworkImage(imageUrl)
                              : AssetImage(imageUrl) as ImageProvider,
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {
                            debugPrint(
                              'Failed to load office image: $imageUrl',
                            );
                          },
                        )
                      : null,
                ),
                child: imageUrl == null || imageUrl.isEmpty
                    ? Icon(Icons.business, color: Color(0xFF1A94C4), size: 32)
                    : null,
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0D0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            name,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(location, style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '$reviews reviews',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OfficeDetailsPage(officeData: office),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'View Profile',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
