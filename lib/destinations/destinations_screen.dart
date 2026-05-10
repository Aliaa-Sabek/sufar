import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/destination_model.dart';
import 'destination_details_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final List<DestinationModel> _destinations = [];
  bool _isLoading = true;
  String? _errorMessage;



  @override
  void initState() {
    super.initState();
    _fetchDestinations();
  }

  Future<void> _fetchDestinations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getDestinations();
      if (mounted) {
        setState(() {
          _destinations.clear();
          _destinations.addAll(
            response.map((json) => DestinationModel.fromJson(json)).toList(),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header Section
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/all_tours.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'All ',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'Tours',
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).cardColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
          // Our Featured Tours Section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Our Featured Destinations',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 24),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    Center(child: Text('Error: $_errorMessage'))
                  else if (_destinations.isEmpty)
                    Center(child: Text('No destinations found'))
                  else
                    ..._buildDynamicTourPatterns(),
                  SizedBox(height: 32),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),

          // The Best Holidays Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Vacation Ag',
                  style: GoogleFonts.greatVibes(
                    fontSize: 24,
                    
                  ),
                ),
                Text(
                  'The Best Holidays',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  height: 320,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      if (_isLoading)
                        Center(child: CircularProgressIndicator())
                      else if (_destinations.isEmpty)
                        Center(child: Text('No destinations found'))
                      else
                        ..._destinations
                            .take(4)
                            .map(
                              (dest) => Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: _buildHolidayCard(context, dest),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),

          // Categories Section (Vip Beaches, etc)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryItem(
                        icon: Icons.beach_access,
                        title: 'Vip Beaches',
                        description:
                            'No one shall be subjected to arbitrary arrest, detention or exile. Everyone',
                      ),
                      SizedBox(width: 24),
                      _buildCategoryItem(
                        icon: Icons.landscape,
                        title: 'Mountain Walks',
                        description:
                            'No one shall be subjected to arbitrary arrest, detention or exile. Everyone',
                      ),
                    ],
                  ),
                  SizedBox(height: 48),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryItem(
                        icon: Icons.directions_boat,
                        title: 'Luxury Yachts',
                        description:
                            'No one shall be subjected to arbitrary arrest, detention or exile. Everyone',
                      ),
                      SizedBox(width: 24),
                      _buildCategoryItem(
                        icon: Icons.terrain,
                        title: 'Recreational Camps',
                        description:
                            'No one shall be subjected to arbitrary arrest, detention or exile. Everyone',
                      ),
                    ],
                  ),
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicTourPatterns() {
    List<Widget> widgets = [];
    for (int i = 0; i < _destinations.length; i += 5) {
      int remaining = _destinations.length - i;
      if (remaining >= 5) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: _buildTourPattern(
              context,
              large1: _destinations[i],
              large2: _destinations[i + 1],
              small1: _destinations[i + 2],
              small2: _destinations[i + 3],
              small3: _destinations[i + 4],
            ),
          ),
        );
      } else if (remaining >= 2) {
        widgets.add(
          Row(
            children: [
              Expanded(
                child: _buildTourCard(
                  context: context,
                  destination: _destinations[i],
                  height: 200,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTourCard(
                  context: context,
                  destination: _destinations[i + 1],
                  height: 200,
                ),
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          _buildTourCard(
            context: context,
            destination: _destinations[i],
            height: 200,
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildTourPattern(
    BuildContext context, {
    required DestinationModel large1,
    required DestinationModel large2,
    required DestinationModel small1,
    required DestinationModel small2,
    required DestinationModel small3,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTourCard(
                context: context,
                destination: large1,
                height: 200,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTourCard(
                context: context,
                destination: large2,
                height: 200,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTourCard(
                context: context,
                destination: small1,
                height: 100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTourCard(
                context: context,
                destination: small2,
                height: 100,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTourCard(
                context: context,
                destination: small3,
                height: 100,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTourCard({
    required BuildContext context,
    required DestinationModel destination,
    required double height,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DestinationDetailsScreen(destination: destination),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          image: destination.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: destination.imageUrl.startsWith('http')
                      ? NetworkImage(destination.imageUrl)
                      : AssetImage(destination.imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              stops: const [0.0, 0.5],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  destination.name,
                  textAlign: TextAlign.center,
                  style: AppFonts.destinationTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  destination.country.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppFonts.destinationSubtitle,
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context, DestinationModel destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DestinationDetailsScreen(destination: destination),
          ),
        );
      },
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
          image: destination.imageUrl.isNotEmpty
              ? DecorationImage(
                  image: destination.imageUrl.startsWith('http')
                      ? NetworkImage(destination.imageUrl)
                      : AssetImage(destination.imageUrl) as ImageProvider,
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      
                    ),
                    SizedBox(width: 4),
                    Text(
                      destination.city,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: Colors.black),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
