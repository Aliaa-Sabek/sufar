import 'package:flutter/material.dart';
import 'flight_search_screen.dart';

class FlightLandingPage extends StatefulWidget {
  const FlightLandingPage({super.key});

  @override
  State<FlightLandingPage> createState() => _FlightLandingPageState();
}

class _FlightLandingPageState extends State<FlightLandingPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _returnController = TextEditingController();
  final TextEditingController _travelersController = TextEditingController(
    text: '1 Adult, Economy',
  );

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _travelersController.dispose();
    super.dispose();
  }

  void _searchFlights() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FlightSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Select flight',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/Sufar Logo Blue.png',
              height: 24,
              errorBuilder: (c, e, s) =>
                  Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Background Image
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  color: Colors.blue[100],
                  child: Image.asset(
                    'assets/flights_bg.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.blue[200]),
                  ),
                ),
                // Dark overlay
                Container(height: 400, color: Colors.black.withOpacity(0.3)),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Hey Buddy! Where are you',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Flying to?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Search Form Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Trip Type Selector
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Radio(
                                value: true,
                                groupValue: true,
                                onChanged: (val) {},
                              ),
                              Text('Return', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Radio(
                                value: false,
                                groupValue: true,
                                onChanged: (val) {},
                              ),
                              Text('One Way', style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Checkbox(value: false, onChanged: (val) {}),
                              Text(
                                'Direct Flights',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // From and To Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            'From',
                            'Egypt - Cairo (CAI)',
                            Icons.flight_takeoff,
                            _fromController,
                          ),
                        ),
                        SizedBox(width: 12),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.swap_horiz,
                            color: Color(0xFF1A94C4),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            'To',
                            'Country, City or Airport',
                            Icons.flight_land,
                            _toController,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Date Fields
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            'Departure',
                            '14/02/2025',
                            Icons.calendar_today,
                            _departureController,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildInputField(
                            'Return',
                            '21/01/2025',
                            Icons.calendar_today,
                            _returnController,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Travelers Field
                    _buildInputField(
                      'Travelers and Cabin Class',
                      '1 Adult, Economy',
                      Icons.person_outline,
                      _travelersController,
                    ),

                    SizedBox(height: 24),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _searchFlights,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D1C52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Search Flights',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40),

            // Why Travel Cart Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Travel Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.shield_rounded,
                          title: 'ATOL Protected Flights',
                          subtitle: 'Your booking is financially protected',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.check_circle_rounded,
                          title: 'Best Prices Guarantee',
                          subtitle: 'We match any lower price',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            // Destination Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Popular Destinations',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDestinationCard(
                          context,
                          'Cape Town,\nSouth Africa',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildDestinationCard(context, 'Paris,\nFrance'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[400]),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Color(0xFF1A94C4)),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A94C4),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
           Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFF1565C0),
              child: Icon(Icons.location_on, color: Colors.white54, size: 48),
            ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D1C52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: Text('Book Now', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
