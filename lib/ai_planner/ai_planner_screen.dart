import 'package:flutter/material.dart';

class AIPlannerPage extends StatefulWidget {
  const AIPlannerPage({super.key});

  @override
  State<AIPlannerPage> createState() => _AIPlannerPageState();
}

class _AIPlannerPageState extends State<AIPlannerPage> {
  final List<String> _interests = [
    'Beach & Relaxation',
    'Adventure & Sports',
    'Culture & History',
    'Food & Cuisine',
    'Nature & Wildlife',
    'Shopping',
    'Nightlife',
    'Photography',
  ];
  final Set<String> _selectedInterests = {};

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
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.home, color: Colors.grey),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  // Logo & Header
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D4B88),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'AI Travel Planner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C52),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tell us your preferences and let our AI create a personalized itinerary just for you',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 40),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Country / Destination',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Italy, Thailand, Japan',
                                      prefixIcon: const Icon(
                                        Icons.location_on_outlined,
                                        color: Color(0xFF1A94C4),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Budget (USD)',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: 'e.g., 1500',
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                        color: Color(0xFF1A94C4),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF9FAFB),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Duration (days)',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'e.g., 7',
                                prefixIcon: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF1A94C4),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          'Interests (select all that apply)',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _interests.map((interest) {
                            final isSelected = _selectedInterests.contains(
                              interest,
                            );
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedInterests.remove(interest);
                                  } else {
                                    _selectedInterests.add(interest);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.transparent
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1A94C4)
                                        : Colors.grey.shade300,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Text(
                                  interest,
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF1A94C4)
                                        : const Color(0xFF0D1C52),
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Generate Plan',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D4B88),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
