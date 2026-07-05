import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Base URL — change to your deployed server URL
// For Android emulator use: http://10.0.2.2:5000
// For real device on same WiFi: http://YOUR_PC_IP:5000
// ─────────────────────────────────────────────
import '../config/app_config.dart';
import '../models/travel_office_model.dart';

class ApiService {
  static String get baseUrl {
    return AppConfig.apiBaseUrl;
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('backend_user');
    await prefs.remove('logged_in_email');
    await prefs.remove('logged_in_name');
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static const Duration _timeout = Duration(seconds: 20);

  static Future<http.Response> _send(Future<http.Response> request) {
    return request.timeout(
      _timeout,
      onTimeout: () => throw Exception(
        'Request timed out. Please check your internet connection.',
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(),
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
      }),
    ));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/verify'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code}),
    ));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    ));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);

      // Handle the user object being either direct or nested inside "data"
      final dynamic dataMap = data['data'];
      final userObj = data['user'] ?? 
                      (dataMap != null && dataMap is Map ? (dataMap['user'] ?? dataMap) : null) ?? 
                      data;
      if (userObj != null && userObj is Map) {
        final prefs = await SharedPreferences.getInstance();
        final map = Map<String, dynamic>.from(userObj);
        if (map['id'] != null && map['_id'] == null) {
          map['_id'] = map['id'].toString();
        }
        await prefs.setString('backend_user', jsonEncode(map));
        final email = map['email']?.toString();
        if (email != null && email.isNotEmpty) {
          await prefs.setString('logged_in_email', email);
        }
        final name = (map['fullName'] ?? map['name'])?.toString();
        if (name != null && name.isNotEmpty) {
          await prefs.setString('logged_in_name', name);
        }
      }
    }
    return data;
  }

  static Future<void> logout() async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: await _headers(auth: true),
    ));
    debugPrint('Logout: ${res.statusCode}');
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    ));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _headers(),
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    ));
    return jsonDecode(res.body);
  }

  // ── Profile ─────────────────────────────────────────────────────────────────

  /// Returns the logged-in user's profile from GET /users/profile.
  static Future<Map<String, dynamic>> getMyProfile() async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/users/profile'),
      headers: await _headers(auth: true),
    ));
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return data;
    }
    throw Exception(data['message']?.toString() ?? 'Failed to load profile');
  }

  /// Updates the logged-in user's profile via PUT /users/profile.
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final res = await _send(http.put(
      Uri.parse('$baseUrl/users/profile'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    ));
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    throw Exception(body['message']?.toString() ?? 'Failed to update profile');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HOTELS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getHotels({
    String? city,
    int? stars,
    double? minPrice,
    double? maxPrice,
    String? mealPlan,
    String? locationType,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (stars != null) params['stars'] = stars.toString();
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (mealPlan != null) params['mealPlan'] = mealPlan;
    if (locationType != null) params['locationType'] = locationType;

    final uri = Uri.parse('$baseUrl/hotels').replace(queryParameters: params);
    final res = await _send(http.get(uri, headers: await _headers()));
    return _decodeJsonObject(res, 'Hotels API');
  }

  static Map<String, dynamic> _decodeJsonObject(
    http.Response res,
    String label,
  ) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('$label error (${res.statusCode}): ${res.body}');
    }
    final body = utf8.decode(res.bodyBytes).trim();
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      throw FormatException('$label returned invalid JSON: $body');
    }
    throw FormatException('$label returned non-object JSON');
  }

  static Future<Map<String, dynamic>> getHotel(String id) async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/hotels/$id'),
      headers: await _headers(),
    ));
    return jsonDecode(res.body);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DESTINATIONS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getDestinations({
    bool? featured,
    int limit = 12,
    int page = 1,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };
    if (featured == true) params['featured'] = 'true';
    final uri = Uri.parse(
      '$baseUrl/destinations',
    ).replace(queryParameters: params);
    final res = await _send(http.get(uri, headers: await _headers()));
    final data = jsonDecode(res.body);
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      final inner = data['data'] ?? data['destinations'] ?? data['results'];
      if (inner is List) return inner;
    }
    return [];
  }

  static Future<Map<String, dynamic>> getDestination(String id) async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/destinations/$id'),
      headers: await _headers(),
    ));
    return jsonDecode(res.body);
  }

  /// Search destinations by name (e.g. "Cairo").
  static Future<List<dynamic>> searchDestinations({
    required String search,
    int limit = 12,
  }) async {
    final uri = Uri.parse('$baseUrl/destinations').replace(
      queryParameters: {
        'search': search,
        'limit': limit.toString(),
      },
    );
    final res = await _send(http.get(uri, headers: await _headers()));
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) {
      final inner = data['destinations'] ?? data['data'] ?? data['results'];
      if (inner is List) return inner;
    }
    return [];
  }

  /// Fetch a single destination by slug (e.g. "cairo").
  static Future<Map<String, dynamic>?> getDestinationBySlug(String slug) async {
    final detail = await getDestinationDetail(slug);
    if (detail == null) return null;
    final dest = detail['destination'];
    return dest is Map<String, dynamic> ? dest : null;
  }

  /// GET /api/destinations/:slug → { destination, topHotels }
  static Future<Map<String, dynamic>?> getDestinationDetail(String slug) async {
    if (slug.trim().isEmpty) return null;
    final res = await _send(http.get(
      Uri.parse('$baseUrl/destinations/${Uri.encodeComponent(slug.trim())}'),
      headers: await _headers(),
    ));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    return data is Map<String, dynamic> ? data : null;
  }

  /// GET /api/hotels/:slug → { hotel, rooms } (room images in rooms[].images)
  static Future<Map<String, dynamic>?> getHotelDetail(String idOrSlug) async {
    if (idOrSlug.trim().isEmpty) return null;
    final res = await _send(http.get(
      Uri.parse('$baseUrl/hotels/${Uri.encodeComponent(idOrSlug.trim())}'),
      headers: await _headers(),
    ));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    return data is Map<String, dynamic> ? data : null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLIGHTS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> searchFlights({
    String? from,
    String? to,
    String? date,
  }) async {
    final params = <String, String>{};
    if (from != null && from.isNotEmpty) params['from'] = from;
    if (to != null && to.isNotEmpty) params['to'] = to;
    if (date != null) params['date'] = date;
    final uri = Uri.parse('$baseUrl/flights').replace(queryParameters: params);
    final res = await _send(http.get(uri, headers: await _headers()));
    final data = jsonDecode(res.body);
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data['results'] ?? data['flights'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> getFlight(String id) async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/flights/$id'),
      headers: await _headers(),
    ));
    return jsonDecode(res.body);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOOKINGS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> bookHotel({
    required String hotelId,
    required String roomId,
    required String checkIn,
    required String checkOut,
    required int totalGuests,
    required Map<String, String> guestInfo,
  }) async {
    final res = await _send(http.post(
      Uri.parse('$baseUrl/bookings/hotel'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'hotelId': hotelId,
        'roomId': roomId,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'totalGuests': totalGuests,
        'guestInfo': guestInfo,
      }),
    ));
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyBookings() async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: await _headers(auth: true),
    ));
    final data = jsonDecode(res.body);
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data['results'] ?? data['bookings'] ?? [];
    }
    return [];
  }

  static Future<Map<String, dynamic>> cancelBooking(String id) async {
    final res = await _send(http.put(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
      headers: await _headers(auth: true),
    ));
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> payBooking(String id) async {
    final res = await _send(http.put(
      Uri.parse('$baseUrl/bookings/$id/pay'),
      headers: await _headers(auth: true),
    ));
    return jsonDecode(res.body);
  }

  static Future<bool> checkAvailability({
    required String roomId,
    required String checkIn,
    required String checkOut,
  }) async {
    final uri = Uri.parse('$baseUrl/bookings/check-availability').replace(
      queryParameters: {
        'roomId': roomId,
        'checkIn': checkIn,
        'checkOut': checkOut,
      },
    );
    final res = await _send(http.get(uri, headers: await _headers()));
    final data = jsonDecode(res.body);
    return data['available'] == true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRAVEL OFFICES
  // ══════════════════════════════════════════════════════════════════════════

  static List<TravelOfficeModel> parseTravelOfficesList(dynamic raw) {
    if (raw is! List) return [];
    final offices = <TravelOfficeModel>[];
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        offices.add(
          TravelOfficeModel.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (e) {
        debugPrint('[ApiService] Skip travel office parse: $e');
      }
    }
    return offices;
  }

  static Future<List<TravelOfficeModel>> fetchTravelOffices({
    String? search,
    String? city,
    double? minRating,
    int page = 1,
    int limit = 10,
  }) async {
    final response = await getTravelOffices(
      search: search,
      city: city,
      minRating: minRating,
      page: page,
      limit: limit,
    );
    return parseTravelOfficesList(response['data']);
  }

  static Future<Map<String, dynamic>> getTravelOffices({
    String? search,
    String? city,
    double? minRating,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (city != null && city.isNotEmpty) params['city'] = city;
    if (minRating != null) params['minRating'] = minRating.toString();

    final uri = Uri.parse(
      '$baseUrl/travel-offices',
    ).replace(queryParameters: params);
    final res = await _send(http.get(uri, headers: await _headers()));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Travel offices API error (${res.statusCode}): ${res.body}',
      );
    }
    final data = jsonDecode(res.body);
    // Backend returns: { total, page, pages, data: [...] }
    return data is Map<String, dynamic> ? data : {'data': [], 'total': 0};
  }

  static Future<Map<String, dynamic>> getTravelOffice(String id) async {
    final res = await _send(http.get(
      Uri.parse('$baseUrl/travel-offices/$id'),
      headers: await _headers(),
    ));
    return jsonDecode(res.body);
  }
}
