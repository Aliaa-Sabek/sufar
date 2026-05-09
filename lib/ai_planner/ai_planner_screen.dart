import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

// ── Data models matching the Flask /api/recommend response ────────────────────

class _Hotel {
  final String nameEn, nameAr, budgetLevel;
  final double rating;
  _Hotel({
    required this.nameEn,
    required this.nameAr,
    required this.budgetLevel,
    required this.rating,
  });
  factory _Hotel.fromJson(Map j) => _Hotel(
    nameEn: j['name_en'] ?? '',
    nameAr: j['name_ar'] ?? '',
    budgetLevel: j['budget_level'] ?? 'medium',
    rating: (j['rating'] as num?)?.toDouble() ?? 4.0,
  );
}

class _DayPlan {
  final int day;
  final List<String> en, ar;
  _DayPlan({required this.day, required this.en, required this.ar});
  factory _DayPlan.fromJson(Map j) => _DayPlan(
    day: (j['day'] as num?)?.toInt() ?? 1,
    en: List<String>.from(j['en'] ?? []),
    ar: List<String>.from(j['ar'] ?? []),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class AIPlannerPage extends StatefulWidget {
  const AIPlannerPage({super.key});
  @override
  State<AIPlannerPage> createState() => _AIPlannerPageState();
}

class _AIPlannerPageState extends State<AIPlannerPage> {
  final _destCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  final Set<String> _sel = {};
  bool _loading = false;
  String? _error;

  // Results
  String? _cityEn, _cityAr;
  List<_Hotel> _hotels = [];
  List<_DayPlan> _days = [];
  bool _isArabic = false;

  static const _interests = [
    'Beach & Relaxation',
    'Adventure & Sports',
    'Culture & History',
    'Food & Cuisine',
    'Nature & Wildlife',
    'Shopping',
    'Nightlife',
    'Photography',
  ];

  @override
  void dispose() {
    _destCtrl.dispose();
    _budgetCtrl.dispose();
    _durationCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  IconData _iconFor(String text) {
    final t = text.toLowerCase();
    if (t.contains('check') || t.contains('تسجيل')) return Icons.hotel;
    if (t.contains('pyramid') ||
        t.contains('أهرام') ||
        t.contains('temple') ||
        t.contains('معبد')) {
      return Icons.account_balance;
    }
    if (t.contains('museum') || t.contains('متحف')) return Icons.museum;
    if (t.contains('food') ||
        t.contains('dinner') ||
        t.contains('عشاء') ||
        t.contains('طعام') ||
        t.contains('مطعم')) {
      return Icons.restaurant;
    }
    if (t.contains('shop') ||
        t.contains('mall') ||
        t.contains('bazaar') ||
        t.contains('تسوق') ||
        t.contains('سوق')) {
      return Icons.shopping_bag_outlined;
    }
    if (t.contains('beach') ||
        t.contains('sea') ||
        t.contains('شاطئ') ||
        t.contains('بحر')) {
      return Icons.beach_access;
    }
    if (t.contains('boat') ||
        t.contains('cruise') ||
        t.contains('felucca') ||
        t.contains('فلوكة') ||
        t.contains('رحلة نيلية')) {
      return Icons.sailing;
    }
    if (t.contains('mosque') ||
        t.contains('haram') ||
        t.contains('مسجد') ||
        t.contains('حرم')) {
      return Icons.mosque;
    }
    if (t.contains('park') || t.contains('garden') || t.contains('حديقة')) {
      return Icons.park;
    }
    if (t.contains('walk') ||
        t.contains('corniche') ||
        t.contains('كورنيش') ||
        t.contains('جولة')) {
      return Icons.directions_walk;
    }
    return Icons.place_outlined;
  }

  Future<void> _generate() async {
    final dest = _destCtrl.text.trim();
    final budget = _budgetCtrl.text.isEmpty ? '1000' : _budgetCtrl.text;
    final duration = _durationCtrl.text.isEmpty ? '5' : _durationCtrl.text;

    setState(() {
      _loading = true;
      _error = null;
      _cityEn = null;
      _cityAr = null;
      _hotels = [];
      _days = [];
      _isArabic = dest.runes.any((r) => r >= 0x0600 && r <= 0x06FF);
    });

    try {
      // Call the Flask backend /api/recommend endpoint
      final baseUrl = ApiService.baseUrl;

      final res = await http
          .post(
            Uri.parse('$baseUrl/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'destination': dest,
              'budget': budget,
              'duration': duration,
              'interests': _sel.toList(),
              'language': _isArabic ? 'ar' : 'en',
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map;

        // Parse results from Flask response
        setState(() {
          _cityEn = data['ai_selected_city_en'] ?? 'Cairo';
          _cityAr = data['ai_selected_city_ar'] ?? 'القاهرة';

          // Parse hotels
          final hotelsList = data['recommended_hotels'] as List? ?? [];
          _hotels = hotelsList.map((h) => _Hotel.fromJson(h as Map)).toList();

          // Parse itinerary
          final itinerary = data['itinerary'] as List? ?? [];
          _days = itinerary.map((d) => _DayPlan.fromJson(d as Map)).toList();

          _loading = false;
        });

        // Scroll to results
        await Future.delayed(const Duration(milliseconds: 300));
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      } else {
        setState(() {
          _error =
              'Error from server (${res.statusCode}). Make sure the backend is reachable on $baseUrl';
          _loading = false;
        });
      }
    } on http.ClientException catch (e) {
      setState(() {
        _error =
            'Connection error: ${e.message}\n\nMake sure:\n1. Backend is running (python app.py)\n2. IP address is correct (check your PC IP)';
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Image.asset(
            'assets/Sufar Logo Blue.png',
            errorBuilder: (c, e, s) =>
                Icon(Icons.travel_explore, color: Color(0xFF1A94C4)),
          ),
        ),
        title: Text(
          'AI Travel Planner',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_outlined, color: Colors.grey),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildForm(),
            if (_error != null) _buildError(),
            if (_loading) _buildLoading(),
            if (_cityEn != null) ...[
              SizedBox(height: 20),
              _buildResultHeader(),
              SizedBox(height: 12),
              if (_hotels.isNotEmpty) _buildHotelsCard(),
              SizedBox(height: 12),
              ..._days.map(_buildDayCard),
            ],
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D4B88),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Theme.of(context).cardColor,
                  size: 22,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Travel Planner',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0D1C52),
                    ),
                  ),
                  Text(
                    'Powered by local smart engine',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

          _field(
            'Country / Destination',
            'e.g., Cairo, دبي, Istanbul',
            Icons.location_on_outlined,
            _destCtrl,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Budget (USD)',
                  'e.g., 1500',
                  Icons.attach_money,
                  _budgetCtrl,
                  num: true,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _field(
                  'Duration (days)',
                  'e.g., 5',
                  Icons.calendar_today_outlined,
                  _durationCtrl,
                  num: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          Text('Interests', style: TextStyle(color: Colors.grey, fontSize: 13)),
          SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _interests.map((i) {
              final s = _sel.contains(i);
              return GestureDetector(
                onTap: () => setState(() => s ? _sel.remove(i) : _sel.add(i)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: s
                        ? const Color(0xFF1A94C4).withValues(alpha: 0.1)
                        : const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: s ? const Color(0xFF1A94C4) : Colors.grey.shade200,
                      width: s ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    i,
                    style: TextStyle(
                      fontSize: 12,
                      color: s
                          ? const Color(0xFF1A94C4)
                          : const Color(0xFF0D1C52),
                      fontWeight: s ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _generate,
              icon: _loading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).cardColor,
                      ),
                    )
                  : Icon(
                      Icons.auto_awesome,
                      color: Theme.of(context).cardColor,
                      size: 18,
                    ),
              label: Text(
                _loading ? 'Generating...' : 'Generate My Plan',
                style: TextStyle(
                  color: Theme.of(context).cardColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D4B88),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    String hint,
    IconData icon,
    TextEditingController ctrl, {
    bool num = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          style: TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
            prefixIcon: Icon(icon, color: const Color(0xFF1A94C4), size: 18),
            filled: true,
            fillColor: const Color(0xFFF5F7FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            isDense: true,
          ),
        ),
      ],
    );
  }

  // ── Error / Loading ───────────────────────────────────────────────────────

  Widget _buildError() => Container(
    margin: EdgeInsets.only(top: 12),
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.error_outline, color: Colors.red, size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            _error!,
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
        ),
      ],
    ),
  );

  Widget _buildLoading() => Container(
    margin: EdgeInsets.only(top: 20),
    padding: EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        CircularProgressIndicator(color: Color(0xFF0D4B88)),
        SizedBox(height: 14),
        Text(
          '✈️ Building your travel plan...',
          style: TextStyle(color: Color(0xFF0D4B88)),
        ),
        SizedBox(height: 4),
        Text(
          'Connecting to local engine',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ),
  );

  // ── Results ───────────────────────────────────────────────────────────────

  Widget _buildResultHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Preview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0D1C52),
            ),
          ),
          Text(
            _isArabic ? (_cityAr ?? '') : (_cityEn ?? ''),
            style: TextStyle(color: Color(0xFF1A94C4), fontSize: 13),
          ),
        ],
      ),
      GestureDetector(
        onTap: _generate,
        child: Row(
          children: [
            Icon(Icons.refresh, size: 16, color: Color(0xFF1A94C4)),
            SizedBox(width: 4),
            Text(
              'Regenerate',
              style: TextStyle(color: Color(0xFF1A94C4), fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildHotelsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D4B88), Color(0xFF1A94C4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.hotel, color: Theme.of(context).cardColor, size: 20),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOMMENDED HOTELS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      _isArabic ? (_cityAr ?? '') : (_cityEn ?? ''),
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Hotel list
          ..._hotels.asMap().entries.map((e) {
            final i = e.key;
            final h = e.value;
            final isLast = i == _hotels.length - 1;
            final budgetColor = h.budgetLevel == 'high'
                ? Colors.orange
                : h.budgetLevel == 'low'
                ? Colors.green
                : const Color(0xFF1A94C4);
            final budgetLabel = h.budgetLevel == 'high'
                ? '💎 Premium'
                : h.budgetLevel == 'low'
                ? '💚 Budget'
                : '⭐ Mid-range';
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF0D4B88,
                          ).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.hotel,
                          color: Color(0xFF0D4B88),
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isArabic ? h.nameAr : h.nameEn,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF0D1C52),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 13),
                                SizedBox(width: 3),
                                Text(
                                  h.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: budgetColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    budgetLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: budgetColor,
                                      fontWeight: FontWeight.w600,
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
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayCard(_DayPlan day) {
    final palette = [
      const Color(0xFF1A94C4),
      const Color(0xFF0D4B88),
      const Color(0xFF00897B),
      const Color(0xFFE65100),
      const Color(0xFF6A1B9A),
      const Color(0xFF2E7D32),
      const Color(0xFFC62828),
    ];
    final color = palette[(day.day - 1) % palette.length];
    final items = _isArabic ? day.ar : day.en;

    return Container(
      margin: EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Theme.of(context).cardColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  _isArabic ? 'اليوم ${day.day}' : 'Day ${day.day}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          // Activities
          ...items.asMap().entries.map((e) {
            final idx = e.key;
            final text = e.value;
            final isLast = idx == items.length - 1;
            final isCheckout =
                text.toLowerCase().contains('check') || text.contains('تسجيل');

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_iconFor(text), color: color, size: 26),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Color(0xFF0D1C52),
                              ),
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCheckout
                                        ? color
                                        : Colors.transparent,
                                    border: Border.all(color: color),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isCheckout
                                        ? (_isArabic ? 'احجز' : 'Reserve')
                                        : (_isArabic
                                              ? 'التفاصيل >'
                                              : 'Details >'),
                                    style: TextStyle(
                                      color: isCheckout ? Colors.white : color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 14,
                    endIndent: 14,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
