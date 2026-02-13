import 'package:flutter/material.dart';

class FlightBookingPage extends StatefulWidget {
  const FlightBookingPage({super.key});

  @override
  State<FlightBookingPage> createState() => _FlightBookingPageState();
}

class _FlightBookingPageState extends State<FlightBookingPage> {
  // Step 1: Info (Initial State)
  // Step 2: Seat (Triggered by button)
  // Step 3: Payment (Triggered by button)

  bool _isSeatSelection = false;
  bool _isPaymentStep = false;
  String _selectedGender = 'Mr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Image.asset(
              'assets/Sufar Logo Blue.png',
              height: 24,
              errorBuilder: (c, e, s) =>
                  const Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildStepper(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Side: Content
              Expanded(flex: 2, child: _buildMainContent()),

              const SizedBox(width: 24),

              // Right Side: Sidebar
              if (MediaQuery.of(context).size.width > 900)
                Expanded(
                  flex: 1,
                  child: _isPaymentStep
                      ? _buildPaymentSidebar()
                      : _buildStandardSidebar(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isPaymentStep) return _buildPaymentStep();
    if (_isSeatSelection) return _buildSeatSelection();
    return _buildTravelerInfo();
  }

  Widget _buildStandardSidebar() {
    return Column(
      children: [
        _buildFlightDetailsCard(),
        const SizedBox(height: 24),
        _buildPaymentDetailsCard(),
      ],
    );
  }

  Widget _buildPaymentSidebar() {
    return Column(
      children: [
        // Flight Summary Card (Simplified for Payment Step)
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Flight Summary',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('London', style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.flight_takeoff, size: 16, color: Colors.grey),
                  Text('CAI', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Tue, 15 Jan 2025',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    '19:10',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.circle, size: 8, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Flight 2',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  '12:40 PM Terminal 2',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  'Time: 41-30m',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'EgyptAir',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'MS M7B',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              const Divider(height: 24),
              const Text(
                'Price Summary',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPriceRow('1 Adult', '\$340.00'),
              _buildPriceRow('Taxes & Fees', '\$40.00'),
              const Divider(height: 16),
              _buildPriceRow('Total Price', '\$380.00', isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Baggage Allowance Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Baggage allowance',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPriceRow('1 Carry-on bag', '6kg'),
              _buildPriceRow('1 Checked bag', '6kg'),
              const SizedBox(height: 16),
              const Text(
                'Change Flight',
                style: TextStyle(color: Color(0xFF1A94C4), fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Need Help Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A94C4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Need Help?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              _buildIconTextRow(Icons.phone, '+1 (555) 123-4567'),
              const SizedBox(height: 8),
              _buildIconTextRow(Icons.support_agent, '24/7 Customer Support'),
              const SizedBox(height: 8),
              _buildIconTextRow(Icons.email, 'Sufar@gmail.com'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              color: Colors.black,
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
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem('Flight Selection', true, true),
          _buildStepLine(true),
          _buildStepItem(
            'Traveler Information',
            !_isSeatSelection && !_isPaymentStep,
            true,
          ), // Active
          _buildStepLine(_isSeatSelection || _isPaymentStep),
          _buildStepItem('Payment', _isPaymentStep, _isPaymentStep),
        ],
      ),
    );
  }

  Widget _buildStepItem(String label, bool isCompleted, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? (isCompleted ? const Color(0xFF1A94C4) : const Color(0xFFE0E0E0))
            : Colors.transparent, // Active/Completed bg
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          if (isCompleted)
            const Icon(Icons.check, color: Colors.white, size: 16),
          if (isCompleted) const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isCompleted ? Colors.white : Colors.black)
                  : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      width: 50,
      height: 2,
      color: isActive ? const Color(0xFF1A94C4) : Colors.grey[300],
    );
  }

  // --- Payment Step Section ---
  Widget _buildPaymentStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1C52),
          ),
        ),
        const Text(
          'Please enter your payment details to complete your booking',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Methods Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildPaymentTab(
                      'Credit / Debit Card',
                      Icons.credit_card,
                      true,
                    ),
                    _buildPaymentTab('PayPal', Icons.paypal, false),
                    _buildPaymentTab(
                      'Online Banking',
                      Icons.account_balance,
                      false,
                    ),
                    _buildPaymentTab(
                      'Pay to Airport',
                      Icons.flight_takeoff,
                      false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Card Details
              _buildTextField('Card Number*', 'Enter your card number'),
              const SizedBox(height: 16),
              _buildTextField('Card Holder Name*', 'Name on card'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expiry Date',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildDateInput('MM')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildDateInput('YY')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'CVV*',
                      'e.g. 123',
                      suffixIcon: Icons.lock_outline,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Finish flow
                    Navigator.pop(context);
                    // Show success message or navigate to confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment Successful!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A94C4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Pay \$380.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Security Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE0F7FA),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 30,
                      color: Color(0xFF1A94C4),
                    ),
                  ),
                  const SizedBox(width: 16),
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
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPaymentLogo(Icons.credit_card, Colors.blue),
                  const SizedBox(width: 16),
                  _buildPaymentLogo(Icons.credit_card, Colors.red),
                  const SizedBox(width: 16),
                  _buildPaymentLogo(Icons.credit_card, Colors.blue[800]!),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTab(String label, IconData icon, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A94C4) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentLogo(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(icon, color: color, size: 30),
    );
  }

  // --- Traveler Info Section ---

  Widget _buildTravelerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Traveler Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1C52),
          ),
        ),
        const SizedBox(height: 24),

        // Primary Contact
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Primary Contact',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('Email*', 'Enter email')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Mobile Number*',
                      '+20 Enter number',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v) {}),
                  const Text(
                    'I do not wish to receive any newsletters about cheap air fares or other offers',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Passenger Details
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Passenger Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Adult (Over 12)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Title*',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildRadio('Mr'),
                  const SizedBox(width: 16),
                  _buildRadio('Mrs/Ms'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField('First Name*', '')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField('Last Name*', '')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown('Nationality*', 'United Kingdom'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateRow(
                      'Date of Birth*',
                      'YYYY',
                      'Month',
                      'DD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Passport Or ID Number*', ''),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateRow(
                      'Passport Or ID Expiration Date*',
                      'YYYY',
                      'Month',
                      'DD',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Baggage Cards
              Row(
                children: [
                  Expanded(
                    child: _buildBaggageCard(
                      'Personal Item',
                      Icons.backpack_outlined,
                      'Included',
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBaggageCard(
                      'Hand baggage',
                      Icons.luggage_outlined,
                      'Included\n1x 7 kg',
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBaggageCard(
                      'Checked Baggage',
                      Icons.work_outline,
                      'Not Included\n1x 23kg',
                      true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_circle, color: Color(0xFF1A94C4)),
            label: const Text(
              'Add Another Passenger',
              style: TextStyle(color: Color(0xFF1A94C4)),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text('Back', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSeatSelection = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Continue to Payment',
                style: TextStyle(color: Colors.white),
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
        const Text(
          'Select Sitting',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1C52),
          ),
        ),
        const SizedBox(height: 8),

        // Header Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
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
                  ),
                  Text(
                    'AirBlue SV737',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Selected 2 Out of 2 Seats',
                  style: TextStyle(color: Colors.green, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem(Colors.blue[100]!, 'Available Seat'),
            _buildLegendItem(Colors.blue[300]!, 'With Conditions'),
            _buildLegendItem(Colors.blue[700]!, 'Extra Leg Room'),
            _buildLegendItem(Colors.green, 'Selected Seat'),
            _buildLegendItem(Colors.grey[300]!, 'Booked Seat'),
          ],
        ),

        const SizedBox(height: 40),

        // Seat Grid
        Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                _buildSeatMapHeader(),
                const SizedBox(height: 16),
                for (int i = 2; i <= 11; i++) _buildSeatRow(i),
                const SizedBox(height: 24),
                _buildSeatRow(12, isExit: true), // Exit row / gap
                const SizedBox(height: 24),
                _buildSeatMapHeader(), // Repeat header
                for (int i = 2; i <= 6; i++) _buildSeatRow(i),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),
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
              child: const Text('Back', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isSeatSelection = false;
                  _isPaymentStep = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Continue to Payment',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 10)),
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
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: const Text('Exit'),
          ),
          const SizedBox(width: 200),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[100],
            child: const Text('Exit'),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              style: const TextStyle(color: Colors.grey, fontSize: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
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
          const SizedBox(height: 2),
          Text('£34', style: TextStyle(fontSize: 8, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- Sidebar Widgets ---

  Widget _buildFlightDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flight details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),

          _buildFlightLegSummary(
            'Departure',
            'Tue, 21 Jan 2025',
            '20:50',
            'LHE',
            '06:35',
            'FRA',
            '13h 45m',
            'AirBlue SV737',
          ),
          const Divider(height: 32),
          _buildFlightLegSummary(
            'Return',
            'Wed, 29 Jan 2025',
            '20:50',
            'FRA',
            '06:35',
            'DXB',
            '11h 45m',
            'AirBlue SV737',
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '30min Transfer and flight change',
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A94C4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Details',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('1x Passenger (Adult)', '£340'),
          _buildPaymentRow('1x Passenger (Teenager)', '£300'),
          _buildPaymentRow('1x Checked Baggage', '£34'),
          _buildPaymentRow('2x Hand Baggage', 'Included'),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Amount to pay',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '£340',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
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
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTextField(String label, String hint, {IconData? suffixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.red),
        ), // Using red for required *
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.grey)
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.red)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.flag,
                    size: 16,
                    color: Colors.blue,
                  ), // Placeholder flag
                  const SizedBox(width: 8),
                  Text(value),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateRow(String label, String y, String m, String d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.red)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildDateInput(y)),
            const SizedBox(width: 8),
            Expanded(child: _buildDateInput(m)),
            const SizedBox(width: 8),
            Expanded(child: _buildDateInput(d)),
          ],
        ),
      ],
    );
  }

  Widget _buildDateInput(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildRadio(String label) {
    return Row(
      children: [
        Radio(
          value: label,
          groupValue: _selectedGender,
          onChanged: (v) => setState(() => _selectedGender = v.toString()),
          activeColor: Colors.red,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildBaggageCard(
    String title,
    IconData icon,
    String detail,
    bool canAdd,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (canAdd)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Not Included',
                style: TextStyle(fontSize: 8, color: Colors.red),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF1A94C4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Included',
                style: TextStyle(fontSize: 8, color: Colors.white),
              ),
            ),

          const SizedBox(height: 8),
          Icon(icon, size: 40, color: const Color(0xFF0D1C52)),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center,
          ),

          if (canAdd) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A94C4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '£34 +',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlightLegSummary(
    String type,
    String date,
    String time1,
    String ap1,
    String time2,
    String ap2,
    String duration,
    String airline,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(date, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        const SizedBox(height: 8),
        Text(airline, style: const TextStyle(fontSize: 10, color: Colors.blue)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$time1 - $time2',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              duration,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        Text(
          '$ap1 - $ap2',
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}
