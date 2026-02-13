import 'package:flutter/material.dart';
import 'booking/booking_screen_1.dart';
import 'flights/flight_landing_screen_v2.dart';
import 'travel_offices/travel_offices_directory.dart';
import 'ai_planner/ai_planner_screen.dart';
import 'visa_advisor/visa_advisor_screen.dart';
import 'chat_bot/chat_bot_screen.dart';
import 'profile/profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sufar Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A94C4)),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sufar Navigation Hub'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A94C4),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            _buildNavCard(
              context,
              'Flights (New)',
              Icons.flight,
              const FlightLandingPage(),
              color: Colors.blueAccent,
            ),
            _buildNavCard(
              context,
              'Hotel Booking',
              Icons.hotel,
              const BookingPage1(),
              color: Colors.orangeAccent,
            ),
            _buildNavCard(
              context,
              'Travel Offices',
              Icons.store,
              const TravelOfficesDirectory(),
              color: Colors.green,
            ),
            _buildNavCard(
              context,
              'AI Planner',
              Icons.auto_awesome,
              const AIPlannerPage(),
              color: Colors.purpleAccent,
            ),
            _buildNavCard(
              context,
              'Visa Advisor',
              Icons.article,
              const VisaAdvisorPage(),
              color: Colors.redAccent,
            ),
            _buildNavCard(
              context,
              'Chat Bot',
              Icons.chat,
              const ChatBotPage(),
              color: Colors.teal,
            ),
            _buildNavCard(
              context,
              'Profile',
              Icons.person,
              const ProfilePage(),
              color: Colors.indigo,
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
    Widget page, {
    Color? color,
  }) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (color ?? Colors.blue).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color ?? Colors.blue),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
