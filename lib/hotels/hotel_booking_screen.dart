import 'package:flutter/material.dart';

class HotelBookingScreen extends StatelessWidget {
  const HotelBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Booking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1C52),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.hotel, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Hotel Booking Coming Soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
