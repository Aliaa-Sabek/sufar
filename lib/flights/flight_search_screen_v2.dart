import 'package:flutter/material.dart';
import 'flight_booking_screen.dart';

class FlightSearchPage extends StatefulWidget {
  const FlightSearchPage({super.key});

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  // Mock data for expandable cards
  final Set<int> _expandedCards = {
    0,
  }; // First card expanded by default for demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Flights Search',
          style: TextStyle(color: Colors.grey),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/Sufar Logo Blue.png',
              height: 24,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Column(
        children: [
          // Blue Header Summary
          Container(
            color: const Color(0xFF1A94C4),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(child: _buildHeaderItem('Lahore (LHE)')),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderItem('Frankfurt am Main (FRA)')),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderItem('21/01/2025')),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderItem('28/02/2025')),
                const SizedBox(width: 8),
                Expanded(child: _buildHeaderItem('1 Adult, Economy')),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar (Filters) - Hidden on small mobile, simplified here
                if (MediaQuery.of(context).size.width > 900)
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '120 Results',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Stops
                          const Text(
                            'Stops',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStopFilter('Direct', '£ 300', true),
                              const SizedBox(width: 8),
                              _buildStopFilter('1 Stop', '£ 500', false),
                              const SizedBox(width: 8),
                              _buildStopFilter('2 Stops', '£ 600', false),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Departure Times
                          const Text(
                            'Departure Times',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Lahore to Dubai',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Slider(
                            value: 0.5,
                            onChanged: (v) {},
                            activeColor: const Color(0xFF0D1C52),
                            inactiveColor: Colors.grey[200],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('00:00', style: TextStyle(fontSize: 10)),
                              Text('23:59', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Dubai to Lahore',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Slider(
                            value: 0.3,
                            onChanged: (v) {},
                            activeColor: const Color(0xFF0D1C52),
                            inactiveColor: Colors.grey[200],
                          ),

                          const SizedBox(height: 24),

                          // Airlines
                          const Text(
                            'Airlines',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildAirlineFilter('Emirates', true),
                              _buildAirlineFilter('Etihad', false),
                              _buildAirlineFilter('Qatar', false),
                              _buildAirlineFilter('Saudia', false),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Flight Results List
                Expanded(
                  child: Container(
                    color: const Color(0xFFF5F6F8), // Light grey bg for results
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Top Tabs
                        Row(
                          children: [
                            Expanded(
                              child: _buildTopTab(
                                'Cheapest',
                                '£279',
                                '9h57m',
                                true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTopTab(
                                'Best',
                                '£279',
                                '9h29m',
                                false,
                              ),
                            ), // Assuming same price for mock
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTopTab(
                                'Quickest',
                                '£279',
                                '9h00m',
                                false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // List
                        Expanded(
                          child: ListView.separated(
                            itemCount: 4,
                            separatorBuilder: (c, i) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              return _buildFlightResultCard(index);
                            },
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
    );
  }

  Widget _buildHeaderItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStopFilter(String label, String price, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A94C4) : Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirlineFilter(String name, bool isSelected) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF333333)
            : Colors.white, // Dark for selected
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight,
            color: isSelected ? Colors.amber : Colors.grey,
          ), // Placeholder logo
          Text(
            name,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(
    String label,
    String price,
    String duration,
    bool isSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A94C4) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlightResultCard(int index) {
    final bool isExpanded = _expandedCards.contains(index);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Row
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                // Airline Logo
                Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[100],
                  child: const Icon(Icons.flight, color: Color(0xFF0D1C52)),
                ),
                const SizedBox(width: 24),

                // Times & Route
                Expanded(
                  child: Column(
                    children: [
                      _buildFlightLeg(
                        'LHE',
                        '20:50',
                        'FRA',
                        '06:35',
                        '13h 45m',
                        'Direct',
                      ),
                      const SizedBox(height: 16),
                      _buildFlightLeg(
                        'FRA',
                        '23:50',
                        'LHE',
                        '06:35',
                        '13h 45m',
                        '1 Stop',
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Price & Select
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      '£340',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF0D1C52),
                      ),
                    ),
                    const Text(
                      'Economy',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlightBookingPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Select',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expand Button
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCards.remove(index);
                } else {
                  _expandedCards.add(index);
                }
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFFF9FAFB),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isExpanded ? 'Hide Details' : 'View Details',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // Expanded Content
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Flight details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Outbound: Tue, 21 Jan 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Timeline Item 1
                  _buildTimelineItem('20:50', 'LHE Lahore T4', isFirst: true),
                  _buildTimelineItem(
                    '06:35',
                    'FRA Frankfurt am Main T2',
                    isLast: true,
                    duration: '13h 45m',
                    airline: 'AirBlue SV737',
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Return: Wed, 29 Jan 2025',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Timeline Item 2
                  _buildTimelineItem(
                    '20:50',
                    'FRA Frankfurt am Main T1',
                    isFirst: true,
                  ),
                  _buildTimelineItem(
                    '06:35',
                    'DXB Dubai T3',
                    isLast: true,
                    duration: '6h 35m',
                    airline: 'AirBlue SV738',
                    isStop: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFlightLeg(
    String from,
    String departure,
    String to,
    String arrival,
    String duration,
    String stops,
  ) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              from,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
            Text(departure, style: const TextStyle(fontSize: 16)),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Text(
                  duration,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const Divider(),
                Text(
                  stops,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(to, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(arrival, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String time,
    String location, {
    bool isFirst = false,
    bool isLast = false,
    String? duration,
    String? airline,
    bool isStop = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 50,
          child: Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              // Vertical Line
              if (!isLast)
                Positioned(
                  top: 8,
                  bottom: 0, // Extend to bottom
                  left: 7,
                  child: Container(
                    width: 2,
                    height: 100,
                    color: Colors.grey[300],
                  ),
                ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(location, style: const TextStyle(fontSize: 13)),
                    ],
                  ),

                  if (duration != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (airline != null) ...[
                            const Icon(
                              Icons.flight,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              airline,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  if (isStop)
                    Padding(
                      padding: const EdgeInsets.only(left: 32, top: 16),
                      child: Text(
                        '1h stop and flight change in Dubai Airport',
                        style: TextStyle(color: Colors.red[400], fontSize: 11),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
