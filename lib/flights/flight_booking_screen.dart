import 'package:flutter/material.dart';
import '../models/flight_model.dart';

class FlightBookingPage extends StatefulWidget {
  final FlightModel? selectedFlight;
  final int totalPassengers;

  const FlightBookingPage({
    super.key,
    this.selectedFlight,
    this.totalPassengers = 1,
  });

  @override
  State<FlightBookingPage> createState() => _FlightBookingPageState();
}

class _FlightBookingPageState extends State<FlightBookingPage> {
  // Step 1: Info (Initial State)
  // Step 2: Seat (Triggered by button)
  // Step 3: Payment (Triggered by button)

  bool _isSeatSelection = false;
  bool _isPaymentStep = false;
  bool _isPaymentCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Text(
          _isPaymentStep || _isPaymentCompleted
              ? 'Flights Payment'
              : 'Flights Selection',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: _buildStepper(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
          final padding = EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset);

          // Mobile / small screens: single column to avoid tight horizontal constraints
          if (constraints.maxWidth <= 900) {
            return SingleChildScrollView(
              padding: padding,
              child: _buildMainContent(isMobile: true),
            );
          }

          // Large screens: keep the two-column layout with sidebar
          return SingleChildScrollView(
            padding: padding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildMainContent()),
                SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: _isPaymentStep
                      ? _buildPaymentSidebar()
                      : _buildStandardSidebar(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent({bool isMobile = false}) {
    if (_isPaymentCompleted) return _buildPaymentCompleted();
    if (_isPaymentStep) return _buildPaymentStep();
    if (_isSeatSelection) return _buildSeatSelection();
    return _buildTravelerInfo(isMobile);
  }

  Widget _buildStandardSidebar() {
    return Column(
      children: [
        _buildFlightDetailsCard(),
        SizedBox(height: 24),
        _buildPaymentDetailsCard(),
      ],
    );
  }

  Widget _buildPaymentSidebar() {
    return Column(
      children: [
        // Flight Summary Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'London',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Tue, 15 Jan 2025',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: Color(0xFF1A94C4)),
                  SizedBox(width: 8),
                  Text(
                    'Flight 2',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A94C4),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'CAI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '12:40 PM Terminal 2',
                      style: TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '19:10',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                'Time: 41-30m',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'EgyptAir',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'MS M78',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Price Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              _buildPriceRow('1 Adult', '\$340.00'),
              _buildPriceRow('Taxes & Fees', '\$40.00'),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Total Price',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '\$380.00',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Baggage allowance
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Baggage allowance',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              _buildPriceRow('1 Carry-on bag', '6kg'),
              _buildPriceRow('1 Checked bag', '6kg'),
              const Divider(height: 32),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Change Flight',
                    style: TextStyle(color: Color(0xFF1A94C4)),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Need Help Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A94C4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need Help?',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              _buildIconTextRow(Icons.phone, '+1 (555) 123-4567'),
              SizedBox(height: 12),
              _buildIconTextRow(Icons.headset_mic, '24/7 Customer Support'),
              SizedBox(height: 12),
              _buildIconTextRow(Icons.email, 'Sufar@gmail.com'),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Security Payment Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 48,
                        color: Color(0xFF1A94C4),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Color(0xFF4DB6AC),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          size: 10,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Security Payment',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Your payment is secure and encrypted',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              const Divider(),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'VISA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.8),
                          offset: const Offset(12, 0),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'AMEX',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 10,
                    ),
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF1A94C4),
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.black : Colors.grey[700],
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconTextRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).cardColor),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Theme.of(context).cardColor, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildStepItem('1', 'Flight Selection', true, false),
          _buildStepLine(true),
          _buildStepItem(
            '2',
            'Traveler Information',
            _isPaymentStep || _isPaymentCompleted,
            !_isPaymentStep && !_isPaymentCompleted,
          ),
          _buildStepLine(_isPaymentStep || _isPaymentCompleted),
          _buildStepItem('3', 'Payment', _isPaymentCompleted, _isPaymentStep),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    String num,
    String label,
    bool isCompleted,
    bool isActive,
  ) {
    bool isCurrentOrPast = isActive || isCompleted;

    return Expanded(
      child: Container(
        height: 32,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentOrPast ? const Color(0xFF1A94C4) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isCurrentOrPast
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCompleted && !isActive)
              Icon(Icons.check, color: Theme.of(context).cardColor, size: 14)
            else
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isCurrentOrPast ? Colors.white : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    num,
                    style: TextStyle(
                      color: isCurrentOrPast
                          ? const Color(0xFF1A94C4)
                          : Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isCurrentOrPast ? Colors.white : Colors.grey,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 20,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? const Color(0xFF1A94C4) : Colors.grey[300],
    );
  }

  // --- Payment Step Section ---
  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        Text(
          'Please enter your payment details to complete your booking',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentTabItem(
                      'Credit / Debit Card',
                      Icons.credit_card,
                      true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentTabItem(
                      'PayPal',
                      Icons.paypal_outlined,
                      false,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentTabItem(
                      'Online Banking',
                      Icons.account_balance_outlined,
                      false,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentTabItem(
                      'Pay to Airport',
                      Icons.flight_takeoff,
                      false,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Card Details
              _buildRefinedTextField('Card Number', 'Enter your card number'),
              SizedBox(height: 24),
              _buildRefinedTextField('Card Holder Name', 'Name on card'),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: 14,
                            
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Flexible(
                                      child: Text(
                                        'MM',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'YY',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: _buildRefinedTextField(
                      'CVV',
                      'e.g. 123',
                      isRequired: true,
                      suffixIcon: Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPaymentCompleted = true;
                      _isPaymentStep = false;
                      _isSeatSelection = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A94C4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Pay \$380.00',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Security Banner
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFE0F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      size: 30,
                      color: Color(0xFF1A94C4),
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Security Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Your payment is secure and encrypted',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              const Divider(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaymentLogo(Icons.credit_card, Colors.blue),
                  SizedBox(width: 16),
                  _buildPaymentLogo(Icons.credit_card, Colors.red),
                  SizedBox(width: 16),
                  _buildPaymentLogo(Icons.credit_card, Colors.blue[800]!),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTabItem(String label, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A94C4) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentLogo(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(icon, color: color, size: 30),
    );
  }

  // --- Traveler Info Section ---

  Widget _buildTravelerInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Traveler Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 24),

        // Primary Contact
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Primary Contact',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                ],
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRefinedTextField('Email', '')),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Mobile Number',
                              style: TextStyle(
                                fontSize: 14,
                                
                              ),
                            ),
                            Text('*', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: const [
                                  Text(
                                    '+20',
                                    style: TextStyle(
                                      
                                      fontSize: 13,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (v) {},
                    activeColor: const Color(0xFF1A94C4),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                  Expanded(
                    child: Text(
                      'I do not wish to receive any newsletters about cheap air fares or other offers',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 32),
        Text(
          'Traveler Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 16),

        // Passenger Details
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey[100]!),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Passenger Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Adult (Over 12)',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Text(
                'Title*',
                style: TextStyle(fontSize: 14, color: Color(0xFF0D1C52)),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  _buildCustomRadio('Mr', true),
                  SizedBox(width: 24),
                  _buildCustomRadio('Mrs/Ms', false),
                ],
              ),
              SizedBox(height: 24),
              if (isMobile) ...[
                _buildRefinedTextField('First Name', ''),
                SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Nationality',
                          style: TextStyle(
                            fontSize: 14,
                            
                          ),
                        ),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: const [
                          Text('🇬🇧', style: TextStyle(fontSize: 18)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'United Kingdom',
                              style: TextStyle(
                                fontSize: 14,
                                
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildRefinedTextField('Last Name', ''),
                SizedBox(height: 24),
                _buildDateInputSection('Passport or ID Expiration Date'),
                SizedBox(height: 24),
                _buildDateInputSection('Date of Birth'),
                SizedBox(height: 24),
                _buildRefinedTextField('Passport Or ID Number', ''),
                SizedBox(height: 32),
                Column(
                  children: [
                    _buildRefinedBaggageCard(
                      'Personal item',
                      Icons.work_outline,
                      '\n',
                      false,
                    ),
                    SizedBox(height: 16),
                    _buildRefinedBaggageCard(
                      'Hand baggage',
                      Icons.backpack_outlined,
                      '1 x 7 kg',
                      false,
                    ),
                    SizedBox(height: 16),
                    _buildRefinedBaggageCard(
                      'Checked Baggage',
                      Icons.luggage_outlined,
                      '1 x 25 kg',
                      true,
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRefinedTextField('First Name', '')),
                    SizedBox(width: 16),
                    Expanded(child: _buildRefinedTextField('Last Name', '')),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Text(
                                'Nationality',
                                style: TextStyle(
                                  fontSize: 14,
                                  
                                ),
                              ),
                              Text('*', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.flag, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'United Kingdom',
                                    style: TextStyle(
                                      fontSize: 14,
                                      
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: _buildDateInputSection('Date of Birth')),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildRefinedTextField(
                        'Passport Or ID Number',
                        '',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDateInputSection(
                        'Passport or ID Expiration Date',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),

                Text(
                  'Baggage',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildRefinedBaggageCard(
                        'Personal item',
                        Icons.work_outline,
                        '\n',
                        false,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildRefinedBaggageCard(
                        'Hand baggage',
                        Icons.backpack_outlined,
                        '1 x 7 kg',
                        false,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildRefinedBaggageCard(
                        'Checked Baggage',
                        Icons.luggage_outlined,
                        '1 x 25 kg',
                        true,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 32),
        if (isMobile) ...[
          _buildFlightDetailsCard(),
          SizedBox(height: 24),
          _buildPaymentDetailsCard(),
          SizedBox(height: 32),
        ],
        Center(
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.add_circle, size: 18),
              label: Text('Add Another Passenger'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A94C4),
                side: BorderSide(color: Color(0xFFE0E0E0)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[200]!),
                ),
                child: Text(
                  '← Back',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isPaymentStep = true;
                    _isSeatSelection = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A94C4),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Payment →',
                  style: TextStyle(color: Theme.of(context).cardColor),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Seat Selection Section ---

  Widget _buildSeatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Sitting',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),

        // Header Info
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Seating 1 of 3',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                    Text(
                      'Departure',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'LHE Lahore (T4) - FRA Frankfurt am Main (T2)',
                      style: TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'AirBlue SV737',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Selected 2 Out of 2 Seats',
                    style: TextStyle(color: Colors.green, fontSize: 10),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Legend (wraps on small screens)
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _buildLegendItem(Colors.blue[100]!, 'Available Seat'),
            _buildLegendItem(Colors.blue[300]!, 'With Conditions'),
            _buildLegendItem(Colors.blue[700]!, 'Extra Leg Room'),
            _buildLegendItem(Colors.green, 'Selected Seat'),
            _buildLegendItem(Colors.grey[300]!, 'Booked Seat'),
          ],
        ),

        SizedBox(height: 40),

        // Seat Grid
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _buildSeatMapHeader(),
                SizedBox(height: 16),
                for (int i = 2; i <= 11; i++) _buildSeatRow(i),
                SizedBox(height: 24),
                _buildSeatRow(12, isExit: true), // Exit row / gap
                SizedBox(height: 24),
                _buildSeatMapHeader(), // Repeat header
                for (int i = 2; i <= 6; i++) _buildSeatRow(i),
              ],
            ),
          ),
        ),

        SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSeatSelection = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
              ),
              child: Text('Back', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSeatSelection = false;
                  _isPaymentStep = true;
                  _isPaymentCompleted = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                padding: EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: Text(
                'Continue to Payment',
                style: TextStyle(color: Theme.of(context).cardColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentCompleted() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Completed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Your booking has been successfully completed.',
          style: TextStyle(color: Colors.grey[700], fontSize: 12),
        ),
        SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payment successful. Thank you for booking with Sufar.',
                  style: TextStyle(
                    
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A94C4),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Back to Home',
              style: TextStyle(color: Theme.of(context).cardColor),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _isPaymentCompleted = false;
                _isPaymentStep = false;
                _isSeatSelection = false;
              });
            },
            child: Text('Book Another Flight'),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Flexible(child: Text(label, style: TextStyle(fontSize: 10))),
      ],
    );
  }

  Widget _buildSeatMapHeader() {
    return SizedBox(
      width: 400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text('A   B   C'),
          SizedBox(width: 40),
          Text('D   E   F'),
          SizedBox(width: 40),
          Text('H   J   K'),
        ],
      ),
    );
  }

  Widget _buildSeatRow(int rowNum, {bool isExit = false}) {
    if (isExit) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Text('Exit'),
          ),
          SizedBox(width: 200),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.grey[100],
            child: Text('Exit'),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: SizedBox(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildSeat(rowNum, 'A'),
                _buildSeat(rowNum, 'B'),
                _buildSeat(rowNum, 'C'),
              ],
            ),
            Text(
              '$rowNum',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Row(
              children: [
                _buildSeat(rowNum, 'D'),
                _buildSeat(rowNum, 'E'),
                _buildSeat(rowNum, 'F'),
              ],
            ),
            Text(
              '$rowNum',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Row(
              children: [
                _buildSeat(rowNum, 'H'),
                _buildSeat(rowNum, 'J'),
                _buildSeat(rowNum, 'K'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat(int row, String col) {
    Color color = Colors.blue[100]!;
    if (row == 5 && col == 'K') color = Colors.green; // Selected demo
    if (row == 5 && col == 'J') color = Colors.green; // Selected demo

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
          ),
          SizedBox(height: 2),
          Text('£34', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- Sidebar Widgets ---

  Widget _buildFlightDetailsCard() {
    final flight = widget.selectedFlight;
    String airline = flight?.airline ?? 'airblue';
    String fNum = flight?.flightNumber ?? 'AirBlue SV737';
    String from = flight?.originCode ?? 'LHE';
    String to = flight?.destinationCode ?? 'FRA';

    int durMins = flight?.durationMinutes ?? 825;
    String dur = '${durMins ~/ 60}h ${durMins % 60}m';

    String depDate = 'Tue, 21 Jan 2025';
    String depTime = '20:50';
    String arrTime = '06:35';

    if (flight?.departureDatetime != null) {
      final dt = flight!.departureDatetime!;
      depDate = '${dt.day}/${dt.month}/${dt.year}';
      depTime =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    if (flight?.arrivalDatetime != null) {
      final at = flight!.arrivalDatetime!;
      arrTime =
          '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Flight details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          _buildRefinedLeg(
            'Departure',
            depDate,
            depTime,
            arrTime,
            from,
            to,
            dur,
            airline: airline,
            flightNumber: fNum,
          ),
          const Divider(height: 1),
          _buildRefinedLeg(
            'Return',
            'Wed, 29 Jan 2025',
            arrTime,
            depTime,
            to,
            from,
            dur,
            hasTransfer: false,
            airline: airline,
            flightNumber: fNum,
          ),
        ],
      ),
    );
  }

  Widget _buildRefinedLeg(
    String type,
    String date,
    String time1,
    String time2,
    String l1,
    String l2,
    String dur, {
    bool hasTransfer = false,
    String airline = 'airblue',
    String flightNumber = 'AirBlue SV737',
  }) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.flight_takeoff,
                size: 16,
                color: Color(0xFF1A94C4),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  airline,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  flightNumber,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Flexible(
                child: Text(
                  '$time1 – $time2',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '($dur)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            '$l1 – $l2',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (hasTransfer) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Flexible(
                    child: Text(
                      '30min',
                      style: TextStyle(
                        
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Transfer and flight change',
                      style: TextStyle(color: Colors.red, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  size: 16,
                  color: Color(0xFF1A94C4),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'airblue',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'AirBlue SV737',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '07:05 – 09:05',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(11h 45m)',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'LHE Lahore (T4) – DXE Dubai (T2)',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    double price = widget.selectedFlight?.priceEGP ?? 340.0;
    int pax = widget.totalPassengers;
    double total = price * pax;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A94C4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: TextStyle(
              color: Theme.of(context).cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 24),
          _buildPaymentRow('${pax}x Passenger', '£${total.toStringAsFixed(0)}'),
          _buildPaymentRow('1x Checked Baggage', '£34'),
          _buildPaymentRow('2x Hand Baggage', 'Included'),
          SizedBox(height: 24),
          Container(height: 1, color: Theme.of(context).cardColor.withOpacity(0.2)),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount to pay',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '£${(total + 34).toStringAsFixed(0)}',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Theme.of(context).cardColor, fontSize: 14),
            ),
          ),
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).cardColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- Refined Helpers ---

  Widget _buildRefinedTextField(
    String label,
    String hint, {
    bool isRequired = true,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Color(0xFF0D1C52)),
            ),
            if (isRequired)
              Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomRadio(String label, bool isSelected) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? const Color(0xFF1A94C4) : Colors.grey[400]!,
              width: isSelected ? 6 : 2,
            ),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDateInputSection(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Color(0xFF0D1C52)),
            ),
            Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'YYYY',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Month',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'DD',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefinedBaggageCard(
    String title,
    IconData icon,
    String detail,
    bool isNotIncluded,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isNotIncluded ? Colors.white : const Color(0xFF1A94C4),
                  border: isNotIncluded
                      ? Border.all(color: Colors.redAccent)
                      : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isNotIncluded ? 'Not Included' : 'Included',
                  style: TextStyle(
                    fontSize: 10,
                    color: isNotIncluded ? Colors.redAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isNotIncluded) ...[
                SizedBox(width: 12),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A94C4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '£34 +',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 24),
          Icon(icon, size: 40, color: const Color(0xFF1A94C4)),
          SizedBox(height: 12),
          Text(
            detail,
            style: TextStyle(
              fontSize: 10,
              
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.info, size: 14, color: Colors.black87),
            ],
          ),
        ],
      ),
    );
  }
}
