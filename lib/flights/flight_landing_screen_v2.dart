import 'package:flutter/material.dart';
import 'flight_search_screen.dart';

class FlightLandingPage extends StatelessWidget {
  const FlightLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Search Box
            SizedBox(
              height: 500, // Fixed height for hero
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    height:
                        350, // Image doesn't go full height of container to allow overlap
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Color(0xFF0D4B88)),
                    child: Image.network(
                      'https://placehold.co/1200x600/0D4B88/FFFFFF/png?text=Airplane+Sky', // Placeholder
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Container(color: const Color(0xFF0D4B88)),
                    ),
                  ),

                  // Text Overlay
                  const Positioned(
                    top: 40,
                    right: 40,
                    child: SizedBox(
                      width: 400,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Hey Buddy! Where are you \n'),
                            TextSpan(
                              text: 'Flying',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ' to?'),
                          ],
                        ),
                        style: TextStyle(color: Colors.white, fontSize: 32),
                      ),
                    ),
                  ),

                  // Search Card
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tabs
                          Row(
                            children: [
                              _buildTabItem('Flights', Icons.flight, true),
                              const SizedBox(width: 8),
                              _buildTabItem(
                                'Visa',
                                Icons.description_outlined,
                                false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Radios
                          Row(
                            children: [
                              _buildRadio('Return', true),
                              const SizedBox(width: 16),
                              _buildRadio('One Way', false),
                              const SizedBox(width: 16),
                              _buildRadio('Direct Flights', false),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Search Fields Row
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Responsive switch for mobile
                              if (constraints.maxWidth < 800) {
                                return Column(
                                  children: [
                                    _buildSearchField(
                                      'From',
                                      'United Kingdom (UK)',
                                      Icons.flight_takeoff,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSearchField(
                                      'To',
                                      'Country, City or Airport',
                                      Icons.flight_land,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildSearchField(
                                            'Departure',
                                            '14/01/2025',
                                            null,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildSearchField(
                                            'Return',
                                            '27/01/2025',
                                            null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildSearchField(
                                      'Travelers and Cabin Class',
                                      '1 Adult, Economy',
                                      null,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  const FlightSearchPage(),
                                            ),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF0D1C52,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              return Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildBorderedField(
                                        'From',
                                        'United Kingdom (UK)',
                                        false,
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: _buildBorderedField(
                                        'To',
                                        'Country, City or Airport',
                                        false,
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: _buildBorderedField(
                                        'Departure',
                                        '14/01/2025',
                                        false,
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      child: _buildBorderedField(
                                        'Return',
                                        '27/01/2025',
                                        false,
                                      ),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(
                                      flex: 2,
                                      child: _buildBorderedField(
                                        'Travelers and Cabin Class',
                                        '1 Adult, Economy',
                                        true,
                                      ),
                                    ),

                                    // Search Button
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0D1C52),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (c) =>
                                                  const FlightSearchPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Why Travel Cart Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why Travel Cart',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C52),
                    ),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildFeatureItem(
                            Icons.verified_user_outlined,
                            'ATOL\nProtected Flights',
                            constraints.maxWidth,
                          ),
                          _buildFeatureItem(
                            Icons.sell_outlined,
                            'Best Prices\nGuarentee',
                            constraints.maxWidth,
                          ),
                          _buildFeatureItem(
                            Icons.payment,
                            'Secure\nPayment',
                            constraints.maxWidth,
                            isHighlighted: true,
                          ),
                          _buildFeatureItem(
                            Icons.support_agent,
                            '24/7 Customer\nSupport',
                            constraints.maxWidth,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Promo Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive layout for cards
                  if (constraints.maxWidth < 900) {
                    return Column(
                      children: [
                        _buildPromoCard(
                          'Complete Control',
                          'Easily manage your booking...',
                        ),
                        const SizedBox(height: 16),
                        _buildPromoCard(
                          'Flexible Payment Options',
                          'Get your ticket by paying deposit...',
                        ),
                        const SizedBox(height: 16),
                        _buildPromoCard(
                          'Experience Trust',
                          'For the first time in the travel industry...',
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(
                        child: _buildPromoCard(
                          'Complete Control',
                          'Easily manage your booking from one place. Change, upgrade, choose seats, meals, check-in options and everything related to your add-ons. Plus, track your refund status real time with no stress.',
                          imageUrl:
                              'https://placehold.co/400x300/333/999?text=Cabin',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPromoCard(
                          'Flexible Payment Options',
                          'Get your ticket by paying deposit, no credit card required. Save big by securing your seat in advance and clear the balance before you travel.',
                          imageUrl:
                              'https://placehold.co/400x300/444/AAA?text=Mobile',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPromoCard(
                          'Experience Trust',
                          'For the first time in the travel industry, we offer direct video calls with our experts. Experience transparency and personalized service that ensures your confidence and peace of mind throughout your journey.',
                          imageUrl:
                              'https://placehold.co/400x300/555/BBB?text=Service',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 60),

            // Trustpilot Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star, color: Color(0xFF00B67A)),
                      Text(
                        'Trustpilot',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Don't take our word for it\nSee what our customer\nsay about us:",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C52),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (c, i) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        return Container(
                          width: 280,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.format_quote,
                                color: Color(0xFF00B67A),
                                size: 30,
                              ),
                              const Text(
                                'Best on the market',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                  (i) => const Icon(
                                    Icons.star_rate_rounded,
                                    color: Color(0xFF00B67A),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'I love this product because the support is great. Please ...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String text, IconData icon, bool isSelected) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: const Color(0xFF1A94C4)) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? const Color(0xFF1A94C4) : Colors.grey,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: isSelected ? const Color(0xFF1A94C4) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadio(String text, bool isSelected) {
    return Row(
      children: [
        Icon(
          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isSelected ? Colors.red : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBorderedField(String label, String value, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String label, String value, IconData? icon) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: value,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }

  Widget _buildFeatureItem(
    IconData icon,
    String text,
    double parentWidth, {
    bool isHighlighted = false,
  }) {
    double width = (parentWidth - 48 - (16 * 3)) / 4; // 4 items per row
    if (width < 150) width = (parentWidth - 48 - 16) / 2; // 2 items per row

    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? const Color(0xFF1A94C4)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isHighlighted ? Colors.white : Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isHighlighted ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String title, String description, {String? imageUrl}) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(imageUrl ?? 'https://placehold.co/400x300'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Text(
            'Learn More >',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
