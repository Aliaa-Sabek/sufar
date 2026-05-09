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
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',

            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.home, color: Colors.grey),
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomStepper(currentStep: 1),

            SizedBox(height: 20),
            Text(
              'Booking Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please fill up the blank fields below',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            SizedBox(height: 40),

            // Layout: Image on top/left, Form on bottom/right depending on width
            // For mobile (portrait), likely vertical stack.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                            Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Duration Input
                  Text(
                    'How long you will stay?',
                    style: TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildCounterButton(Icons.remove, () {
                        if (_stayDuration > 1) setState(() => _stayDuration--);
                      }),
                      Expanded(
                        child: Container(
                          height: 44,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
                          alignment: Alignment.center,
                          child: Text(
                            '$_stayDuration Days',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _buildCounterButton(Icons.add, () {
                        setState(() => _stayDuration++);
                      }),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Date Input (Visual Only)
                  Text(
                    'Pick a Date',
                    style: TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : const Color(0xFFF5F6F8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).cardColor,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          '20 Jan - 22 Jan',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Price Summary
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        TextSpan(text: 'You will pay '),
                        TextSpan(
                          text: '\$400 USD\n',
                          style: TextStyle(
                            
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: 'per '),
                        TextSpan(
                          text: '$_stayDuration Days',
                          style: TextStyle(
                            
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

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
                      child: Text(
                        'Next',
                        style: TextStyle(fontSize: 18, color: Theme.of(context).cardColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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
                      child: Text(
                        'Cancel',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
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
