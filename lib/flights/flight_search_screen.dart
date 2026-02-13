import 'package:flutter/material.dart';
import 'flight_landing_screen.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find Your Flight',
                style: TextStyle(
                  color: Color(0xFF1A94C4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputGroup(
                            'From',
                            'New York',
                            Icons.flight_takeoff,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'To',
                            'Dubai',
                            Icons.flight_land,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'Date',
                            'mm/dd/yyyy',
                            Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'Travelers',
                            '1 Traveller',
                            Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A94C4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Search Flights',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                '6 flights found',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final flights = [
                    {
                      'airline': 'Singapore Airlines',
                      'logo': Icons.flight,
                      'departureTime': '11:00 PM',
                      'departureAirport': 'Los Angeles (LAX)',
                      'duration': '17h 30m',
                      'stops': 'Non-stop',
                      'arrivalTime': '6:30 AM +2',
                      'arrivalAirport': 'Singapore (SIN)',
                      'price': '\$920',
                    },
                    {
                      'airline': 'Qatar Airways',
                      'logo': Icons.flight,
                      'departureTime': '8:15 PM',
                      'departureAirport': 'London (LHR)',
                      'duration': '22h 25m',
                      'stops': '1 stop',
                      'arrivalTime': '5:40 PM +1',
                      'arrivalAirport': 'Sydney (SYD)',
                      'price': '\$1100',
                    },
                    {
                      'airline': 'Air France',
                      'logo': Icons.flight,
                      'departureTime': '1:45 PM',
                      'departureAirport': 'Paris (CDG)',
                      'duration': '8h 35m',
                      'stops': 'Non-stop',
                      'arrivalTime': '4:20 PM',
                      'arrivalAirport': 'New York (JFK)',
                      'price': '\$680',
                    },
                    {
                      'airline': 'Cathay Pacific',
                      'logo': Icons.flight,
                      'departureTime': '4:20 PM',
                      'departureAirport': 'Hong Kong (HKG)',
                      'duration': '12h 35m',
                      'stops': 'Non-stop',
                      'arrivalTime': '12:55 PM',
                      'arrivalAirport': 'San Francisco (SFO)',
                      'price': '\$795',
                    },
                    {
                      'airline': 'Lufthansa',
                      'logo': Icons.flight,
                      'departureTime': '9:50 AM',
                      'departureAirport': 'Frankfurt (FRA)',
                      'duration': '11h 35m',
                      'stops': 'Non-stop',
                      'arrivalTime': '5:25 AM +1',
                      'arrivalAirport': 'Tokyo (NRT)',
                      'price': '\$850',
                    },
                  ];

                  return _buildFlightCard(context, flights[index]);
                },
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4B88),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Compare Multiple Flights',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select up to 3 flights to compare prices, schedules, and amenities',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
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
                        foregroundColor: const Color(0xFF0D4B88),
                      ),
                      child: const Text('Go to Comparison Tool'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1A94C4)),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightCard(BuildContext context, Map<String, dynamic> flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.flight,
              color: Color(0xFF1A94C4),
            ), // Placeholder
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['airline'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Non-stop',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['departureTime'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      flight['departureAirport'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                Column(
                  children: [
                    const Icon(
                      Icons.flight_takeoff,
                      size: 16,
                      color: Color(0xFF1A94C4),
                    ),
                    Container(height: 1, width: 60, color: Colors.grey[300]),
                    Text(
                      flight['duration'],
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['arrivalTime'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      flight['arrivalAirport'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'From',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    Text(
                      flight['price'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF0D1C52),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Select Flight',
                        style: TextStyle(color: Colors.white, fontSize: 12),
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
