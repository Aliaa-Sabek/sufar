import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import 'booking_stepper.dart';
import 'booking_screen_4.dart';
import '../services/api_service.dart';
import '../theme/widgets/process_loading_overlay.dart';

class BookingPage3 extends StatefulWidget {
  final String? hotelId;
  final String? roomId;
  final String? checkIn;
  final String? checkOut;
  final int? totalGuests;
  final Map<String, String>? guestInfo;
  final double? totalPrice;
  final String? hotelName;
  final String? hotelCity;
  final int? stayDays;

  const BookingPage3({
    super.key,
    this.hotelId,
    this.roomId,
    this.checkIn,
    this.checkOut,
    this.totalGuests,
    this.guestInfo,
    this.totalPrice,
    this.hotelName,
    this.hotelCity,
    this.stayDays,
  });

  @override
  State<BookingPage3> createState() => _BookingPage3State();
}

class _BookingPage3State extends State<BookingPage3> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _cardHolderController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all payment details')),
      );
      return;
    }

    try {
      await ProcessLoadingOverlay.run(
        context: context,
        title: 'Processing Payment',
        steps: ProcessLoadingPresets.hotelBooking,
        task: (ctrl) async {
          await ctrl.jumpTo(0);

          String? bookingId;

          if (widget.hotelId != null &&
              widget.roomId != null &&
              widget.checkIn != null &&
              widget.checkOut != null &&
              widget.guestInfo != null) {
            await ctrl.advance();

            final bookingResponse = await ApiService.bookHotel(
              hotelId: widget.hotelId!,
              roomId: widget.roomId!,
              checkIn: widget.checkIn!,
              checkOut: widget.checkOut!,
              totalGuests: widget.totalGuests ?? 1,
              guestInfo: widget.guestInfo!,
            );

            if (bookingResponse['success'] == false ||
                bookingResponse['error'] != null) {
              throw Exception(
                bookingResponse['error'] ?? 'Failed to create booking',
              );
            }

            bookingId =
                bookingResponse['data']?['_id'] ?? bookingResponse['_id'];
          }

          await ctrl.advance();

          if (bookingId == null) {
            throw Exception('Could not retrieve booking ID');
          }

          final paymentResponse = await ApiService.payBooking(bookingId);

          if (paymentResponse['success'] == false ||
              paymentResponse['error'] != null) {
            throw Exception(paymentResponse['error'] ?? 'Payment failed');
          }

          await ctrl.advance();
          return true;
        },
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BookingPage4()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            const CustomStepper(currentStep: 3),

            SizedBox(height: 20),
            Text(
              'Payment',
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
                  // Summary Text Only (as per design)
                  Text(
                    '$days Night${days == 1 ? '' : 's'} at $hotelName',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hotelCity.isNotEmpty)
                    Text(
                      hotelCity,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  if (dateRange.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      dateRange,
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                  if (widget.totalGuests != null) ...[
                    SizedBox(height: 4),
                    Text(
                      '${widget.totalGuests} guest${widget.totalGuests == 1 ? '' : 's'}',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Card Number'),
                        _buildTextField(
                          _cardNumberController,
                          'Enter your card number',
                          'Please enter a valid card number',
                        ),
                        SizedBox(height: 16),

                        _buildLabel('Card Holder Name'),
                        _buildTextField(
                          _cardHolderController,
                          'Enter card holder name',
                          'Please enter card holder name',
                        ),
                        SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Exp Date'),
                                  _buildTextField(
                                    _expiryController,
                                    'MM/YY',
                                    'Please enter expiry date',
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('CVV'),
                                  _buildTextField(
                                    _cvvController,
                                    'XXX',
                                    'Please enter CVV',
                                  ),
                                ],
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
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Pay \$${total.toStringAsFixed(0)} USD',
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
                      onPressed: () => Navigator.pop(context),
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
    String errorMsg,
  ) {
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
        enabled: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMsg;
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
