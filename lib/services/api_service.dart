import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────
// Base URL — change to your deployed server URL
// For Android emulator use: http://10.0.2.2:5000
// For real device on same WiFi: http://YOUR_PC_IP:5000
// ─────────────────────────────────────────────
import 'dart:io' show Platform;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://127.0.0.1:5000/api';
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
  }

  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(),
      body: jsonEncode({'fullName': fullName, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String email,
    required String code,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/verify'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200 && data['token'] != null) {
      await saveToken(data['token']);
      
      // Handle the user object being either direct or nested inside "data"
      final userObj = data['user'] ?? (data['data'] != null ? data['data']['user'] : null);
      if (userObj != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('backend_user', jsonEncode(userObj));
      }
    }
    return data;
  }

  static Future<void> logout() async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: await _headers(auth: true),
    );
    debugPrint('Logout: ${res.statusCode}');
    await clearToken();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: await _headers(),
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: await _headers(),
      body: jsonEncode({'email': email, 'code': code, 'newPassword': newPassword}),
    );
    return jsonDecode(res.body);
  }

  // ── Profile ─────────────────────────────────────────────────────────────────

  /// Returns the logged-in user's profile from the backend.
  static Future<Map<String, dynamic>> getMyProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: await _headers(auth: true),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Updates the logged-in user's profile.
  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final res = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _headers(auth: true),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
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
    final res = await http.get(uri, headers: await _headers());
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getHotel(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/hotels/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DESTINATIONS
  // ══════════════════════════════════════════════════════════════════════════

  static Future<List<dynamic>> getDestinations({bool? featured}) async {
    final params = <String, String>{};
    if (featured == true) params['featured'] = 'true';
    final uri = Uri.parse('$baseUrl/destinations').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  static Future<Map<String, dynamic>> getDestination(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/destinations/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
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
    final res = await http.get(uri, headers: await _headers());
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  static Future<Map<String, dynamic>> getFlight(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/flights/$id'),
      headers: await _headers(),
    );
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
    final res = await http.post(
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
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyBookings() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bookings/my'),
      headers: await _headers(auth: true),
    );
    final data = jsonDecode(res.body);
    return data is List ? data : [];
  }

  static Future<Map<String, dynamic>> cancelBooking(String id) async {
    final res = await http.put(
      Uri.parse('$baseUrl/bookings/$id/cancel'),
      headers: await _headers(auth: true),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> payBooking(String id) async {
    final res = await http.put(
      Uri.parse('$baseUrl/bookings/$id/pay'),
      headers: await _headers(auth: true),
    );
    return jsonDecode(res.body);
  }

  static Future<bool> checkAvailability({
    required String roomId,
    required String checkIn,
    required String checkOut,
  }) async {
    final uri = Uri.parse('$baseUrl/bookings/check-availability').replace(
      queryParameters: {'roomId': roomId, 'checkIn': checkIn, 'checkOut': checkOut},
    );
    final res = await http.get(uri, headers: await _headers());
    final data = jsonDecode(res.body);
    return data['available'] == true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRAVEL OFFICES
  // ══════════════════════════════════════════════════════════════════════════

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

    final uri = Uri.parse('$baseUrl/travel-offices').replace(queryParameters: params);
    final res = await http.get(uri, headers: await _headers());
    final data = jsonDecode(res.body);
    // Backend returns: { total, page, pages, data: [...] }
    return data is Map<String, dynamic> ? data : {'data': [], 'total': 0};
  }

  static Future<Map<String, dynamic>> getTravelOffice(String id) async {
    final res = await http.get(
      Uri.parse('$baseUrl/travel-offices/$id'),
      headers: await _headers(),
    );
    return jsonDecode(res.body);
  }
}
