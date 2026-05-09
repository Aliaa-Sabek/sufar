import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../ai_planner/ai_planner_screen.dart';
import '../travel_offices/travel_offices_directory.dart';
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

  @override
  void initState() {
    super.initState();
    // Defer fetch after first frame so UI renders immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    const timeout = Duration(seconds: 10);
    try {
      final destsFuture = ApiService.getDestinations(featured: true);
      final officesFuture = ApiService.getTravelOffices(limit: 3);

      final results = await Future.wait([
        destsFuture.timeout(timeout),
        officesFuture.timeout(timeout),
      ]);

      final destsResult = results[0] as List<dynamic>;
      final officesResult = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _destinations.clear();
          _destinations.addAll(
            destsResult.map((e) => DestinationModel.fromJson(e)).toList(),
          );
          _isLoadingDest = false;

          _offices.clear();
          final officeList = officesResult['data'] as List? ?? [];
          _offices.addAll(
            officeList.map((e) => TravelOfficeModel.fromJson(e)).toList(),
          );
          _isLoadingOffices = false;
        });
      }
    } catch (e) {
      // Timeout or network error — show empty state gracefully
      if (mounted) {
        setState(() {
          _isLoadingDest = false;
          _isLoadingOffices = false;
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
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
                        icon: Icon(
                          Icons.chat_bubble_outline,
                          
                          size: 26,
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onNavigateToProfile,
                        icon: Icon(
                          Icons.person_outline,
                          
                          size: 28,
                        ),
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
                            image: DecorationImage(
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
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Content Overlay
                        Positioned.fill(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
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
                                  color: Colors.black.withValues(alpha: 0.1),
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
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  children: [
                                    if (_destinations.isEmpty)
                                      Center(
                                        child: Text('No destinations found'),
                                      )
                                    else
                                      ..._destinations.map(
                                        (dest) => _buildDestinationCard(
                                          context,
                                          dest.imageUrl,
                                          dest.name,
                                          dest.description,
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
                            Center(child: CircularProgressIndicator())
                          else if (_offices.isEmpty)
                            Center(child: Text('No travel offices found'))
                          else
                            ..._offices.map(
                              (office) => Padding(
                                padding: EdgeInsets.only(bottom: 16),
                                child: _buildOfficeCard(
                                  context,
                                  office.name,
                                  office.city ?? 'Unknown',
                                  office.rating ?? 0.0,
                                  office.reviewsCount ?? 0,
                                ),
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
                              color: Theme.of(context).cardColor.withValues(alpha: 0.1),
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
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(
    BuildContext context,
    String imageUrl,
    String title,
    String description,
  ) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0).withValues(alpha: 0.3),
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
                : (imageUrl.startsWith('http')
                      ? Image.network(
                          imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 220,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.landscape,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                      : Image.asset(
                          imageUrl,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 220,
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.landscape,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                        )),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      
                    ),
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

  Widget _buildOfficeCard(
    BuildContext context,
    String name,
    String location,
    double rating,
    int reviews,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A94C4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.business,
                  color: Color(0xFF1A94C4),
                  size: 32,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey,
              ),
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
                    builder: (context) => const TravelOfficesDirectory(),
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
