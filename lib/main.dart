import 'dart:async';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'flights/flight_landing_screen_v2.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'chat_bot/chat_bot_screen.dart';
import 'onboarding/splash_screen.dart';
import 'ai_planner/ai_planner_screen.dart';
import 'home/services_screen.dart';
import 'services/activity_image_resolver.dart';
import 'services/destination_catalog_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ActivityImageResolver.preloadCatalog();
  runApp(const MyApp());
  unawaited(DestinationCatalogService.loadRawCatalog());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Sufar Booking',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
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
        onNavigateToDestinations: () => _onNavigate(1),
        onNavigateToProfile: () => _onNavigate(3),
        onNavigateToChat: () => _navigateToChat(context),
        onNavigateToFlights: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FlightLandingPage()),
          );
        },
      ),
      ServicesScreen(onNavigate: _onNavigate),

      const AIPlannerPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          selectedItemColor: const Color(0xFF1A94C4),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'AI Planner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
