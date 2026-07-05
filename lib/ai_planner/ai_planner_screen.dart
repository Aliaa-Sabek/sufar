import 'package:flutter/material.dart';
import '../models/hotel_model.dart';
import '../services/api_service.dart';
import '../services/destination_catalog_service.dart';
import '../services/image_service.dart';
import '../theme/widgets/process_loading_overlay.dart';

// ── Data models matching the Flask /api/recommend response ────────────────────

class _Hotel {
  final String nameEn, nameAr, budgetLevel, locationType, slug;
  final double rating;
  final int startingFrom, stars;
  final List<String> images;
  _Hotel({
    required this.nameEn,
    required this.nameAr,
    required this.budgetLevel,
    required this.rating,
    required this.startingFrom,
    required this.locationType,
    required this.stars,
    required this.slug,
    required this.images,
  });

  static List<String> _parseImages(dynamic raw) {
    final urls = <String>[];

    if (raw is List) {
      for (final item in raw) {
        if (item == null) continue;
        final url = item is Map
            ? item['url']?.toString() ?? ''
            : item.toString();
        debugPrint('[_Hotel] Raw image from list: $url');
        final normalized = ImageService.normalizeImageUrl(url, type: 'hotel').isNotEmpty
            ? ImageService.normalizeImageUrl(url, type: 'hotel')
            : ImageService.resolveMediaUrl(url, type: 'hotel');
        if (normalized.isNotEmpty && !urls.contains(normalized)) {
          urls.add(normalized);
        }
      }
    } else if (raw != null) {
      final url = raw is Map ? raw['url']?.toString() ?? '' : raw.toString();
      debugPrint('[_Hotel] Raw image single: $url');
      final normalized = ImageService.normalizeImageUrl(url, type: 'hotel').isNotEmpty
          ? ImageService.normalizeImageUrl(url, type: 'hotel')
          : ImageService.resolveMediaUrl(url, type: 'hotel');
      if (normalized.isNotEmpty) urls.add(normalized);
    }

    return urls;
  }

  factory _Hotel.fromJson(Map j) => _Hotel(
    nameEn: j['name'] ?? '',
    nameAr: j['name_ar'] ?? j['name'] ?? '',
    budgetLevel: 'medium',
    rating: (j['rating'] as num?)?.toDouble() ?? 4.0,
    startingFrom: (j['startingFrom'] as num?)?.toInt() ?? 100,
    locationType: j['locationType'] ?? 'City Center',
    stars: (j['stars'] as num?)?.toInt() ?? 4,
    slug: j['slug']?.toString() ?? '',
    images: () {
      final list = _parseImages(j['images']);
      if (list.isNotEmpty) return list;
      final fallbackFields = [
        j['image'],
        j['image_url'],
        j['imageUrl'],
        j['thumbnail'],
        j['photo'],
      ];
      for (final field in fallbackFields) {
        final fallback = _parseImages(field);
        if (fallback.isNotEmpty) return fallback;
      }
      return <String>[];
    }(),
  );
}

class _Activity {
  final String name;
  final String type;
  _Activity({required this.name, required this.type});
}

class _DayPlan {
  final int day;
  final String title;
  final List<_Activity> activities;
  _DayPlan({required this.day, required this.title, required this.activities});
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
  String? _destImageUrl; // city hero from catalog (Cloudinary / assets)
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

    // ── Type shortcuts (from _inferType) ──────────────────────────────────────
    if (t == 'museum') { return Icons.museum; }
    if (t == 'religious') { return Icons.mosque; }
    if (t == 'beach') { return Icons.beach_access; }
    if (t == 'adventure') { return Icons.landscape; }
    if (t == 'food') { return Icons.restaurant; }
    if (t == 'shopping') { return Icons.shopping_bag_outlined; }
    if (t == 'cruise') { return Icons.sailing; }
    if (t == 'nature') { return Icons.park; }
    if (t == 'sightseeing') { return Icons.directions_walk; }
    if (t == 'landmark') { return Icons.account_balance; }
    if (t == 'attraction') { return Icons.place_outlined; }

