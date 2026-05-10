import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sufar_project/services/api_service.dart';
import '../models/user_model.dart';
import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import '../models/booking_model.dart';
import '../ai_planner/ai_planner_screen.dart';
import '../chat_bot/chat_bot_screen.dart';
import 'edit_profile_screen.dart';
import '../onboarding/splash_screen.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserModel? _userModel;
  final List<DestinationModel> _savedDestinations = [];
  final List<Hotel> _bookmarkedHotels = [];
  final List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfileAndData();
  }

  Future<void> _fetchProfileAndData() async {
    await _fetchUserProfile();
    await _fetchFavorites();
    await _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      final rows = await ApiService.getMyBookings();
      if (mounted) {
        setState(() {
          _bookings.clear();
          _bookings.addAll(
            rows.map((b) => Booking.fromJson(b)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
    }
  }

  Future<void> _fetchFavorites() async {
    // Backend API for favorites not implemented yet
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. First try to get user from SharedPreferences (saved at login)
      final prefs = await SharedPreferences.getInstance();
      final storedUserJson = prefs.getString('backend_user');
      if (storedUserJson != null && storedUserJson != 'null') {
        final decoded = jsonDecode(storedUserJson);
        if (decoded is Map<String, dynamic>) {
          if (mounted) {
            setState(() {
              _userModel = UserModel.fromJson(decoded);
              _isLoading = false;
            });
          }
        }
      }

      // 2. Try to fetch fresh data from backend (non-blocking)
      try {
        final profileData = await ApiService.getMyProfile();
        // Backend may return { user: {...} } or the user directly
        final userData = profileData['user'] as Map<String, dynamic>? ?? profileData;
        if (userData.isNotEmpty && mounted) {
          final freshUser = UserModel.fromJson(userData);
          await prefs.setString('backend_user', jsonEncode(userData));
          if (mounted) {
            setState(() {
              _userModel = freshUser;
              _isLoading = false;
            });
          }
        }
      } catch (profileError) {
        debugPrint('Could not refresh profile from backend: $profileError');
      }

      // 3. If still no user data, show default
      if (mounted && _userModel == null) {
        setState(() {
          _userModel = UserModel(
            id: '',
            name: 'Traveler',
            email: '',
            createdAt: DateTime.now().toIso8601String(),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Web-style App Bar
            Container(
              color: Theme.of(context).cardColor,
              padding: EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/Sufar Logo Blue.png',
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.travel_explore,
                      color: Color(0xFF1A94C4),
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  // Web Navigation Links
                  if (!isMobile) ...[
                    _buildNavText('Home'),
                    _buildNavText('Destinations'),
                    _buildNavText('Hotels'),
                    _buildNavText('Flights'),
                    _buildNavText('Travel Offices'),
                    _buildNavText(
                      'AI Planner',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AIPlannerPage(),
                          ),
                        );
                      },
                    ),
                    _buildNavText('Visa Advisor'),
                  ] else ...[
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        // Open mobile menu
                      },
                    ),
                  ],
                  SizedBox(width: 24),
                  IconButton(
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.grey,
                      size: 20,
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
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: AppTheme.themeNotifier,
                    builder: (context, themeMode, _) {
                      final isDark = themeMode == ThemeMode.dark;
                      return IconButton(
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () {
                          AppTheme.themeNotifier.value =
                              isDark ? ThemeMode.light : ThemeMode.dark;
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      _showLogoutDialog(context); // Or profile menu
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 1000,
                    ), // Web container width
                    padding: EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      children: [
                        // Main Profile Card
                        Container(
                          padding: EdgeInsets.all(isMobile ? 0 : 32),
                          decoration: BoxDecoration(
                            color: isMobile ? Colors.transparent : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: isMobile
                                ? []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.02,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Column(
                            children: [
                              // User Info Row
                              isMobile
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            if (_userModel != null) {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfileScreen(
                                                            userModel:
                                                                _userModel!,
                                                          ),
                                                    ),
                                                  );
                                              if (result == true) {
                                                _fetchProfileAndData();
                                              }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.settings_outlined,
                                            size: 16,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          label: Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1A94C4,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),
                                        if (_isLoading)
                                          Center(
                                            child: SizedBox(
                                              width: 80,
                                              height: 80,
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                          )
                                        else if (_errorMessage != null)
                                          Center(
                                            child: Text(
                                              'Error: $_errorMessage',
                                            ),
                                          )
                                        else if (_userModel == null)
                                          Center(
                                            child: Text(
                                              'Please log in to see profile',
                                            ),
                                          )
                                        else
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      LinearGradient(
                                                        colors: [
                                                          Color(0xFF1A94C4),
                                                          Color(0xFF0D1C52),
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  image:
                                                      _userModel?.avatarUrl !=
                                                              null &&
                                                          _userModel!
                                                              .avatarUrl!
                                                              .isNotEmpty
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                            _userModel!
                                                                .avatarUrl!,
                                                          ),
                                                          fit: BoxFit.cover,
                                                        )
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child:
                                                    _userModel?.avatarUrl ==
                                                            null ||
                                                        _userModel!
                                                            .avatarUrl!
                                                            .isEmpty
                                                    ? Text(
                                                        _userModel!.initials,
                                                        style: TextStyle(
                                                          color: Theme.of(context).cardColor,
                                                          fontSize: 32,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _userModel!.name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color(
                                                          0xFF0D1C52,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    _buildIconText(
                                                      Icons.email_outlined,
                                                      _userModel!.email,
                                                    ),
                                                    if (_userModel!
                                                            .nationality !=
                                                        null) ...[
                                                      SizedBox(height: 4),
                                                      _buildIconText(
                                                        Icons
                                                            .location_on_outlined,
                                                        _userModel!
                                                            .nationality!,
                                                      ),
                                                    ],
                                                    SizedBox(height: 4),
                                                    _buildIconText(
                                                      Icons
                                                          .calendar_today_outlined,
                                                      'Member since ${_formatDate(_userModel!.createdAt)}',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (_isLoading)
                                          SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: CircularProgressIndicator(),
                                          )
                                        else if (_errorMessage != null)
                                          Text('Error: $_errorMessage')
                                        else if (_userModel == null)
                                          Text(
                                            'Please log in to see profile',
                                          )
                                        else ...[
                                          Container(
                                            width: 100,
                                            height: 100,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0D4B88),
                                              borderRadius:
                                                  BorderRadius.circular(24),
                                              image:
                                                  _userModel?.avatarUrl !=
                                                          null &&
                                                      _userModel!
                                                          .avatarUrl!
                                                          .isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        _userModel!.avatarUrl!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            alignment: Alignment.center,
                                            child:
                                                _userModel?.avatarUrl == null ||
                                                    _userModel!
                                                        .avatarUrl!
                                                        .isEmpty
                                                ? Text(
                                                    _userModel!.initials,
                                                    style: TextStyle(
                                                      color: Theme.of(context).cardColor,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                          SizedBox(width: 24),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _userModel!.name,
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                _buildIconText(
                                                  Icons.email_outlined,
                                                  _userModel!.email,
                                                ),
                                                if (_userModel!.nationality !=
                                                    null) ...[
                                                  SizedBox(height: 4),
                                                  _buildIconText(
                                                    Icons.location_on_outlined,
                                                    _userModel!.nationality!,
                                                  ),
                                                ],
                                                SizedBox(height: 4),
                                                _buildIconText(
                                                  Icons.calendar_today_outlined,
                                                  'Member since ${_formatDate(_userModel!.createdAt)}',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                        // Edit Profile Button
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            if (_userModel != null) {
                                              final result =
                                                  await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditProfileScreen(
                                                            userModel:
                                                                _userModel!,
                                                          ),
                                                    ),
                                                  );
                                           if (result == true) {
                                             _fetchProfileAndData();
                                           }
                                            }
                                          },
                                          icon: Icon(
                                            Icons.settings_outlined,
                                            size: 16,
                                            color: Theme.of(context).cardColor,
                                          ),
                                          label: Text(
                                            'Edit Profile',
                                            style: TextStyle(
                                              color: Theme.of(context).cardColor,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF1A94C4,
                                            ),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              SizedBox(height: 32),
                              // Stats Section - Horizontal Cards
                              isMobile
                                  ? Column(
                                      children: [
                                        _buildStat(
                                          _savedDestinations.length.toString(),
                                          'Destinations',
                                        ),
                                        SizedBox(height: 16),
                                        _buildStat(
                                          _bookings.length.toString(),
                                          'Travel Plans',
                                        ),
                                        SizedBox(height: 16),
                                        _buildStat(
                                          _bookmarkedHotels.length.toString(),
                                          'Bookmarks',
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildStat(
                                            _savedDestinations.length
                                                .toString(),
                                            'Destinations',
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStat(
                                            _bookings.length.toString(),
                                            'Travel Plans',
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildStat(
                                            _bookmarkedHotels.length.toString(),
                                            'Bookmarks',
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Two Columns Layer: Saved Destinations and Bookmarked Hotels
                        isMobile
                            ? Column(
                                children: [
                                  _buildSavedDestinationsContainer(),
                                  SizedBox(height: 24),
                                  _buildBookmarkedHotelsContainer(),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildSavedDestinationsContainer(),
                                  ),
                                  SizedBox(width: 24),
                                  Expanded(
                                    child: _buildBookmarkedHotelsContainer(),
                                  ),
                                ],
                              ),

                        SizedBox(height: 24),

                        // Past AI Travel Plans
                        Container(
                          padding: EdgeInsets.all(24),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.description_outlined,
                                    color: Color(0xFF1A94C4),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Past AI Travel Plans',
                                    style: TextStyle(
                                      
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              isMobile
                                  ? Column(
                                      children: [
                                        _buildPlanCard(
                                          'Thailand Adventure',
                                          '7 days',
                                          '\$1,500',
                                          'Nov 15, 2024',
                                        ),
                                        SizedBox(height: 16),
                                        _buildPlanCard(
                                          'European Tour',
                                          '14 days',
                                          '\$3,200',
                                          'Oct 20, 2024',
                                        ),
                                        SizedBox(height: 16),
                                        _buildPlanCard(
                                          'Dubai Experience',
                                          '5 days',
                                          '\$2,000',
                                          'Sep 12, 2024',
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: _buildPlanCard(
                                            'Thailand Adventure',
                                            '7 days',
                                            '\$1,500',
                                            'Nov 15, 2024',
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildPlanCard(
                                            'European Tour',
                                            '14 days',
                                            '\$3,200',
                                            'Oct 20, 2024',
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _buildPlanCard(
                                            'Dubai Experience',
                                            '5 days',
                                            '\$2,000',
                                            'Sep 12, 2024',
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),

                        SizedBox(height: 40),

                        // Bottom CTA
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 40,
                            horizontal: 24,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1A94C4), Color(0xFF0D1C52)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF1A94C4,
                                ).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Start Planning Your Next Adventure',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).cardColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Use our AI planner to create your perfect itinerary',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 32),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const AIPlannerPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1A94C4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                ),
                                child: Text(
                                  'Create New Plan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDestinationsContainer() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.favorite_border, color: Color(0xFF1A94C4), size: 18),
              SizedBox(width: 8),
              Text(
                'Saved Destinations',
                style: TextStyle(
                  
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (_savedDestinations.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No saved destinations yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._savedDestinations.map(
              (dest) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildSavedItem(
                  dest.name,
                  'Saved destination',
                  null,
                  imageUrl: dest.imageUrl,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookmarkedHotelsContainer() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.bookmark_border, color: Color(0xFF1A94C4), size: 18),
              SizedBox(width: 8),
              Text(
                'Bookmarked Hotels',
                style: TextStyle(
                  
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          if (_bookmarkedHotels.isEmpty && _bookings.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No bookmarked hotels yet',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            ..._bookings.map(
              (booking) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildBookingItem(booking),
              ),
            ),
            ..._bookmarkedHotels.map(
              (hotel) => Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: _buildHotelItem(
                  hotel.name,
                  hotel.city,
                  '\$${hotel.price}',
                  imageUrl: hotel.imageUrl,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavText(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: _logout,
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8FA2B4)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Color(0xFF5D6B78), fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: Color(0xFF1A94C4),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Color(0xFF5D6B78), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItem(
    String title,
    String date,
    Color? color, {
    String? imageUrl,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color ?? Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: imageUrl.startsWith('http') 
                          ? NetworkImage(imageUrl) 
                          : AssetImage(imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.image, color: Theme.of(context).cardColor.withOpacity(0.5))
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    color: Color(0xFF8FA2B4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: const [
              Text(
                'View',
                style: TextStyle(
                  color: Color(0xFF1A94C4),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 14, color: Color(0xFF1A94C4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    final imageUrl = booking.hotelImageUrl;
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              image: imageUrl != null && imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: imageUrl.startsWith('http')
                          ? NetworkImage(imageUrl)
                          : AssetImage(imageUrl) as ImageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null || imageUrl.isEmpty
                ? Icon(Icons.check_circle_outline, color: Colors.green)
                : null,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hotel Booking #${booking.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${booking.checkIn} to ${booking.checkOut}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  'Status: ${booking.status.toUpperCase()}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${booking.totalPrice}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A94C4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelItem(String name, String location, String price, {String? imageUrl}) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    image: imageUrl != null && imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: imageUrl.startsWith('http')
                                ? NetworkImage(imageUrl)
                                : AssetImage(imageUrl) as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null || imageUrl.isEmpty
                      ? Icon(Icons.hotel, color: Colors.grey[500])
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF8FA2B4),
                          ),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: TextStyle(
                                color: Color(0xFF8FA2B4),
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A94C4),
                ),
              ),
              Text(
                '/night',
                style: TextStyle(color: Color(0xFF8FA2B4), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    String title,
    String duration,
    String budget,
    String date,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF8FA2B4),
              ),
              SizedBox(width: 6),
              Text(
                duration,
                style: TextStyle(fontSize: 13, color: Color(0xFF5D6B78)),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Budget: $budget',
            style: TextStyle(fontSize: 13, color: Color(0xFF5D6B78)),
          ),
          SizedBox(height: 8),
          Text(
            'Created: $date',
            style: TextStyle(fontSize: 12, color: Color(0xFF8FA2B4)),
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Plan',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
