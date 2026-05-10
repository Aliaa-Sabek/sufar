import 'package:flutter/material.dart';

class FlightLandingPage extends StatelessWidget {
  const FlightLandingPage({super.key});

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
            // Hero Section
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.blue[100],
                  child: Image.network(
                    'https://placehold.co/800x400/png?text=Plane+Sky',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: Colors.blue[100]),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.flight,
                                color: Color(0xFF1A94C4),
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Emirates',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Non-stop',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '10:30 AM',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'New York (JFK)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 60,
                          child: Column(
                            children: [
                              Icon(
                                Icons.flight_takeoff,
                                size: 16,
                                color: Color(0xFF1A94C4),
                              ),
                              Container(height: 1, color: Colors.grey[300]),
                              Text(
                                '14h 15m',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '6:45 PM',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Dubai (DXB)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: const [
                            Text(
                              'From',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '\$850',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              color: Colors.blue[50],
              child: Column(
                children: const [
                  Text(
                    'Comprehensive Flight\nOptions For Every Budget.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildDestinationCard(context, 'Cape Town, South Africa'),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDestinationCard(context, 'Cape Town, South Africa'),
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

  Widget _buildDestinationCard(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A94C4),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.network(
            'https://placehold.co/400x300/png?text=Destination',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(height: 150, color: Colors.blue[200]),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'The City of Lights is calling! Discover iconic landmarks like the Eiffel Tower, world-class museums, and romantic streets.',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0D1C52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Book Now'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
