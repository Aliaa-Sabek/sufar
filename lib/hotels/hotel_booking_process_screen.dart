import 'package:flutter/material.dart';
import 'package:sufar_project/models/hotel_model.dart';
import 'package:sufar_project/services/api_service.dart';

class HotelBookingProcessScreen extends StatefulWidget {
  final Hotel hotel;
  final String roomTitle;
  final int pricePerNight;

  const HotelBookingProcessScreen({
    super.key,
    required this.hotel,
    required this.roomTitle,
    required this.pricePerNight,
  });

  @override
  State<HotelBookingProcessScreen> createState() =>
      _HotelBookingProcessScreenState();
}

class _HotelBookingProcessScreenState extends State<HotelBookingProcessScreen> {
  int _currentStep = 0;
  int _days = 2;
  bool _isBookingLoading = false;
  String? _bookingError;

  // Check-in date (default: today)
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));

  DateTime get _checkOut => _checkIn.add(Duration(days: _days));

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// Calls the real Backend booking API
  Future<void> _submitBooking() async {
    setState(() {
      _isBookingLoading = true;
      _bookingError = null;
    });
    try {
      final result = await ApiService.bookHotel(
        hotelId: widget.hotel.id,
        roomId: widget.hotel.id, // Use hotel ID as room ID if no room model
        checkIn: _checkIn.toIso8601String().substring(0, 10),
        checkOut: _checkOut.toIso8601String().substring(0, 10),
        totalGuests: 1,
        guestInfo: {
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'email': _emailController.text.trim(),
          'country': _countryController.text.trim(),
          'phone': _phoneController.text.trim(),
        },
      );

      if (result['success'] == true || result['booking'] != null || result['_id'] != null) {
        if (mounted) setState(() => _currentStep = 3);
      } else {
        final msg = result['message'] ?? result['error'] ?? 'Booking failed. Please try again.';
        if (mounted) setState(() => _bookingError = msg.toString());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _bookingError = 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isBookingLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentStep < 3
          ? _buildAppBar()
          : null, // No app bar on success screen
      body: SafeArea(
        child: Column(
          children: [
            if (_currentStep < 3) _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: _buildCurrentStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.0),
        child: Image.asset(
          'assets/Sufar Logo Blue.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
        ),
      ),
      leadingWidth: 100,
      actions: [
        IconButton(
          icon: Icon(Icons.menu, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: Colors.grey),
          onPressed: () {},
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Booking Info', 'Your Details', 'Payment'];
    return Container(
      color: Theme.of(context).cardColor,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isDone = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 34,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF1A94C4)
                          : isDone
                          ? const Color(0xFFE0F4FD)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(17),
                      border: isDone
                          ? Border.all(
                              color: const Color(0xFF1A94C4),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : isDone
                                ? const Color(0xFF1A94C4)
                                : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isDone
                                ? Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Theme.of(context).cardColor,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isActive
                                          ? const Color(0xFF1A94C4)
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            steps[index],
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive
                                  ? Colors.white
                                  : isDone
                                  ? const Color(0xFF1A94C4)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 14,
                    height: 2,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    color: isDone
                        ? const Color(0xFF1A94C4)
                        : Colors.grey.shade200,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    final totalPrice = widget.pricePerNight * _days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Booking Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Please fill up the blank fields below',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.hotel.imageUrl.isNotEmpty
                ? widget.hotel.imageUrl
                : 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[200],
              child: Icon(Icons.hotel, color: Colors.grey, size: 40),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.roomTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                
                fontSize: 14,
              ),
            ),
            Text(
              widget.hotel.city,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'How long you will stay?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (_days > 1) {
                    setState(() => _days--);
                  }
                },
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.remove, color: Theme.of(context).cardColor),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_days Days',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _days++);
                },
                child: Container(
                  width: 48,
                  decoration: BoxDecoration(
                    color: Color(0xFF1A94C4),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Center(
                    child: Icon(Icons.add, color: Theme.of(context).cardColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pick a Date',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              
              fontSize: 13,
            ),
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.calendar_month,
                    color: Theme.of(context).cardColor,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '20 Jan - ${20 + _days} Jan', // Mock date string
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey),
              children: [
                TextSpan(text: 'You will pay '),
                TextSpan(
                  text: '\$$totalPrice USD ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                TextSpan(text: '\nper '),
                TextSpan(
                  text: '$_days Days',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        _buildActionButtons(onNext: _nextStep, nextLabel: 'Next'),
      ],
    );
  }

  Widget _buildStep2() {
    final totalPrice = widget.pricePerNight * _days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Enter your information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Kindly follow the instructions below',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 32),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            widget.hotel.imageUrl.isNotEmpty
                ? widget.hotel.imageUrl
                : 'https://images.unsplash.com/photo-1566073771259-6a8506099945',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[200],
              child: Icon(Icons.hotel, color: Colors.grey, size: 40),
            ),
          ),
        ),
        SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '$_days Days at ${widget.hotel.name},\n${widget.hotel.city}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              
              height: 1.5,
            ),
          ),
        ),
        SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Total: \$$totalPrice USD',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              
            ),
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Initial Payment: \$${totalPrice ~/ 2}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              
            ),
          ),
        ),
        SizedBox(height: 32),
        _buildTextField(
          'First name',
          'Enter your first name',
          _firstNameController,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Last name',
          'Enter your last name',
          _lastNameController,
        ),
        SizedBox(height: 16),
        _buildTextField('Email', 'your@email.com', _emailController),
        SizedBox(height: 16),
        _buildTextField('Country', 'your country', _countryController),
        SizedBox(height: 16),
        _buildPhoneField(),
        SizedBox(height: 32),
        _buildActionButtons(onNext: _nextStep, nextLabel: 'Next'),
      ],
    );
  }

  Widget _buildStep3() {
    final totalPrice = widget.pricePerNight * _days;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Please enter your payment details to complete your booking',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 24),

        // Summary card
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F8FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF1A94C4).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$_days Days at ${widget.hotel.name}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$$totalPrice USD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A94C4),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Initial Payment (50%)',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  Text(
                    '\$${totalPrice ~/ 2} USD',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Payment method tabs
        Row(
          children: [
            _paymentTab('Credit / Debit Card', Icons.credit_card, true),
            SizedBox(width: 8),
            _paymentTab('Bank Transfer', Icons.account_balance, false),
          ],
        ),
        SizedBox(height: 24),

        // Card fields
        _buildTextField(
          'Card Number',
          'Enter your card number',
          _firstNameController,
        ),
        SizedBox(height: 16),
        _buildTextField(
          'Card Holder Name',
          'Name on card',
          _lastNameController,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Expiry Date',
                'MM / YY',
                _emailController,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildTextField('CVV', 'e.g. 123', _countryController),
            ),
          ],
        ),
        SizedBox(height: 24),

        // Security banner
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.security,
                  color: Color(0xFF1A94C4),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Payment',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Your payment is secure and encrypted',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),
        if (_bookingError != null)
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              _bookingError!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        _buildActionButtons(
          onNext: _isBookingLoading ? () {} : _submitBooking,
          nextLabel: _isBookingLoading ? 'Processing...' : 'Pay \$$totalPrice USD',
        ),
      ],
    );
  }

  Widget _paymentTab(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A94C4) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A94C4) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Yay! Payment Completed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              
            ),
          ),
          SizedBox(height: 40),
          // Placeholder for the illustration
          Container(
            height: 200,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Icon(
                Icons.receipt_long,
                size: 80,
                color: Color(0xFF1A94C4),
              ),
            ),
          ),
          SizedBox(height: 40),
          Text(
            'Please check your email & phone\nMessage.\nWe have sent all the Information',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 60),
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              'Back to Home',
              style: TextStyle(
                color: Color(0xFF1A94C4),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    
                  ),
                  SizedBox(width: 4),
                  Text(
                    '+20',
                    style: TextStyle( fontSize: 13),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons({
    required VoidCallback onNext,
    required String nextLabel,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A94C4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              nextLabel,
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _previousStep,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentStep == 0 ? 'Cancel' : '← Back',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
