import 'package:flutter/material.dart';
import '../theme/widgets/process_loading_overlay.dart';

class FlightPaymentScreen extends StatefulWidget {
  final String flightNumber;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final int passengers;

  const FlightPaymentScreen({
    super.key,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.passengers,
  });

  @override
  State<FlightPaymentScreen> createState() => _FlightPaymentScreenState();
}

class _FlightPaymentScreenState extends State<FlightPaymentScreen> {
  int _currentStep = 0;
  String? _paymentError;
  String _selectedPaymentMethod = 'card';

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  void _nextStep() {
    if (_currentStep < 2) {
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

  Future<void> _submitPayment() async {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty) {
      setState(() => _paymentError = 'Please fill in all payment details');
      return;
    }

    setState(() => _paymentError = null);

    try {
      await ProcessLoadingOverlay.run(
        context: context,
        title: 'Processing Payment',
        steps: ProcessLoadingPresets.payment,
        task: (ctrl) async {
          await ctrl.jumpTo(0);
          await ctrl.advance();
          await ctrl.advance();

          if (mounted) setState(() => _currentStep = 3);
          return true;
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _paymentError = 'Payment failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentStep < 3 ? _buildAppBar() : null,
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey),
        onPressed: _previousStep,
      ),
      title: Text(
        'Flight Payment',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
      centerTitle: true,
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Flight Details', 'Passenger Info', 'Payment'];
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
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: isDone
                                ? Icon(
                                    Icons.check,
                                    size: 12,
                                    color: const Color(0xFF1A94C4),
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isActive
                                          ? const Color(0xFF1A94C4)
                                          : Colors.grey.shade400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          steps[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: isActive
                                ? const Color(0xFF1A94C4)
                                : Colors.grey,
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (index < steps.length - 1) SizedBox(width: 8),
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
        return _buildSuccessScreen();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    final totalPrice = widget.price * widget.passengers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flight Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Review your flight information',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Flight Number',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        widget.flightNumber,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Passengers',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        '${widget.passengers}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Departure',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.from,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.departureTime,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Icon(
                        Icons.flight_takeoff,
                        color: Color(0xFF1A94C4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Arrival',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.to,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          widget.arrivalTime,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price per passenger'),
                  Text('\$${widget.price}'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of passengers'),
                  Text('${widget.passengers}'),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$$totalPrice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32),
        _buildActionButtons(onNext: _nextStep, nextLabel: 'Continue'),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passenger Information',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Enter your details to complete the booking',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 32),
        _buildInputField(
          'First Name',
          'John',
          Icons.person,
          _firstNameController,
        ),
        SizedBox(height: 16),
        _buildInputField('Last Name', 'Doe', Icons.person, _lastNameController),
        SizedBox(height: 16),
        _buildInputField(
          'Email',
          'john@example.com',
          Icons.email,
          _emailController,
        ),
        SizedBox(height: 16),
        _buildInputField(
          'Phone',
          '+1 234 567 8900',
          Icons.phone,
          _phoneController,
        ),
        SizedBox(height: 32),
        _buildActionButtons(onNext: _nextStep, nextLabel: 'Next'),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Please enter your payment details to complete your booking',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 24),
        // Payment method tabs
        Row(
          children: [
            Expanded(
              child: _paymentTab(
                'Credit / Debit Card',
                Icons.credit_card,
                _selectedPaymentMethod == 'card',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _paymentTab(
                'Bank Transfer',
                Icons.account_balance,
                _selectedPaymentMethod == 'bank',
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        if (_selectedPaymentMethod == 'card') ...[
          _buildInputField(
            'Card Holder Name',
            'John Doe',
            Icons.person,
            _cardHolderController,
          ),
          SizedBox(height: 16),
          _buildInputField(
            'Card Number',
            '1234 5678 9012 3456',
            Icons.credit_card,
            _cardNumberController,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  'Expiry Date',
                  'MM/YY',
                  Icons.calendar_today,
                  _expiryController,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  'CVV',
                  '123',
                  Icons.lock,
                  _cvvController,
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bank Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('Account Name: Sufar Travel'),
                Text('Bank: International Bank'),
                Text('Account Number: 1234567890'),
                Text('Routing Number: 987654321'),
              ],
            ),
          ),
        ],
        SizedBox(height: 24),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.lock, color: Colors.green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Payment',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Your payment is secure and encrypted',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        if (_paymentError != null)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[300]!),
            ),
            child: Text(
              _paymentError!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _submitPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D1C52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Pay \$${widget.price * widget.passengers}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Back'),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 80, color: Colors.green),
          SizedBox(height: 24),
          Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Your flight is confirmed',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Confirmation',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                _buildConfirmationRow(
                  'Booking Ref:',
                  'FL${DateTime.now().millisecond}',
                ),
                _buildConfirmationRow('Flight:', widget.flightNumber),
                _buildConfirmationRow('From:', widget.from),
                _buildConfirmationRow('To:', widget.to),
                _buildConfirmationRow('Passengers:', '${widget.passengers}'),
              ],
            ),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Center(child: Icon(icon, color: Colors.grey, size: 20)),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _paymentTab(String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPaymentMethod = label.contains('Card') ? 'card' : 'bank';
      }),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A94C4) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A94C4) : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 24,
            ),
            SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              nextLabel,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Back'),
          ),
        ),
      ],
    );
  }
}
