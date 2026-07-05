import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import 'booking_stepper.dart';
import 'booking_screen_3.dart';

class BookingPage2 extends StatefulWidget {
  final String? hotelId;
  final String? roomId;
  final String? checkIn;
  final String? checkOut;
  final int? totalGuests;
  final double? totalPrice;
  final String? hotelName;
  final String? hotelCity;
  final int? stayDays;

  const BookingPage2({
    super.key,
    this.hotelId,
    this.roomId,
    this.checkIn,
    this.checkOut,
    this.totalGuests,
    this.totalPrice,
    this.hotelName,
    this.hotelCity,
    this.stayDays,
  });

  @override
  State<BookingPage2> createState() => _BookingPage2State();
}

class _BookingPage2State extends State<BookingPage2> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _countryController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _countryController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    // Prepare guest information
    final guestInfo = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'country': _countryController.text,
      'phone': '+20${_phoneController.text}',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage3(
          hotelId: widget.hotelId,
          roomId: widget.roomId,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          totalGuests: widget.totalGuests,
          guestInfo: guestInfo.cast<String, String>(),
          totalPrice: widget.totalPrice,
          hotelName: widget.hotelName,
          hotelCity: widget.hotelCity,
          stayDays: widget.stayDays,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.stayDays ?? 2;
    final total = widget.totalPrice ?? 0;
    final initialPayment = total / 2;
    final hotelName = widget.hotelName ?? 'Your hotel';
    final hotelCity = widget.hotelCity ?? '';
    final dateRange = (widget.checkIn != null && widget.checkOut != null)
        ? '${Booking.formatDisplayDate(widget.checkIn!)} – ${Booking.formatDisplayDate(widget.checkOut!)}'
        : '';

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
            const CustomStepper(currentStep: 2),

            SizedBox(height: 20),
            Text(
              'Enter your information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kindly follow the instructions below',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),

            SizedBox(height: 40),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                          color: const Color(0xFFE3F2FD),
                          child: Icon(Icons.hotel, color: Color(0xFF1A94C4), size: 28),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$days Night${days == 1 ? '' : 's'} at $hotelName',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hotelCity.isNotEmpty)
                              Text(
                                hotelCity,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (dateRange.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text(
                                dateRange,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (widget.totalGuests != null) ...[
                              SizedBox(height: 4),
                              Text(
                                '${widget.totalGuests} guest${widget.totalGuests == 1 ? '' : 's'}',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            SizedBox(height: 8),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14),
                                children: [
                                  TextSpan(text: 'Total: '),
                                  TextSpan(
                                    text: '\$${total.toStringAsFixed(0)} USD',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14),
                                children: [
                                  TextSpan(text: 'Initial Payment: '),
                                  TextSpan(
                                    text: '\$${initialPayment.toStringAsFixed(0)}',
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

                  SizedBox(height: 30),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('First name'),
                        _buildTextField(
                          _firstNameController,
                          'Enter your first name',
                          'Please enter your first name',
                        ),
                        SizedBox(height: 16),

                        _buildLabel('Last name'),
                        _buildTextField(
                          _lastNameController,
                          'Enter your last name',
                          'Please enter your last name',
                        ),
                        SizedBox(height: 16),

                        _buildLabel('Email'),
                        _buildTextField(
                          _emailController,
                          'your@email.com',
                          'Please enter a valid email',
                          isEmail: true,
                        ),
                        SizedBox(height: 16),

                        _buildLabel('Country'),
                        _buildTextField(
                          _countryController,
                          'your country',
                          'Please enter your country',
                        ),
                        SizedBox(height: 16),

                        _buildLabel('Phone number'),
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 50,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[850]!
                                    : const Color(0xFFF5F6F8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '+20',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildTextField(
                                _phoneController,
                                '',
                                'Please enter your phone number',
                              ),
                            ),
                          ],
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
                      onPressed: _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Payment',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    String errorMsg, {
    bool isEmail = false,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]!
            : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
          }
          if (isEmail &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
