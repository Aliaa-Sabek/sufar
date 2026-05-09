import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// Central place for environment configuration.
///
/// You can override at runtime using:
/// `--dart-define=API_BASE_URL=https://sufar-rho.vercel.app/api`
class AppConfig {
  static const String _apiBaseUrlDefine =
      String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://sufar-rho.vercel.app/api',
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
}

