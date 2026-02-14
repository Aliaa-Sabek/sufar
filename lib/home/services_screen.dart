import 'package:flutter/material.dart';
import '../travel_offices/travel_offices_directory.dart';
import '../ai_planner/ai_planner_screen.dart';
import '../visa_advisor/visa_advisor_screen.dart';
import '../chat_bot/chat_bot_screen.dart';
import '../hotels/hotel_booking_screen.dart';

class ServicesScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const ServicesScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('All Services'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C52),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNavCard(
              context,
              'Flights',
              Icons.flight,
              null, // No direct page, use callback
              index: 1, // Flights tab index
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              'Hotel Booking',
              Icons.hotel,
              const HotelBookingScreen(),
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              'Travel Offices',
              Icons.store,
              const TravelOfficesDirectory(),
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              'AI Planner',
              Icons.auto_awesome,
              const AIPlannerPage(),
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              'Visa Advisor',
              Icons.article,
              const VisaAdvisorPage(),
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            _buildNavCard(
              context,
              'Chat Bot',
              Icons.chat,
              const ChatBotPage(),
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget? page, {
    int? index,
    Color? color,
  }) {
    return Container(
      width: double.infinity,
      height: 100, // Fixed height for consistency
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (index != null) {
              onNavigate(index);
            } else if (page != null) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (color ?? Colors.blue).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color ?? Colors.blue),
                ),
                const SizedBox(width: 24),
                // Text
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF0D1C52),
                    ),
                  ),
                ),
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
