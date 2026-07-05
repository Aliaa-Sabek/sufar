import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// Service for interacting with AI backend
/// Handles travel recommendations, planning, and other AI features
class AIService {
  static String get _baseUrl => AppConfig.aiServiceUrl;

  /// Get travel recommendation from AI
  ///
  /// Parameters:
  /// - activities: List of travel interests/activities
  /// - budget: Budget amount (string e.g. '500')
  /// - duration: Trip duration in days (integer)
  /// - travelers: Number of travelers (default 2)
  static Future<Map<String, dynamic>> getRecommendation({
    required List<String> activities,
    required String budget,
    required int duration,
    int travelers = 2,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/recommend'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'activities': activities,
              'budget': budget,
              'duration': duration,
              'travelers': travelers,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        throw Exception(
          'AI Service error (${response.statusCode}): ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get recommendation: $e');
    }
  }

  /// Chat with AI travel assistant
  ///
  /// Parameters:
  /// - message: User message
  /// - language: Language preference ('en', 'ar', or 'both')
  static Future<Map<String, dynamic>> chat({
    required String message,
    String language = 'both',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'message': message, 'language': language}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        throw Exception(
          'Chat service error (${response.statusCode}): ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Get available cities for recommendation
  static Future<List<String>> getAvailableCities() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/cities'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) return List<String>.from(data);
        if (data is Map && data['cities'] is List) {
          return List<String>.from(data['cities']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check AI service availability
  static Future<bool> isAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
