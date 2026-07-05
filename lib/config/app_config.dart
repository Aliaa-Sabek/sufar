import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Central place for environment configuration.
///
/// You can override at runtime using:
/// `--dart-define=API_BASE_URL=https://sufar-rho.vercel.app/api`
/// `--dart-define=AI_SERVICE_URL=https://sufar-production.up.railway.app`
class AppConfig {
  static const String _apiBaseUrlDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sufar-rho.vercel.app/api',
  );

  static const String _aiServiceUrlDefine = String.fromEnvironment(
    'AI_SERVICE_URL',
    defaultValue: 'https://sufar-production.up.railway.app',
  );

  /// Cloudinary base used when the API returns relative media paths.
  static const String mediaBaseUrl = String.fromEnvironment(
    'MEDIA_BASE_URL',
    defaultValue: 'https://res.cloudinary.com/dgggctaxn/image/upload',
  );

  static String get apiBaseUrl {
    if (_apiBaseUrlDefine.trim().isNotEmpty) {
      return _apiBaseUrlDefine.trim().replaceAll(RegExp(r'/$'), '');
    }

    // Default fallback for local development (when API_BASE_URL is empty).
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://127.0.0.1:5000/api';
  }

  static String get aiServiceUrl {
    if (_aiServiceUrlDefine.trim().isNotEmpty) {
      return _aiServiceUrlDefine.trim().replaceAll(RegExp(r'/$'), '');
    }

    // Default fallback for local development
    if (kIsWeb) return 'http://localhost:5000';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    return 'http://127.0.0.1:5000';
  }
}
