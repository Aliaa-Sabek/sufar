import 'package:flutter/material.dart';
import '../auth/sign_in_screen.dart';
import '../auth/sign_up_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage(
                    imageAsset: 'assets/Group 81.png',
                    titlePrefix: 'Discover\nAmazing',
                    highlightedText: 'Destinations',
                    description:
                        'We believe traveling around the world shouldn\'t be hard.',
                  ),
                  _buildPage(
                    imageAsset: 'assets/Group 416.png',
                    titlePrefix: 'Book',
                    highlightedText: 'Reservations',
                    description:
                        'We are here to help you book tours with locals on-the-go and experience a wonderful trip.',
                  ),
                  _buildPage(
                    imageAsset: 'assets/Group 417.png',
                    titlePrefix: 'Find New',
                    highlightedText: 'Locations',
                    description:
                        'Worried about new places to visit and explore? We\'ve got you covered.',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: _currentPage == index ? 24 : 12,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF1A94C4)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (_currentPage < 2)
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A94C4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignInScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A94C4),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1A94C4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(color: Color(0xFF1A94C4)),
                            ),
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
    );
  }

  Widget _buildPage({
    required String imageAsset,
    required String titlePrefix,
    required String highlightedText,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(imageAsset, height: 300, fit: BoxFit.contain),
          ),
          const SizedBox(height: 40),
          Text(
            titlePrefix,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1C52),
              height: 1.2,
            ),
          ),
          Stack(
            children: [
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                height: 12,
                child: Transform.translate(
                  offset: const Offset(0, 5),
                  child: Container(
                    color: const Color(0xFF1A94C4).withOpacity(0.8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A94C4),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ), // Rough approximation
                ),
                child: Text(
                  highlightedText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
