import 'package:flutter/material.dart';
import 'flight_search_screen_v2.dart';

class FlightLandingPage extends StatefulWidget {
  const FlightLandingPage({super.key});

  @override
  State<FlightLandingPage> createState() => _FlightLandingPageState();
}

class _FlightLandingPageState extends State<FlightLandingPage> {
  String _flightType = 'Return';
  bool _directFlights = false;
  String _selectedTab = 'Flights';

  final _fromController = TextEditingController(text: 'Lahore (LHE)');
  final _toController = TextEditingController(text: 'Frankfurt am Main (FRA)');
  final _departureController = TextEditingController(text: '21/01/2025');
  final _returnController = TextEditingController(text: '28/02/2025');
  final _travelersController = TextEditingController(text: '1 Adult, Economy');

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _departureController.dispose();
    _returnController.dispose();
    _travelersController.dispose();
    super.dispose();
  }

  void _swapCities() {
    final t = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = t;
    setState(() {});
  }

  void _openSearchResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightSearchPage(
          fromCity: _fromController.text,
          toCity: _toController.text,
          departureDate: _departureController.text,
          returnDate: _returnController.text,
          travelers: 1,
          isOneWay: _flightType == 'One Way',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
        title: Image.asset(
          'assets/Sufar Logo Blue.png',
          height: 35,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Color(0xFF0D1C52)),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            SizedBox(height: 40),
            _buildWhyTravelCartSection(),
            SizedBox(height: 40),
            _buildFeaturesSection(),
            SizedBox(height: 40),
            _buildTrustpilotSection(),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 640,
      child: Stack(
        children: [
          // Background Image
          Image.asset(
            'assets/flights_bg.png',
            height: 450,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                Container(color: const Color(0xFF1A94C4), height: 450),
          ),
          // Overlay gradient
          Container(
            height: 450,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tabs
                Row(
                  children: [
                    _buildTab(
                      'Flights',
                      Icons.flight,
                      _selectedTab == 'Flights',
                    ),
                    SizedBox(width: 16),
                    _buildTab(
                      'VISA',
                      Icons.article_outlined,
                      _selectedTab == 'VISA',
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Title
                Text(
                  'Hey Buddy! Where are you\nFlying to?',
                  style: TextStyle(
                    color: Theme.of(context).cardColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Search Card positioned at bottom
          Positioned(
            top: 260,
            left: 20,
            right: 20,
            child: _buildAdvancedSearchCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedTab = title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A94C4) : Colors.white,
              size: 28,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0D1C52) : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkboxes / Radios
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRadioOption('Return'),
                SizedBox(width: 12),
                _buildRadioOption('One Way'),
                SizedBox(width: 12),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _directFlights,
                        onChanged: (v) =>
                            setState(() => _directFlights = v ?? false),
                        activeColor: const Color(0xFF1A94C4),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Direct Flights',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          // From / To inputs
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'From',
                  'United Kingdom (UK)',
                  Icons.flight_takeoff,
                  _fromController,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _swapCities,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(
                        Icons.swap_horiz,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildInputField(
                  'To',
                  'Country, City..',
                  Icons.flight_land,
                  _toController,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Departure / Return
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Departure',
                  '14/01/2025',
                  Icons.calendar_today,
                  _departureController,
                ),
              ),
              if (_flightType != 'One Way') ...[
                SizedBox(width: 16),
                Expanded(
                  child: _buildInputField(
                    'Return',
                    '21/01/2025',
                    Icons.calendar_today,
                    _returnController,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16),
          _buildInputField(
            'Travelers and Cabin Class',
            '1 Adult, Economy',
            Icons.person,
            _travelersController,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openSearchResults,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Search Flights',
                    style: TextStyle(
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
    );
  }

  Widget _buildRadioOption(String title) {
    final isSelected = _flightType == title;
    return GestureDetector(
      onTap: () => setState(() => _flightType = title),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF1A94C4)
                    : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: 6),
          Text(title, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, [
    TextEditingController? controller,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: TextStyle( fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhyTravelCartSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why Travel Cart',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildWhyCard('ATOL\nProtected Flights', Icons.security),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildWhyCard('Best Prices\nGuarentee', Icons.loyalty),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildWhyCard(
                  'Secure\nPayment',
                  Icons.payment,
                  bgColor: const Color(0xFF1A94C4),
                  textColor: Colors.white,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildWhyCard(
                  '24/7 Customer\nSupport',
                  Icons.headset_mic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWhyCard(
    String title,
    IconData icon, {
    Color bgColor = const Color(0xFFF9FAFB),
    Color textColor = Colors.black87,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: textColor == Colors.black87
                ? const Color(0xFF0D1C52)
                : Colors.white,
            size: 28,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          _buildFeatureImageCard(
            'Complete Control',
            'Easily manage your booking from one place. Change, upgrade, choose seats, meals, check-in options and everything related to your add-ons. Plus, track your refund status in real time with no stress.',
            'Log in to My Bookings >',
            'assets/flights_bg.png',
          ),
          SizedBox(width: 16),
          _buildFeatureImageCard(
            'Flexible Payment Options',
            'Get your ticket by paying deposit, no credit card required. Save big by securing your seat in advance and clear the balance before you travel.',
            'Explore Flexible Payments >',
            'assets/clouds_bg.png',
          ),
          SizedBox(width: 16),
          _buildFeatureImageCard(
            'Experience Trust',
            'For the first time in the travel industry, we offer direct video calls with our experts. Experience transparency and personalized service that ensures your confidence and peace of mind throughout your journey.',
            'Video Chat with us >',
            'assets/home_bg.png',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureImageCard(
    String title,
    String desc,
    String btnText,
    String asset,
  ) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(asset), fit: BoxFit.cover),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.4),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(color: Colors.white70, fontSize: 12),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16),
            Text(
              btnText,
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustpilotSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: Colors.green),
              SizedBox(width: 4),
              Text(
                'Trustpilot',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Don't take our word for it\nSee what our customer\nsay about us:",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildReviewCard(),
                SizedBox(width: 16),
                _buildReviewCard(),
                SizedBox(width: 16),
                _buildReviewCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      width: 250,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best on the market',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (index) => Icon(Icons.star, color: Colors.green, size: 16),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'I love this product because the support is great. Please ...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const Spacer(),
          Text(
            'Worldtraveler',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
