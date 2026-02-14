import 'package:flutter/material.dart';

class ChatBotPage extends StatelessWidget {
  const ChatBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    // For simplicity, we'll design a layout that works best on mobile but mimics the desktop split via a bottom sheet or just stacking if needed.
    // Given the screenshot is desktop, I'll build a responsive-ish view.
    return Scaffold(
      backgroundColor: Colors.white, // Background behind chat
      appBar: AppBar(
        title: const Text('Chat Bot', style: TextStyle(color: Colors.grey)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Chat Area (Taking up most space)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Header Banner
                Container(
                  color: const Color(0xFF0D4B88),
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Sufar AI Assistant',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Always here to help',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chat Messages
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE0F7FA),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Color(0xFF1A94C4),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sufar AI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A94C4),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Hello! I'm Sufar AI, your personal travel assistant. How can I help you plan your journey today?",
                                    style: TextStyle(color: Color(0xFF0D1C52)),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      '07:38 PM',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Input Area
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Type your message...',
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A94C4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sidebar (Visible on larger screens, strictly following screenshot layout)
          // Ideally this should be hidden/drawer on mobile.
          if (MediaQuery.of(context).size.width >
              800) // Simple responsive check
            Container(
              width: 350,
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1C52),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildQuickAction(
                            Icons.location_on_outlined,
                            'Find Destinations',
                          ),
                          const SizedBox(height: 8),
                          _buildQuickAction(
                            Icons.flight_takeoff,
                            'Search Flights',
                          ),
                          const SizedBox(height: 8),
                          _buildQuickAction(
                            Icons.hotel_outlined,
                            'Book Hotels',
                          ),
                          const SizedBox(height: 8),
                          _buildQuickAction(
                            Icons.description_outlined,
                            'Visa Info',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A94C4), Color(0xFF0D4B88)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Pro Tips',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildProTip('Be specific about your preferences'),
                          _buildProTip('Mention your budget range'),
                          _buildProTip('Share your travel dates'),
                          _buildProTip('Ask follow-up questions'),
                          _buildProTip('Use quick actions for faster help'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Need More Help?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1C52),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Connect with our travel experts for personalized assistance.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A94C4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Contact Support',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Example Questions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D1C52),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildExampleQuestion(
                            "What's the best time to visit Japan?",
                          ),
                          const SizedBox(height: 8),
                          _buildExampleQuestion(
                            "I have \$2000 for a week trip",
                          ),
                          const SizedBox(height: 8),
                          _buildExampleQuestion(
                            "Do I need a visa for Thailand?",
                          ),
                        ],
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

  Widget _buildQuickAction(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1A94C4), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0D1C52),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleQuestion(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1A94C4),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
