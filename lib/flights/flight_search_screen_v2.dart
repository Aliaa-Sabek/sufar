import 'package:flutter/material.dart';
import 'package:sufar_project/services/api_service.dart';

import '../models/flight_model.dart';
import 'flight_booking_screen.dart';

class FlightSearchPage extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final String departureDate;
  final String returnDate;
  final int travelers;
  final bool isOneWay;

  const FlightSearchPage({
    super.key,
    this.fromCity = 'London (LHR)',
    this.toCity = 'Dubai, UAE',
    this.departureDate = '14/05/2025',
    this.returnDate = '21/05/2025',
    this.travelers = 1,
    this.isOneWay = false,
  });

  @override
  State<FlightSearchPage> createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  List<FlightModel> _flights = [];
  bool _isLoading = true;

  // Filter state
  String _selectedSort = 'Recommended';
  final List<bool> _stageChecks = [true, false, false];
  final List<bool> _depTimeChecks = List.filled(16, false);

  final List<String> _sortOptions = [
    'Recommended',
    'Cheapest',
    'Fastest',
    'Earliest',
  ];
  final List<String> _stages = ['Direct', '1 stop', '2+ stops'];
  final List<String> _depTimes = [
    '00:00',
    '01:00',
    '02:00',
    '03:00',
    '04:00',
    '05:00',
    '06:00',
    '07:00',
    '08:00',
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
  ];

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--:--';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    if (minutes <= 0) return '--';
    return '${minutes ~/ 60}h ${(minutes % 60).toString().padLeft(2, '0')}m';
  }

  // ── Sample flights used as fallback if DB is empty ────────────────
  static final List<FlightModel> _mockFlights = [
    FlightModel(
      flightId: 1,
      flightNumber: 'EK202',
      airline: 'Emirates',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 8, 30),
      arrivalDatetime: DateTime(2025, 5, 14, 20, 45),
      durationMinutes: 435,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Boeing 777',
      priceEGP: 450,
      seatsTotal: 300,
      seatsAvailable: 120,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T3',
    ),
    FlightModel(
      flightId: 2,
      flightNumber: 'QR101',
      airline: 'Qatar Airways',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 10, 15),
      arrivalDatetime: DateTime(2025, 5, 14, 22, 30),
      durationMinutes: 435,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Airbus A380',
      priceEGP: 520,
      seatsTotal: 400,
      seatsAvailable: 95,
      status: 'scheduled',
      baggageAllowanceKg: 30,
      mealIncluded: true,
      terminal: 'T5',
    ),
    FlightModel(
      flightId: 3,
      flightNumber: 'TK793',
      airline: 'Turkish Airlines',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 14, 20),
      arrivalDatetime: DateTime(2025, 5, 15, 5, 5),
      durationMinutes: 525,
      flightType: '1 stop',
      airlineClass: 'Economy',
      aircraftType: 'Airbus A330',
      priceEGP: 380,
      seatsTotal: 250,
      seatsAvailable: 60,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T2',
    ),
    FlightModel(
      flightId: 4,
      flightNumber: 'BA107',
      airline: 'British Airways',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 6, 0),
      arrivalDatetime: DateTime(2025, 5, 14, 18, 15),
      durationMinutes: 435,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Boeing 787',
      priceEGP: 490,
      seatsTotal: 280,
      seatsAvailable: 140,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T5',
    ),
    FlightModel(
      flightId: 5,
      flightNumber: 'LH3167',
      airline: 'Lufthansa',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 16, 45),
      arrivalDatetime: DateTime(2025, 5, 15, 7, 0),
      durationMinutes: 555,
      flightType: '1 stop',
      airlineClass: 'Economy',
      aircraftType: 'Airbus A340',
      priceEGP: 430,
      seatsTotal: 200,
      seatsAvailable: 80,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T2',
    ),
    FlightModel(
      flightId: 6,
      flightNumber: 'MS760',
      airline: 'EgyptAir',
      originCity: 'Cairo',
      originCode: 'CAI',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 15, 0),
      arrivalDatetime: DateTime(2025, 5, 14, 19, 30),
      durationMinutes: 270,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Boeing 737',
      priceEGP: 220,
      seatsTotal: 180,
      seatsAvailable: 90,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T1',
    ),
    FlightModel(
      flightId: 7,
      flightNumber: 'FZ201',
      airline: 'flydubai',
      originCity: 'Cairo',
      originCode: 'CAI',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 22, 0),
      arrivalDatetime: DateTime(2025, 5, 15, 2, 30),
      durationMinutes: 270,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Boeing 737 MAX',
      priceEGP: 180,
      seatsTotal: 200,
      seatsAvailable: 150,
      status: 'scheduled',
      baggageAllowanceKg: 20,
      mealIncluded: false,
      terminal: 'T2',
    ),
    FlightModel(
      flightId: 8,
      flightNumber: 'EY025',
      airline: 'Etihad Airways',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Abu Dhabi',
      destinationCode: 'AUH',
      departureDatetime: DateTime(2025, 5, 14, 9, 45),
      arrivalDatetime: DateTime(2025, 5, 14, 21, 30),
      durationMinutes: 465,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Airbus A380',
      priceEGP: 470,
      seatsTotal: 400,
      seatsAvailable: 200,
      status: 'scheduled',
      baggageAllowanceKg: 30,
      mealIncluded: true,
      terminal: 'T3',
    ),
    FlightModel(
      flightId: 9,
      flightNumber: 'AF1680',
      airline: 'Air France',
      originCity: 'London',
      originCode: 'LHR',
      destinationCity: 'Dubai',
      destinationCode: 'DXB',
      departureDatetime: DateTime(2025, 5, 14, 12, 30),
      arrivalDatetime: DateTime(2025, 5, 15, 1, 45),
      durationMinutes: 555,
      flightType: '1 stop',
      airlineClass: 'Economy',
      aircraftType: 'Boeing 777',
      priceEGP: 410,
      seatsTotal: 300,
      seatsAvailable: 110,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T4',
    ),
    FlightModel(
      flightId: 10,
      flightNumber: 'SV001',
      airline: 'Saudia',
      originCity: 'Cairo',
      originCode: 'CAI',
      destinationCity: 'Riyadh',
      destinationCode: 'RUH',
      departureDatetime: DateTime(2025, 5, 14, 7, 30),
      arrivalDatetime: DateTime(2025, 5, 14, 10, 0),
      durationMinutes: 150,
      flightType: 'direct',
      airlineClass: 'Economy',
      aircraftType: 'Airbus A320',
      priceEGP: 150,
      seatsTotal: 180,
      seatsAvailable: 100,
      status: 'scheduled',
      baggageAllowanceKg: 23,
      mealIncluded: true,
      terminal: 'T1',
    ),
  ];

  Future<void> _fetchFlights() async {
    try {
      final rows = await ApiService.searchFlights(
        from: widget.fromCity,
        to: widget.toCity,
      );
      if (mounted) {
        setState(() {
          _flights = rows.isEmpty
              ? _mockFlights // fallback when DB table is empty
              : rows.map((json) => FlightModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      // On any error, show mock data so UI is never broken
      if (mounted) {
        setState(() {
          _flights = _mockFlights;
          _isLoading = false;
        });
      }
    }
  }

  String _stopLabel(FlightModel f) {
    final t = f.flightType.toLowerCase();
    if (t.contains('direct') || t.isEmpty) return 'Direct';
    if (t.contains('1') || t.contains('one')) return '1 stop';
    return '2+ stops';
  }

  Color _stopColor(String label) {
    if (label == 'Direct') return const Color(0xFF00C896);
    if (label == '1 stop') return const Color(0xFFF5A623);
    return const Color(0xFFE04040);
  }

  List<FlightModel> _getFilteredAndSortedFlights() {
    // Step 1: Apply Stage Filter
    List<FlightModel> filtered = _flights.where((flight) {
      final stopLabel = _stopLabel(flight);
      // If no stage is selected, show all
      final hasStageFilter = _stageChecks.any((v) => v);
      if (!hasStageFilter) return true;
      
      if (_stageChecks[0] && stopLabel == 'Direct') return true;
      if (_stageChecks[1] && stopLabel == '1 stop') return true;
      if (_stageChecks[2] && stopLabel == '2+ stops') return true;
      return false;
    }).toList();

    // Step 2: Apply Departure Time Filter
    final selectedTimes = <int>[];
    for (int i = 0; i < _depTimeChecks.length; i++) {
      if (_depTimeChecks[i]) {
        selectedTimes.add(i); // 00:00, 01:00, ... 15:00
      }
    }

    if (selectedTimes.isNotEmpty) {
      filtered = filtered.where((flight) {
        final depHour = flight.departureDatetime?.hour ?? -1;
        return selectedTimes.contains(depHour);
      }).toList();
    }

    // Step 3: Apply Sorting
    switch (_selectedSort) {
      case 'Cheapest':
        filtered.sort((a, b) => a.priceEGP.compareTo(b.priceEGP));
        break;
      case 'Fastest':
        filtered.sort((a, b) => a.durationMinutes.compareTo(b.durationMinutes));
        break;
      case 'Earliest':
        filtered.sort((a, b) {
          final aTime = a.departureDatetime?.hour ?? 24;
          final bTime = b.departureDatetime?.hour ?? 24;
          return aTime.compareTo(bTime);
        });
        break;
      case 'Recommended':
      default:
        // Keep original order or sort by a combination
        break;
    }

    return filtered;
  }

  // ─── Show filter bottom sheet ───────────────────────────────────────────────
  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.4,
            builder: (_, scrollController) {
              return ListView(
                controller: scrollController,
                padding: EdgeInsets.fromLTRB(20, 0, 20, 32),
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            for (int i = 0; i < _stageChecks.length; i++) {
                              _stageChecks[i] = i == 0;
                            }
                            for (int i = 0; i < _depTimeChecks.length; i++) {
                              _depTimeChecks[i] = false;
                            }
                          });
                          setState(() {});
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(color: Color(0xFF1A94C4)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Stages
                  Text(
                    'Stages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      
                    ),
                  ),
                  SizedBox(height: 12),
                  ...List.generate(_stages.length, (i) {
                    return CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      value: _stageChecks[i],
                      activeColor: const Color(0xFF1A94C4),
                      title: Text(
                        _stages[i],
                        style: TextStyle(fontSize: 14),
                      ),
                      onChanged: (v) {
                        setSheetState(() => _stageChecks[i] = v ?? false);
                        setState(() {});
                      },
                    );
                  }),

                  SizedBox(height: 20),
                  const Divider(),
                  SizedBox(height: 12),

                  // Departure Times
                  Text(
                    'Departure Times',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(_depTimes.length, (i) {
                      final selected = _depTimeChecks[i];
                      return GestureDetector(
                        onTap: () {
                          setSheetState(
                            () => _depTimeChecks[i] = !_depTimeChecks[i],
                          );
                          setState(() {});
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF1A94C4)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1A94C4)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            _depTimes[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Count active filters
    final activeStages = _stageChecks.where((v) => v).length;
    final activeTimes = _depTimeChecks.where((v) => v).length;
    final totalFilters = activeStages + activeTimes;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Image.asset(
          'assets/Sufar Logo Blue.png',
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, st) => Text(
            'Sufar',
            style: TextStyle(
              color: Color(0xFF1A94C4),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              
              size: 22,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.person_outline,
              
              size: 22,
            ),
            onPressed: () {},
          ),
          SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // ─── Blue summary bar ───────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFF1A94C4),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _headerPill(
                    Icons.flight,
                    '${widget.fromCity} → ${widget.toCity}',
                  ),
                  SizedBox(width: 8),
                  _headerPill(
                    Icons.calendar_today_outlined,
                    widget.isOneWay
                        ? widget.departureDate
                        : '${widget.departureDate} - ${widget.returnDate}',
                  ),
                  SizedBox(width: 8),
                  _headerPill(
                    Icons.person_outline,
                    '${widget.travelers} Adult, Economy',
                  ),
                ],
              ),
            ),
          ),

          // ─── Scrollable body ────────────────────────────
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Title + Filter button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flights Search',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                
                              ),
                            ),
                            Text(
                              _isLoading
                                  ? 'Loading...'
                                  : '${_getFilteredAndSortedFlights().length} Results',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        // Filter button
                        GestureDetector(
                          onTap: _showFilters,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: totalFilters > 0
                                  ? const Color(0xFF1A94C4)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF1A94C4),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tune,
                                  size: 16,
                                  color: totalFilters > 0
                                      ? Colors.white
                                      : const Color(0xFF1A94C4),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  totalFilters > 0
                                      ? 'Filters ($totalFilters)'
                                      : 'Filters',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: totalFilters > 0
                                        ? Colors.white
                                        : const Color(0xFF1A94C4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sort tabs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _sortOptions.map((opt) {
                          final isSelected = _selectedSort == opt;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSort = opt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF1A94C4)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1A94C4)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // ── Flight cards / states ───────────────────
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  Builder(
                    builder: (ctx) {
                      final filteredFlights = _getFilteredAndSortedFlights();
                      if (filteredFlights.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flight_takeoff,
                                  color: Colors.grey,
                                  size: 56,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'No flights found',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Try adjusting your search criteria',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 32),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: EdgeInsets.only(bottom: 14),
                              child: _buildFlightCard(filteredFlights[i]),
                            ),
                            childCount: filteredFlights.length,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────────

  Widget _headerPill(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).cardColor, size: 14),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).cardColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightCard(FlightModel flight) {
    final stopLabel = _stopLabel(flight);
    final badgeColor = _stopColor(stopLabel);
    final depTime = _formatTime(flight.departureDatetime);
    final arrTime = _formatTime(flight.arrivalDatetime);
    final duration = _formatDuration(flight.durationMinutes);
    final price = flight.priceEGP.toStringAsFixed(0);
    final originCode = flight.originCode.isNotEmpty ? flight.originCode : 'LHR';
    final destCode = flight.destinationCode.isNotEmpty
        ? flight.destinationCode
        : 'DXB';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Row 1: Airline + Price
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A94C4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.flight,
                        color: Theme.of(context).cardColor,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.airline,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            flight.flightNumber.isNotEmpty
                                ? flight.flightNumber
                                : 'FL 000',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          'USD',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 18),

                // Row 2: Depart — line — Arrive + badge
                Row(
                  children: [
                    // Depart
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          depTime,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            
                          ),
                        ),
                        Text(
                          originCode,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    // Center timeline
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            duration,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              SizedBox(width: 6),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Icon(
                                Icons.flight,
                                color: Color(0xFF1A94C4),
                                size: 16,
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              SizedBox(width: 6),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrive
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrTime,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            
                          ),
                        ),
                        Text(
                          destCode,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(width: 10),

                    // Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badgeColor.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        stopLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Select button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FlightBookingPage(
                      selectedFlight: flight,
                      totalPassengers: widget.travelers,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1A94C4),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Flight',
                    style: TextStyle(
                      color: Theme.of(context).cardColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward, color: Theme.of(context).cardColor, size: 15),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