    // ── Keyword fallback (activity name) ──────────────────────────────────────
    if (t.contains('check') || t.contains('تسجيل')) { return Icons.hotel; }
    if (t.contains('pyramid') || t.contains('أهرام') ||
        t.contains('temple') || t.contains('معبد')) {
      return Icons.account_balance;
    }
    if (t.contains('museum') || t.contains('متحف') ||
        t.contains('bibliotheca')) {
      return Icons.museum;
    }
    if (t.contains('food') || t.contains('dinner') ||
        t.contains('restaurant') || t.contains('cuisine') ||
        t.contains('عشاء') || t.contains('طعام') ||
        t.contains('مطعم')) {
      return Icons.restaurant;
    }
    if (t.contains('shop') || t.contains('mall') ||
        t.contains('bazaar') || t.contains('market') ||
        t.contains('souk') || t.contains('سوق') ||
        t.contains('تسوق')) {
      return Icons.shopping_bag_outlined;
    }
    if (t.contains('beach') || t.contains('sea') ||
        t.contains('snorkel') || t.contains('شاطئ') ||
        t.contains('بحر')) {
      return Icons.beach_access;
    }
    if (t.contains('boat') || t.contains('cruise') ||
        t.contains('felucca') || t.contains('yacht') ||
        t.contains('nile') || t.contains('فلوكة') ||
        t.contains('نيلية')) {
      return Icons.sailing;
    }
    if (t.contains('mosque') || t.contains('haram') ||
        t.contains('مسجد') || t.contains('حرم')) {
      return Icons.mosque;
    }
    if (t.contains('church') || t.contains('cathedral') ||
        t.contains('holy')) {
      return Icons.church;
    }
    if (t.contains('park') || t.contains('garden') ||
        t.contains('balloon') || t.contains('حديقة')) {
      return Icons.park;
    }
    if (t.contains('desert') || t.contains('safari') ||
        t.contains('trek') || t.contains('mountain')) {
      return Icons.landscape;
    }
    if (t.contains('walk') || t.contains('corniche') ||
        t.contains('downtown') || t.contains('كورنيش') ||
        t.contains('جولة')) {
      return Icons.directions_walk;
    }
    if (t.contains('tower') || t.contains('bridge') ||
        t.contains('palace') || t.contains('castle') ||
        t.contains('citadel') || t.contains('fort')) {
      return Icons.account_balance;
    }
    if (t.contains('diving') || t.contains('reef') ||
        t.contains('coral')) {
      return Icons.scuba_diving;
    }
    if (t.contains('photo') || t.contains('view') ||
        t.contains('panoram')) {
      return Icons.photo_camera_outlined;
    }
    return Icons.place_outlined;
  }


  /// Maps a city name to a bundled local asset image (last-resort fallback).
  String? _localAssetForCity(String cityName) {
    final slug = cityName.toLowerCase().trim()
        .replaceAll(' el ', '-el-')
        .replaceAll(' ', '-')
        .replaceAll('_', '-');
    const assetMap = <String, String>{
      'cairo': 'assets/destinations/cairo.jpg',
      'alexandria': 'assets/destinations/alexandria.png',
      'hurghada': 'assets/destinations/hurghada.jpeg',
      'sharm-el-sheikh': 'assets/destinations/sharm-el-sheikh.jpg',
      'sharm': 'assets/destinations/sharm-el-sheikh.jpg',
      'luxor': 'assets/destinations/luxor.png',
      'aswan': 'assets/destinations/aswan.jpg',
      'riyadh': 'assets/destinations/riyadh.png',
      'jeddah': 'assets/destinations/jeddah.jpeg',
      'makkah': 'assets/destinations/makkah.jpeg',
      'al-madina': 'assets/destinations/al-madina.png',
      'madinah': 'assets/destinations/al-madina.png',
      'dubai': 'assets/destinations/dubai.jpg',
      'abu-dhabi': 'assets/destinations/abu-dhabi.png',
      'doha': 'assets/destinations/doha.png',
      'amman': 'assets/destinations/amman.png',
      'beirut': 'assets/destinations/beirut.png',
      'paris': 'assets/destinations/paris.jpg',
      'rome': 'assets/destinations/rome.jpg',
      'barcelona': 'assets/destinations/barcelona.jpg',
      'london': 'assets/destinations/london.png',
      'new-york': 'assets/destinations/new-york.png',
      'los-angeles': 'assets/destinations/los-angeles.png',
      'istanbul': 'assets/destinations/istanbul.jpg',
      'tokyo': 'assets/destinations/tokyo.jpg',
      'maldives': 'assets/destinations/maldives.jpg',
    };
    return assetMap[slug];
  }

  Future<void> _fetchDestinationHeroImage(String cityName) async {
    // 1️⃣ Try the catalog / API (may return a Cloudinary or assets/ URL)
    try {
      // First try by name, then by slug
      final slug = DestinationCatalogService.toSlug(cityName);
      final dest = await DestinationCatalogService.destinationFor(name: cityName) ??
          await DestinationCatalogService.destinationFor(slug: slug);

      if (dest != null && dest.imageUrl.isNotEmpty && mounted) {
        setState(() => _destImageUrl = dest.imageUrl);
        debugPrint('[AIPlannerPage] Hero image from catalog: ${dest.imageUrl}');
        return;
      }
    } catch (e) {
      debugPrint('[AIPlannerPage] Catalog hero image failed: $e');
    }

    // 2️⃣ Fall back to bundled local asset
    final localAsset = _localAssetForCity(cityName);
    if (localAsset != null && mounted) {
      setState(() => _destImageUrl = localAsset);
      debugPrint('[AIPlannerPage] Hero image from local asset: $localAsset');
    }
  }

  Future<void> _enrichHotelsWithApiImages(String cityName) async {
    try {
      final res = await ApiService.getHotels(city: cityName, limit: 30);
      final list = res['hotels'] as List? ?? [];
      if (list.isEmpty || !mounted) return;

      final imagesBySlug = <String, List<String>>{};
      final imagesByName = <String, List<String>>{};
      for (final item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        final hotel = Hotel.fromJson(map);
        if (hotel.images.isEmpty) continue;
        final slug = map['slug']?.toString() ?? '';
        if (slug.isNotEmpty) imagesBySlug[slug] = hotel.images;
        imagesByName[hotel.name.toLowerCase()] = hotel.images;
      }

      setState(() {
        _hotels = _hotels.map((h) {
          final fromSlug =
              h.slug.isNotEmpty ? imagesBySlug[h.slug] : null;
          final fromName = imagesByName[h.nameEn.toLowerCase()];
          final imgs = fromSlug ?? fromName;
          if (imgs == null || imgs.isEmpty) return h;
          return _Hotel(
            nameEn: h.nameEn,
            nameAr: h.nameAr,
            budgetLevel: h.budgetLevel,
            rating: h.rating,
            startingFrom: h.startingFrom,
            locationType: h.locationType,
            stars: h.stars,
            slug: h.slug,
            images: imgs,
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('[AIPlannerPage] Hotel image enrichment failed: $e');
    }
  }

  /// Distributes [activities] across [days] days, returning a list of _DayPlan.
  List<_DayPlan> _buildItinerary(
    List<Map<String, dynamic>> activities,
    int days,
    String cityName,
  ) {
    // Typical day themes
    const themes = [
      'Arrival & First Impressions',
      'History & Heritage',
      'Culture & Local Life',
      'Adventure & Exploration',
      'Food, Shopping & Souvenirs',
      'Relaxation & Nature',
      'Hidden Gems & Farewell',
    ];

    final plans = <_DayPlan>[];
    final pool = List<Map<String, dynamic>>.from(activities);

    // If fewer activities than days, repeat them
    while (pool.length < days * 3) {
      pool.addAll(activities);
    }

    int actIdx = 0;
    for (int d = 1; d <= days; d++) {
      // 3-4 activities per day
      final perDay = (d == days) ? 3 : (d % 2 == 0 ? 4 : 3);
      final dayActs = <_Activity>[];
      for (int i = 0; i < perDay && actIdx < pool.length; i++, actIdx++) {
        final act = pool[actIdx % pool.length];
        dayActs.add(_Activity(
          name: (act['title'] ?? act['name'] ?? '').toString(),
          type: _inferType((act['title'] ?? '').toString()),
        ));
      }
      plans.add(_DayPlan(
        day: d,
        title: themes[(d - 1) % themes.length],
        activities: dayActs,
      ));
    }
    return plans;
  }

  String _inferType(String title) {
    final t = title.toLowerCase();
    if (t.contains('museum') || t.contains('متحف') || t.contains('bibliotheca')) return 'Museum';
    if (t.contains('mosque') || t.contains('haram') || t.contains('مسجد') || t.contains('temple') || t.contains('معبد') || t.contains('church') || t.contains('cathedral')) return 'Religious';
    if (t.contains('beach') || t.contains('شاطئ') || t.contains('sea') || t.contains('snorkel') || t.contains('diving') || t.contains('reef')) return 'Beach';
    if (t.contains('safari') || t.contains('desert') || t.contains('trek') || t.contains('hike') || t.contains('mountain')) return 'Adventure';
    if (t.contains('food') || t.contains('dinner') || t.contains('restaurant') || t.contains('cuisine') || t.contains('طعام') || t.contains('مطعم')) return 'Food';
    if (t.contains('shop') || t.contains('mall') || t.contains('bazaar') || t.contains('market') || t.contains('souk') || t.contains('سوق')) return 'Shopping';
    if (t.contains('cruise') || t.contains('boat') || t.contains('felucca') || t.contains('yacht') || t.contains('نيلية') || t.contains('nile')) return 'Cruise';
    if (t.contains('park') || t.contains('garden') || t.contains('حديقة') || t.contains('balloon') || t.contains('nature')) return 'Nature';
    if (t.contains('walk') || t.contains('corniche') || t.contains('كورنيش') || t.contains('downtown') || t.contains('old city')) return 'Sightseeing';
    if (t.contains('tower') || t.contains('bridge') || t.contains('palace') || t.contains('castle') || t.contains('citadel') || t.contains('fort')) return 'Landmark';
    return 'Attraction';
  }

  Future<void> _generate() async {
    final dest = _destCtrl.text.trim();
    if (dest.isEmpty) {
      setState(() => _error = 'Please enter a destination');
      return;
    }
    if (_sel.isEmpty) {
      setState(() => _error = 'Please select at least one interest');
      return;
    }

    final durationStr = _durationCtrl.text.isEmpty ? '5' : _durationCtrl.text;
    final duration = (int.tryParse(durationStr) ?? 5).clamp(1, 14);

    setState(() {
      _error = null;
      _cityEn = null;
      _cityAr = null;
      _destImageUrl = null;
      _hotels = [];
      _days = [];
    });

    try {
      await ProcessLoadingOverlay.run(
        context: context,
        title: 'Generating Your Plan',
        steps: ProcessLoadingPresets.aiPlan,
        task: (ctrl) async {
          await ctrl.jumpTo(0);

          final raw = await DestinationCatalogService.findRaw(name: dest) ??
              await DestinationCatalogService.findRaw(
                slug: DestinationCatalogService.toSlug(dest),
              );

          if (raw == null) {
            throw Exception(
              'City "$dest" not found.\nTry: Cairo, Dubai, Istanbul, Paris, Tokyo…',
            );
          }

          final cityEn = (raw['name'] ?? dest).toString();
          final cityAr = (raw['name_ar'] ?? cityEn).toString();
          final activities = (raw['activities'] as List? ?? [])
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();

          await ctrl.advance();

          final days = _buildItinerary(activities, duration, cityEn);

          await ctrl.advance();

          List<_Hotel> hotels = [];
          try {
            final res = await ApiService.getHotels(city: cityEn, limit: 6);
            final list = res['hotels'] as List? ?? [];
            hotels = list.map((h) => _Hotel.fromJson(h as Map)).toList();
          } catch (_) {}

          if (!mounted) return false;
          setState(() {
            _cityEn = cityEn;
            _cityAr = cityAr;
            _hotels = hotels;
            _days = days;
            _isArabic = false;
            _loading = false;
          });

          await _fetchDestinationHeroImage(cityEn);
          if (_hotels.isNotEmpty) await _enrichHotelsWithApiImages(cityEn);

          await Future.delayed(const Duration(milliseconds: 300));
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
          return true;
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
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
              onPressed: _generate,
              icon: Icon(
                Icons.auto_awesome,
                color: Theme.of(context).cardColor,
                size: 18,
              ),
              label: Text(
                'Generate My Plan',
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

  Widget _buildResultHeader() {
    final String cityName = _cityEn ?? _destCtrl.text.trim();
    // City hero from catalog (Cloudinary / assets)
    final String finalHeroImageUrl = _destImageUrl ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeroImage(finalHeroImageUrl),
                // Gradient overlay for depth
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                // City Name Overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Text(
                        'Your Custom AI Itinerary',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: Color(0xFF0D4B88),
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic ? (_cityAr ?? '') : (_cityEn ?? ''),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Color(0xFF0D1C52),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: _generate,
              child: Icon(Icons.refresh, color: Color(0xFF1A94C4)),
            ),
          ],
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChip(
              Icons.calendar_today,
              '${_durationCtrl.text.isNotEmpty ? _durationCtrl.text : 5} Days',
            ),
            _buildChip(Icons.attach_money, 'Medium'),
            _buildChip(Icons.people, '2 Travelers'),
            _buildChip(Icons.star, '100% Match', color: Colors.orange),
          ],
        ),
      ],
    );
  }

  /// Smart hero image: handles local assets AND network URLs correctly.
  Widget _buildHeroImage(String url) {
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFF0D4B88).withValues(alpha: 0.3),
        child: const Center(
          child: Icon(Icons.travel_explore, color: Colors.white54, size: 60),
        ),
      );
    }

    // Local asset — use Image.asset directly
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          color: const Color(0xFF0D4B88).withValues(alpha: 0.3),
          child: const Center(
            child: Icon(Icons.travel_explore, color: Colors.white54, size: 60),
          ),
        ),
      );
    }

    // Network URL (Cloudinary city hero)
    return ImageService.buildNetworkImage(
      imageUrl: url,
      width: double.infinity,
      height: 200,
      type: 'destination',
      citySlug: DestinationCatalogService.toSlug(_cityEn ?? _destCtrl.text.trim()),
      placeholder: Container(
        color: const Color(0xFF0D4B88).withValues(alpha: 0.3),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
        ),
      ),
      errorWidget: Container(
        color: const Color(0xFF0D4B88).withValues(alpha: 0.3),
        child: const Center(
          child: Icon(Icons.travel_explore, color: Colors.white54, size: 60),
        ),
      ),
    );
  }

  Widget _buildChip(
    IconData icon,
    String label, {
    Color color = const Color(0xFF1A94C4),
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.apartment, color: Color(0xFF0D4B88)),
            SizedBox(width: 8),
            Text(
              'Recommended Hotels',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF0D1C52),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _hotels.length,
            itemBuilder: (context, i) {
              final h = _hotels[i];
              return Container(
                width: 220,
                margin: EdgeInsets.only(right: 16, bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: h.images.isNotEmpty
                          ? ImageService.buildNetworkImage(
                              imageUrl: h.images.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 120,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(Icons.hotel, color: Colors.grey),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isArabic ? h.nameAr : h.nameEn,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(
                                ' ${h.rating}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.thumb_up,
                                color: Color(0xFF1A94C4),
                                size: 12,
                              ),
                              Text(
                                ' +3',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF1A94C4),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'From ',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '\$${h.startingFrom}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0D4B88),
                                    ),
                                  ),
                                  Text(
                                    '/night',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 10,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    ' ${h.locationType}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(_DayPlan day) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D4B88), Color(0xFF1A94C4)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    day.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: day.activities.asMap().entries.map((e) {
                final idx = e.key;
                final act = e.value;
                // Fake time logic based on index
                final hour = 10 + (idx * 2);
                final isPM = hour >= 12;
                final displayHour = hour > 12 ? hour - 12 : hour;
                final timeStr =
                    '${displayHour.toString().padLeft(2, '0')}:00 ${isPM ? 'PM' : 'AM'}';

                return Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconFor(act.type.isNotEmpty ? act.type : act.name),
                          size: 16,
                          color: Color(0xFF1A94C4),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                act.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF1A94C4),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
