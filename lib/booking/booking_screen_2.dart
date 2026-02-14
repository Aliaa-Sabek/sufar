import 'package:flutter/material.dart';
import 'booking_stepper.dart';
import 'booking_screen_3.dart';

class BookingPage2 extends StatefulWidget {
  const BookingPage2({super.key});

  @override
  State<BookingPage2> createState() => _BookingPage2State();
}

class _BookingPage2State extends State<BookingPage2> {
  final _formKey = GlobalKey<FormState>();

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
            const CustomStepper(currentStep: 2),

            const SizedBox(height: 20),
            const Text(
              'Enter your information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D1C52),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kindly follow the instructions below',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Small Image + Text
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 60,
                          color: Colors.grey[200],
                          child: Image.network(
                            'https://placehold.co/150x100/png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '2 Days at Blue Origin Fams,',
                              style: TextStyle(
                                color: Color(0xFF0D1C52),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Galle, Sri Lanka',
                              style: TextStyle(
                                color: Color(0xFF0D1C52),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF0D1C52),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: 'Total: '),
                                  TextSpan(
                                    text: '\$400 USD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  color: Color(0xFF0D1C52),
                                  fontSize: 14,
                                ),
                                children: [
                                  TextSpan(text: 'Initial Payment: '),
                                  TextSpan(
                                    text: '\$200',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('First name'),
                        _buildTextField('Enter your first name'),
                        const SizedBox(height: 16),

                        _buildLabel('Last name'),
                        _buildTextField('Enter your last name'),
                        const SizedBox(height: 16),

                        _buildLabel('Email'),
                        _buildTextField('your@email.com'),
                        const SizedBox(height: 16),

                        _buildLabel('Country'),
                        _buildTextField('your country'),
                        const SizedBox(height: 16),

                        _buildLabel('Phone number'),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F6F8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '+20',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: _buildTextField('')),
                          ],
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
                            builder: (context) => const BookingPage3(),
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
                        'Payment',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back
                      },
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0D1C52),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint) {
    return Container(
      height: 50, // Fixed height for visual consistency with design
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
