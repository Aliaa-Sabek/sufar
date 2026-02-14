import 'package:flutter/material.dart';
import 'flights/flight_landing_screen_v2.dart';
import 'home/home_screen.dart';
import 'home/services_screen.dart';
import 'profile/profile_screen.dart';
import 'chat_bot/chat_bot_screen.dart';
import 'onboarding/splash_screen.dart';

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
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToServices(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServicesScreen(
          onNavigate: (index) {
            Navigator.pop(context); // Close the Services Screen
            _onNavigate(index); // Switch the tab
          },
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatBotPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        onNavigateToServices: () => _navigateToServices(context),
        onNavigateToProfile: () =>
            _onNavigate(2), // Switch to Profile Tab (index 2)
        onNavigateToChat: () => _navigateToChat(context),
        onNavigateToFlights: () => _onNavigate(1),
      ),
      const FlightLandingPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF1A94C4),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.flight), label: 'Flight'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
