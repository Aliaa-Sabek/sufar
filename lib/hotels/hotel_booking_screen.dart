import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'hotel_details_screen.dart';
import '../chat_bot/chat_bot_screen.dart';
import 'package:sufar_project/models/hotel_model.dart';


// the screen =
class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _cityController = TextEditingController();

  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;
  String? _rawDebugResponse;

  @override
  void initState() {
    super.initState();
    _fetchInitialHotels();
  }

  Future<void> _fetchInitialHotels() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getHotels(limit: 10);
      final hotelList = response['hotels'] as List? ?? [];
      setState(() {
        _hotels = hotelList.map((e) => Hotel.fromJson(e)).toList();
        _hasSearched = true;
      });
    } catch (e) {
      debugPrint('Error fetching hotels: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

// Api call
  Future<void> _searchHotels() async {
    final city = _cityController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _rawDebugResponse = null;
      _hasSearched = true;
    });

    try {
      final response = await ApiService.getHotels(city: city, limit: 20);
      final hotelList = response['hotels'] as List? ?? [];
      setState(() {
        _hotels = hotelList.map((e) => Hotel.fromJson(e)).toList();
        if (_hotels.isEmpty) {
          _rawDebugResponse = 'No hotels found for "$city"';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Search error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // screen builder
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showSidebar = constraints.maxWidth > 700;
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xFF0D1C52)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatBotPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  
                ),
                onPressed: () {
                  // This is a standalone screen navigation,
                  // but since it's on the bar usually we pop or navigate to main
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              SizedBox(width: 8),
            ],
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          endDrawer: showSidebar
              ? null
              : Drawer(child: _buildSidebarFilters(isMobile: true)),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSidebar) _buildSidebarFilters(isMobile: false),
              Expanded(
                child: Column(
                  children: [
                    _buildSearchBar(showFilterButton: !showSidebar),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarFilters({bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 280,
      margin: isMobile
          ? EdgeInsets.all(0) // No margin in drawer
          : EdgeInsets.only(left: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isMobile
            ? null // No border in drawer
            : Border.all(color: const Color(0xFF1A94C4), width: 3),
      ),
      child: SafeArea(
        // Keep it safe in case it's in a drawer
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filters',
                style: TextStyle(
                  
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                child: Text(
                  'Price Range',
                  style: TextStyle(
                    color: Color(0xFF5D6B78),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              _buildPriceSlider(),
              _buildFilterSectionTitle('Minimum Rating'),
              _buildRadioOption('4.5+', isSelected: true, isStar: true),
              _buildRadioOption('4+', isSelected: false, isStar: true),
              _buildRadioOption('3.5+', isSelected: false, isStar: true),
              _buildRadioOption('3+', isSelected: false, isStar: true),
              _buildFilterSectionTitle('Amenities'),
              _buildCheckboxOption(
                'Free WiFi',
                isSelected: true,
                icon: Icons.wifi,
              ),
              _buildCheckboxOption(
                'Breakfast',
                isSelected: true,
                icon: Icons.coffee,
              ),
              _buildCheckboxOption(
                'Restaurant',
                isSelected: true,
                icon: Icons.restaurant,
              ),
              _buildCheckboxOption(
                'Gym',
                isSelected: true,
                icon: Icons.fitness_center,
              ),
              _buildFilterSectionTitle('Location'),
              _buildCheckboxOption('City Center', isSelected: true),
              _buildCheckboxOption('Beachfront', isSelected: true),
              _buildCheckboxOption('Near Airport', isSelected: true),
              _buildFilterSectionTitle('Hotel Type'),
              _buildRadioOption('Resort', isSelected: true),
              _buildRadioOption('Boutique Hotel', isSelected: false),
              _buildRadioOption('Business Hotel', isSelected: false),
              _buildRadioOption('Family Hotel', isSelected: false),
              _buildFilterSectionTitle('Room Options'),
              _buildRadioOption('Single Room', isSelected: true),
              _buildRadioOption('Double Room', isSelected: false),
              _buildRadioOption('Suite', isSelected: false),
              _buildFilterSectionTitle('Deals & Offers'),
              _buildRadioOption('On Sale', isSelected: true),
              _buildRadioOption('Best Value', isSelected: false),
              _buildRadioOption('Limited Offer', isSelected: false),
              _buildFilterSectionTitle('Stay Duration'),
              _buildRadioOption('1–3 Nights', isSelected: true),
              _buildRadioOption('4–7 Nights', isSelected: false),
              _buildRadioOption('8+ Nights', isSelected: false),
              _buildFilterSectionTitle('Region / Area'),
              _buildRadioOption('Asia', isSelected: true),
              _buildRadioOption('Europe', isSelected: false),
              _buildRadioOption('Middle East', isSelected: false),
              _buildRadioOption('Africa', isSelected: false),
              _buildFilterSectionTitle('Traveler Type'),
              _buildRadioOption('Solo Travelers', isSelected: true),
              _buildRadioOption('Couples', isSelected: false),
              _buildRadioOption('Families', isSelected: false),
              _buildRadioOption('Honeymoon', isSelected: false),
              _buildFilterSectionTitle('Accessibility'),
              _buildCheckboxOption('Wheelchair Accessible', isSelected: false),
              _buildCheckboxOption('Elevator Available', isSelected: false),
              _buildFilterSectionTitle('Eco Friendly'),
              _buildCheckboxOption('Eco-friendly Hotel', isSelected: false),
              _buildCheckboxOption('Sustainable Practices', isSelected: false),
              _buildFilterSectionTitle('Service & Policies'),
              _buildCheckboxOption('Free Cancellation', isSelected: false),
              _buildCheckboxOption('Pay at Hotel', isSelected: false),
              _buildCheckboxOption('No Prepayment', isSelected: false),
              _buildCheckboxOption('24/7 Front Desk', isSelected: false),
              _buildFilterSectionTitle('Check-in Experience'),
              _buildRadioOption('Early Check-in Available', isSelected: false),
              _buildRadioOption('Standard Check-in', isSelected: false),
              _buildRadioOption('Late Check-in Available', isSelected: false),
              _buildFilterSectionTitle('Bed Type'),
              _buildRadioOption('King Bed', isSelected: false),
              _buildRadioOption('Queen Bed', isSelected: false),
              _buildRadioOption('Twin Beds', isSelected: false),
              _buildFilterSectionTitle('Bathroom Type'),
              _buildRadioOption('Private Bathroom', isSelected: false),
              _buildRadioOption('Bathtub', isSelected: false),
              _buildRadioOption('Walk-in Shower', isSelected: false),
              _buildFilterSectionTitle('Noise Level'),
              _buildRadioOption('Quiet Area', isSelected: false),
              _buildRadioOption('Moderate', isSelected: false),
              _buildRadioOption('Lively Area', isSelected: false),
              _buildFilterSectionTitle('Facilities Level'),
              _buildRadioOption('Basic Facilities', isSelected: false),
              _buildRadioOption('Full Facilities', isSelected: false),
              _buildRadioOption('Luxury Facilities', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Color(0xFF1A94C4),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF1A94C4),
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: const Color(0xFF1A94C4),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
          ),
          child: Slider(value: 500, min: 0, max: 500, onChanged: (val) {}),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('\$0', style: TextStyle(color: Colors.grey, fontSize: 11)),
            Text(
              '\$500',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(
    String label, {
    required bool isSelected,
    bool isStar = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: isSelected
                ? const Color(0xFF1A94C4)
                : const Color(0xFF1A94C4),
            size: 16,
          ),
          SizedBox(width: 8),
          if (isStar) ...[
            Icon(Icons.star, color: Colors.amber, size: 14),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle( fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxOption(
    String label, {
    required bool isSelected,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_box : Icons.check_box_outline_blank,
            color: isSelected
                ? const Color(0xFF1A94C4)
                : const Color(0xFF1A94C4),
            size: 16,
          ),
          SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, color: Colors.grey, size: 14),
            SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle( fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar({bool showFilterButton = false}) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchHotels(),
              decoration: InputDecoration(
                hintText: 'Enter city name…',
                prefixIcon: Icon(Icons.location_city),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (_isLoading) return;
              _searchHotels();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1C52),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Search'),
          ),
          if (showFilterButton) ...[
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.tune, color: Color(0xFF0D1C52)),
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              tooltip: 'Filters',
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF5F5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDebugBox() {
    if (_rawDebugResponse == null) return SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: SelectableText(
        _rawDebugResponse!,
        style: TextStyle(fontFamily: 'monospace', fontSize: 11),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
            _buildDebugBox(),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _searchHotels,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hotel, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for hotels in any city',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hotels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hotels found matching your search.',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16),
      itemCount: _hotels.length,
      separatorBuilder: (ctx, idx) => SizedBox(height: 12),
      itemBuilder: (context, index) => _HotelCard(hotel: _hotels[index]),
    );
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }
}

// Hotel's card
class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Image Section
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: hotel.imageUrl.isNotEmpty
                        ? Image.network(
                            hotel.imageUrl,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.hotel,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                        : Container(
                            height: 180,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.hotel,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite_border,
                        color: Theme.of(context).cardColor,
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(true),
                        _buildDot(false),
                        _buildDot(false),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).cardColor,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            // Right Side: Details Section
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          hotel.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _RatingBadge(rating: hotel.rating),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    hotel.description,
                    style: TextStyle(
                      fontSize: 11,
                      
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        hotel.city,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Hotel Highlights',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                  SizedBox(height: 6),
                  _buildHighlight('Free Wi-Fi'),
                  _buildHighlight('Spa & Wellness Center'),
                  _buildHighlight('Breakfast Included'),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Duration',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                          Text(
                            '9 Days / 8 Nights',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${hotel.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(fontSize: 9, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HotelDetailsScreen(hotel: hotel),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'View Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 14),
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

  Widget _buildHighlight(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 12, color: Colors.green),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

// the badge of the rating
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: Colors.amber),
          SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
