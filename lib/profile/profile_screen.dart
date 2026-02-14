import 'package:flutter/material.dart';
import '../auth/sign_in_screen.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/Sufar Logo Blue.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.travel_explore,
                      color: Color(0xFF1A94C4),
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black54),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.black54,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Main Profile Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Edit Profile Button
                            Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Edit Profile',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A94C4),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),

                            // User Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D4B88),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'JD',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'John Doe',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D1C52),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _buildIconText(
                                        Icons.email_outlined,
                                        'john.doe@example.com',
                                      ),
                                      const SizedBox(height: 4),
                                      _buildIconText(
                                        Icons.location_on_outlined,
                                        'New York, USA',
                                      ),
                                      const SizedBox(height: 4),
                                      _buildIconText(
                                        Icons.calendar_today_outlined,
                                        'Member since January 2023',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Stats Section - Vertical Cards
                            _buildStat('12', 'Destinations'),
                            const SizedBox(height: 12),
                            _buildStat('8', 'Travel Plans'),
                            const SizedBox(height: 12),
                            _buildStat('25', 'Bookmarks'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Saved Destinations
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.favorite_border,
                                  color: Color(0xFF1A94C4),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Saved Destinations',
                                  style: TextStyle(
                                    color: Color(0xFF0D1C52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSavedItem(
                              'Bali, Indonesia',
                              'Saved on Dec 10, 2024',
                              Colors.brown[300], // Palm tree vibe
                            ),
                            const SizedBox(height: 16),
                            _buildSavedItem(
                              'Swiss Alps',
                              'Saved on Dec 5, 2024',
                              Colors.green[300], // Nature vibe
                            ),
                            const SizedBox(height: 16),
                            _buildSavedItem(
                              'Paris, France',
                              'Saved on Nov 28, 2024',
                              Colors.orange[300], // City vibe
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bookmarked Hotels
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.bookmark_border,
                                  color: Color(0xFF1A94C4),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Bookmarked Hotels',
                                  style: TextStyle(
                                    color: Color(0xFF0D1C52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildHotelItem(
                              'The Mulia Resort',
                              'Bali, Indonesia',
                              '\$250',
                            ),
                            const SizedBox(height: 16),
                            _buildHotelItem(
                              'Four Seasons',
                              'Paris, France',
                              '\$380',
                            ),
                            const SizedBox(height: 16),
                            _buildHotelItem(
                              'Alpine Lodge',
                              'Swiss Alps',
                              '\$320',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Past AI Travel Plans
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.description_outlined,
                                  color: Color(0xFF1A94C4),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Past AI Travel Plans',
                                  style: TextStyle(
                                    color: Color(0xFF0D1C52),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildPlanCard(
                              'Thailand Adventure',
                              '7 days',
                              '\$1,500',
                              'Nov 15, 2024',
                            ),
                            const SizedBox(height: 16),
                            _buildPlanCard(
                              'European Tour',
                              '14 days',
                              '\$3,200',
                              'Oct 20, 2024',
                            ),
                            const SizedBox(height: 16),
                            _buildPlanCard(
                              'Dubai Experience',
                              '5 days',
                              '\$2,000',
                              'Sep 12, 2024',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bottom CTA
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 32,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A94C4), Color(0xFF0D1C52)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A94C4).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Start Planning Your Next Adventure',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Use our AI planner to create your perfect itinerary',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF1A94C4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Create New Plan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF5D6B78), fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 28,
              color: Color(0xFF1A94C4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF5D6B78), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItem(String title, String date, Color? color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            ),
            child: Icon(Icons.image, color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0D1C52),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
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

  Widget _buildHotelItem(String name, String location, String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF0D1C52),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: Color(0xFF8FA2B4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF8FA2B4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF1A94C4),
                ),
              ),
              const Text(
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF0D1C52),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF8FA2B4),
              ),
              const SizedBox(width: 6),
              Text(
                duration,
                style: const TextStyle(fontSize: 13, color: Color(0xFF5D6B78)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Budget: $budget',
            style: const TextStyle(fontSize: 13, color: Color(0xFF5D6B78)),
          ),
          const SizedBox(height: 8),
          Text(
            'Created: $date',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8FA2B4)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'View Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
