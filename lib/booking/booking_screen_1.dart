import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import 'booking_stepper.dart';
import 'booking_screen_2.dart';

class BookingPage1 extends StatefulWidget {
  final String? hotelId;
  final String? roomId;
  final int? totalGuests;
  final double? totalPrice;
  final String? hotelName;
  final String? hotelCity;
  final double? pricePerNight;

  const BookingPage1({
    super.key,
    this.hotelId,
    this.roomId,
    this.totalGuests,
    this.totalPrice,
    this.hotelName,
    this.hotelCity,
    this.pricePerNight,
  });

  @override
  State<BookingPage1> createState() => _BookingPage1State();
}

class _BookingPage1State extends State<BookingPage1> {
  int _stayDuration = 2;
  int _guests = 1;
  late DateTime _checkIn;

  DateTime get _checkOut => DateTime(
        _checkIn.year,
        _checkIn.month,
        _checkIn.day + _stayDuration,
      );

  double get _nightlyRate =>
      widget.pricePerNight ?? widget.totalPrice ?? 0;

  double get _totalAmount => _nightlyRate * _stayDuration;

  String get _dateRangeLabel =>
      '${Booking.formatDisplayDate(_checkIn.toIso8601String())} – '
      '${Booking.formatDisplayDate(_checkOut.toIso8601String())}';

  @override
  void initState() {
    super.initState();
    _guests = widget.totalGuests ?? 1;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    _checkIn = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }

  Future<void> _pickCheckInDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Select check-in date',
    );
    if (picked != null) {
      setState(() {
        _checkIn = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  void _changeStay(int delta) {
    setState(() => _stayDuration = (_stayDuration + delta).clamp(1, 30));
  }

  void _changeGuests(int delta) {
    setState(() => _guests = (_guests + delta).clamp(1, 8));
  }

  void _proceedToBooking() {
    if (_nightlyRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid price for this booking.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage2(
          hotelId: widget.hotelId,
          roomId: widget.roomId,
          checkIn: _checkIn.toIso8601String().split('T').first,
          checkOut: _checkOut.toIso8601String().split('T').first,
          totalGuests: _guests,
          totalPrice: _totalAmount,
          hotelName: widget.hotelName,
          hotelCity: widget.hotelCity,
          stayDays: _stayDuration,
        ),
      ),
    );
  }

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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Choose your dates, guests, and stay length',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: const Color(0xFFE3F2FD),
                      child: Icon(
                        Icons.hotel,
                        size: 64,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                  ),
                  if (widget.hotelName != null) ...[
                    SizedBox(height: 12),
                    Text(
                      widget.hotelName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (widget.hotelCity != null)
                      Text(
                        widget.hotelCity!,
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                  SizedBox(height: 30),
                  Text(
                    'How long will you stay?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildCounterButton(Icons.remove, () => _changeStay(-1)),
                      Expanded(
                        child: Container(
                          height: 44,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]!
                              : const Color(0xFFF5F6F8),
                          alignment: Alignment.center,
                          child: Text(
                            '$_stayDuration Night${_stayDuration == 1 ? '' : 's'}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _buildCounterButton(Icons.add, () => _changeStay(1)),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Guests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildCounterButton(Icons.remove, () => _changeGuests(-1)),
                      Expanded(
                        child: Container(
                          height: 44,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[850]!
                              : const Color(0xFFF5F6F8),
                          alignment: Alignment.center,
                          child: Text(
                            '$_guests Guest${_guests == 1 ? '' : 's'}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      _buildCounterButton(Icons.add, () => _changeGuests(1)),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Check-in & Check-out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: _pickCheckInDate,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]!
                            : const Color(0xFFF5F6F8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Color(0xFF1A94C4),
                            size: 16,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _dateRangeLabel,
                              style: TextStyle(fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.edit, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to change check-in date',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 30),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                      children: [
                        TextSpan(text: 'You will pay '),
                        TextSpan(
                          text: '\$${_totalAmount.toStringAsFixed(0)} USD\n',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'for '),
                        TextSpan(
                          text:
                              '$_stayDuration night${_stayDuration == 1 ? '' : 's'} · $_guests guest${_guests == 1 ? '' : 's'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _proceedToBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A94C4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Next',
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
