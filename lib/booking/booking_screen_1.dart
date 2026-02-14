import 'package:flutter/material.dart';
import 'booking_stepper.dart';
import 'booking_screen_2.dart';

class BookingPage1 extends StatefulWidget {
  const BookingPage1({super.key});

  @override
  State<BookingPage1> createState() => _BookingPage1State();
}

class _BookingPage1State extends State<BookingPage1> {
  int _stayDuration = 2; // Default 2 days

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
        child: Column(
          children: [
            const CustomStepper(currentStep: 1),

            const SizedBox(height: 20),
            const Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C52),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please fill up the blank fields below',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 40),

            // Layout: Image on top/left, Form on bottom/right depending on width
            // For mobile (portrait), likely vertical stack.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Room Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Image.network(
                        'https://placehold.co/600x400/png', // Placeholder
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Duration Input
                  const Text(
                    'How long you will stay?',
                    style: TextStyle(
                      color: Color(0xFF0D1C52),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildCounterButton(Icons.remove, () {
                        if (_stayDuration > 1) setState(() => _stayDuration--);
                      }),
                      Expanded(
                        child: Container(
                          height: 44,
                          color: const Color(0xFFF5F6F8),
                          alignment: Alignment.center,
                          child: Text(
                            '$_stayDuration Days',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _buildCounterButton(Icons.add, () {
                        setState(() => _stayDuration++);
                      }),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Date Input (Visual Only)
                  const Text(
                    'Pick a Date',
                    style: TextStyle(
                      color: Color(0xFF0D1C52),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1C52),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          '20 Jan - 22 Jan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Price Summary
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        const TextSpan(text: 'You will pay '),
                        const TextSpan(
                          text: '\$400 USD\n',
                          style: TextStyle(
                            color: Color(0xFF0D1C52),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(text: 'per '),
                        TextSpan(
                          text: '$_stayDuration Days',
                          style: const TextStyle(
                            color: Color(0xFF0D1C52),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BookingPage2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: icon == Icons.remove
              ? const Color(0xFFE0E0E0)
              : const Color(0xFF1A94C4),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          color: icon == Icons.remove ? Colors.black54 : Colors.white,
        ),
      ),
    );
  }
}
