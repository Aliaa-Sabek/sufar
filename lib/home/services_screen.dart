import 'package:flutter/material.dart';
import '../travel_offices/travel_offices_directory.dart';
import '../chat_bot/chat_bot_screen.dart';
import '../hotels/hotel_booking_screen.dart';
import '../destinations/destinations_screen.dart';
import '../flights/flight_landing_screen_v2.dart';

class ServicesScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const ServicesScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sufar Navigation Hub',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotPage()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Color(0xFF0D1C52)),
            onPressed: () => onNavigate(3), // Navigate to Profile tab
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildGrid(context),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final List<_ServiceGridItem> items = [
      _ServiceGridItem(
        title: 'Flights (New)',
        icon: Icons.flight,
        color: Colors.blueAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FlightLandingPage()),
        ),
      ),
      _ServiceGridItem(
        title: 'Hotel Booking',
        icon: Icons.hotel_outlined,
        color: Colors.orangeAccent,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HotelBookingScreen()),
        ),
      ),
      _ServiceGridItem(
        title: 'Travel Offices',
        icon: Icons.store_mall_directory_outlined,
        color: Colors.green,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TravelOfficesDirectory(),
          ),
        ),
      ),
      _ServiceGridItem(
        title: 'Destinations',
        icon: Icons.explore_outlined,
        color: const Color(0xFF1A94C4),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DestinationsScreen()),
        ),
      ),
      _ServiceGridItem(
        title: 'Chat Bot',
        icon: Icons.chat_bubble_outline,
        color: Colors.teal,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatBotPage()),
        ),
      ),
      _ServiceGridItem(
        title: 'Profile',
        icon: Icons.person_outline,
        color: Colors.indigo,
        onTap: () => onNavigate(3), // Navigate to Profile tab
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildItem(context, items[index]);
      },
    );
  }

  Widget _buildItem(BuildContext context, _ServiceGridItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, size: 36, color: item.color),
            ),
            SizedBox(height: 12),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceGridItem {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ServiceGridItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
