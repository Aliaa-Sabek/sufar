import 'package:flutter/material.dart';
import 'booking_stepper.dart';

class BookingPage4 extends StatelessWidget {
  const BookingPage4({super.key});

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
            const CustomStepper(currentStep: 4), // All completed or step 4

            const SizedBox(height: 60),

            const Text(
              'Yay! Payment Completed',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C52),
              ),
            ),

            const SizedBox(height: 40),

            // Success Image
            SizedBox(
              height: 250,
              child: Image.network(
                'https://placehold.co/400x300/png?text=Success',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.check_circle,
                  size: 100,
                  color: Color(0xFF1A94C4),
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Please check your email & phone Message.\nWe have sent all the information',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),

            const SizedBox(height: 30),

            TextButton(
              onPressed: () {
                // Navigate back to the start and clear stack
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  color: Color(0xFF1A94C4),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
