import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../models/travel_office_model.dart';
import '../ai_planner/ai_planner_screen.dart';
import '../travel_offices/travel_offices_directory.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToChat;
  final VoidCallback onNavigateToFlights;

  HomeScreen({
    super.key,
    required this.onNavigateToServices,
    required this.onNavigateToProfile,
    required this.onNavigateToChat,
    required this.onNavigateToFlights,
  });

  // Dummy Data for UI - Moving away from static widget tree
  final List<DestinationModel> _topDestinations = [
    const DestinationModel(
      id: '1',
      title: 'Bali, Indonesia',
      description: 'Tropical paradise with stunning beaches and rich culture',
      imageUrl: 'https://images.unsplash.com/photo-1537996194471-e657df975ab4',
      rating: 4.8,
    ),
    const DestinationModel(
      id: '2',
      title: 'Swiss Alps',
      description: 'Majestic mountains and pristine scenery',
      imageUrl: 'https://images.unsplash.com/photo-1531366936337-7c912a4589a7',
      rating: 4.9,
    ),
    const DestinationModel(
      id: '3',
      title: 'Paris, France',
      description: 'City of lights, love, and endless beauty',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34',
      rating: 4.7,
    ),
  ];

  final List<TravelOfficeModel> _featuredOffices = [
    const TravelOfficeModel(
      id: '1',
      name: 'Global Wanderlust',
      location: 'New York, USA',
      rating: 4.8,
      reviews: 1250,
      icon: Icons.business,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Custom Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    // Logo
                    GestureDetector(
                      onTap: () {},
                      child: Image.asset(
                        'assets/Sufar Logo Blue.png',
                        height: 40,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.route,
                              color: Color(0xFF1A94C4),
                              size: 24,
                            ),
                            Text(
                              'Sufar',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Center Menu Icon (Three lines) -> Services
                    IconButton(
                      onPressed: onNavigateToServices,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black87, width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Right Icons: Chat & Profile
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onNavigateToChat,
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF0D1C52),
                            size: 26,
                          ),
                        ),
                        IconButton(
                          onPressed: onNavigateToProfile,
                          icon: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF0D1C52),
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                          height: 400,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1506744038136-46273834b3fb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80',
                              ),
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
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                // Hero Text
                                const Text(
                                  'Plan Your Journey\nSmarter with Sufar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Discover destinations, book flights & hotels, get AI-\npowered recommendations, and connect with\ntrusted travel offices',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Hero Buttons
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AIPlannerPage(),
                                          ),
                                        );
                                      }, // 'Start Planning'
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF1A94C4,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Start Planning'),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed:
                                          onNavigateToServices, // "Explore Destinations"
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: const Color(
                                          0xFF0D1C52,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Explore Destinations'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Floating Search Card
                        Positioned(
                          bottom: -30,
                          left: 24,
                          right: 24,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE0E0),
                              borderRadius: BorderRadius.circular(12),
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
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.black12,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      'Where to?',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: const Text(
                                      'Travel date',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: onNavigateToFlights,
                                  icon: const Icon(Icons.search, size: 16),
                                  label: const Text('Search'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A94C4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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

                  // Why Choose Sufar Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Why Choose Sufar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1C52),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Everything you need for the perfect trip',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Features Grid
                          _buildFeatureItem(
                            icon: Icons.auto_awesome,
                            title: 'AI Travel Planner',
                            description:
                                'Get personalized itineraries powered by AI',
                            color: Colors.blue[100]!,
                            iconColor: Colors.blue,
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            icon: Icons.store,
                            title: 'Trusted Travel Offices',
                            description:
                                'Connect with verified and rated travel agencies',
                            color: Colors.orange[100]!,
                            iconColor: Colors.orange,
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            icon: Icons.flight_takeoff,
                            title: 'Hotel & Flight Comparison',
                            description:
                                'Find the best deals across multiple platforms',
                            color: Colors.purple[100]!,
                            iconColor: Colors.purple,
                          ),
                          const SizedBox(height: 24),
                          _buildFeatureItem(
                            icon: Icons.article_outlined,
                            title: 'Visa Advice & Requirements',
                            description:
                                'Know visa requirements for any destination',
                            color: Colors.teal[100]!,
                            iconColor: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // Top Destinations
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const Text(
                          'Top Destinations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1C52),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Discover the world's most amazing places",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 320,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: _topDestinations.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final destination = _topDestinations[index];
                              return _buildDestinationCard(destination);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // Explore Travel Offices
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const Text(
                          'Explore Travel Offices',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D1C52),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Connect with trusted travel professionals',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TravelOfficesDirectory(),
                                  ),
                                );
                              },
                              child: const Text('View All Offices ->'),
                            ),
                          ),
                        ),
                        // List of offices
                        ..._featuredOffices.map(
                          (office) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 8.0,
                            ),
                            child: _buildOfficeCard(office),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 40)),

                  // Bottom CTA
                  SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(
                        vertical: 48,
                        horizontal: 24,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A94C4), Color(0xFF0D1C52)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Let AI Plan Your Perfect Trip',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Get personalized recommendations,\noptimized itineraries, and smart travel tips\npowered by artificial intelligence',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Ask Sufar AI'),
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
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: iconColor, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A94C4),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 220,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard(DestinationModel destination) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                image: DecorationImage(
                  image: NetworkImage(destination.imageUrl ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF0D1C52),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  destination.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Color(0xFF1A94C4),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF1A94C4),
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

  Widget _buildOfficeCard(TravelOfficeModel office) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.pink.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A94C4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  office.icon ?? Icons.business,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      office.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  office.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1C52),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      office.location,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${office.reviews} reviews',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('View Profile'),
            ),
          ),
        ],
      ),
    );
  }
}
