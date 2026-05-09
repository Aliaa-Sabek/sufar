import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/flight_model.dart';
import 'flight_landing_screen.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  List<FlightModel> _flights = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  // Fallback demo data for when API has no results
  static final List<Map<String, dynamic>> _demoFlights = [
    {
      'airline': 'Singapore Airlines',
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
      'departureTime': '9:50 AM',
      'departureAirport': 'Frankfurt (FRA)',
      'duration': '11h 35m',
      'stops': 'Non-stop',
      'arrivalTime': '5:25 AM +1',
      'arrivalAirport': 'Tokyo (NRT)',
      'price': '\$850',
    },
  ];

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
      _flights = [];
    });

    try {
      final results = await ApiService.searchFlights(
        from: _fromController.text.trim().isEmpty ? null : _fromController.text.trim(),
        to: _toController.text.trim().isEmpty ? null : _toController.text.trim(),
        date: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _flights = results.map((e) => FlightModel.fromJson(e)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to search flights: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find Your Flight',
                style: TextStyle(
                  color: Color(0xFF1A94C4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 24),

              // Search Form
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
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
                            'e.g. Cairo',
                            Icons.flight_takeoff,
                            controller: _fromController,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'To',
                            'e.g. Dubai',
                            Icons.flight_land,
                            controller: _toController,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'Date',
                            'YYYY-MM-DD',
                            Icons.calendar_today,
                            controller: _dateController,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildInputGroup(
                            'Travelers',
                            '1 Traveller',
                            Icons.person_outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _searchFlights,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A94C4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).cardColor,
                                ),
                              )
                            : Text(
                                'Search Flights',
                                style: TextStyle(color: Theme.of(context).cardColor, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              // Results or demo
              if (_hasSearched && !_isLoading) ...[
                Text(
                  _flights.isEmpty
                      ? 'No flights found — showing sample flights'
                      : '${_flights.length} flight${_flights.length != 1 ? 's' : ''} found',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                if (_flights.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _flights.length,
                    itemBuilder: (context, index) {
                      final f = _flights[index];
                      final dep = f.departureDatetime;
                      final arr = f.arrivalDatetime;
                      final flightData = {
                        'airline': f.airline,
                        'departureTime': dep != null
                            ? '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}'
                            : '--:--',
                        'departureAirport': '${f.originCity} (${f.originCode})',
                        'duration': '${f.durationMinutes ~/ 60}h ${f.durationMinutes % 60}m',
                        'stops': 'Non-stop',
                        'arrivalTime': arr != null
                            ? '${arr.hour.toString().padLeft(2, '0')}:${arr.minute.toString().padLeft(2, '0')}'
                            : '--:--',
                        'arrivalAirport': '${f.destinationCity} (${f.destinationCode})',
                        'price': 'EGP ${f.priceEGP.toStringAsFixed(0)}',
                      };
                      return _buildFlightCard(context, flightData);
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _demoFlights.length,
                    itemBuilder: (context, index) =>
                        _buildFlightCard(context, _demoFlights[index]),
                  ),
              ] else if (!_hasSearched) ...[
                Text(
                  'Sample available flights',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _demoFlights.length,
                  itemBuilder: (context, index) =>
                      _buildFlightCard(context, _demoFlights[index]),
                ),
              ],

              SizedBox(height: 40),

              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4B88),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      'Compare Multiple Flights',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select up to 3 flights to compare prices, schedules, and amenities',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 16),
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
                      child: Text('Go to Comparison Tool'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputGroup(
    String label,
    String placeholder,
    IconData icon, {
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1A94C4)),
              SizedBox(width: 8),
              Expanded(
                child: controller != null
                    ? TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          hintText: placeholder,
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 13),
                      )
                    : Text(
                        placeholder,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
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
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.flight,
              color: Color(0xFF1A94C4),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['airline'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      flight['stops'] ?? 'Non-stop',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['departureTime'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      flight['departureAirport'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(
                      Icons.flight_takeoff,
                      size: 16,
                      color: Color(0xFF1A94C4),
                    ),
                    Container(height: 1, width: 60, color: Colors.grey[300]),
                    Text(
                      flight['duration'],
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight['arrivalTime'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      flight['arrivalAirport'],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: Text(
                        'Select Flight',
                        style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12),
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
