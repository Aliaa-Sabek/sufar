import '../config/app_config.dart';

/// Builds Cloudinary delivery URLs (same account as hotel images).
class CloudinaryMediaService {
  CloudinaryMediaService._();

  static String get _base =>
      AppConfig.mediaBaseUrl.replaceAll(RegExp(r'/$'), '');

  /// Optimised delivery URL for list/card thumbnails.
  static String optimised(String url, {int width = 800}) {
    final raw = url.trim();
    if (raw.isEmpty) return '';

    if (raw.contains('res.cloudinary.com') && raw.contains('/image/upload/')) {
      if (raw.contains('/image/upload/w_') ||
          raw.contains('/image/upload/f_')) {
        return raw;
      }
      return raw.replaceFirst(
        '/image/upload/',
        '/image/upload/f_auto,q_auto,w_$width,c_fill/',
      );
    }

    // For external HTTP(S) URLs, load them directly (e.g., Pexels).
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }

    return raw;
  }

  static String hotelPath(String relativePath) {
    final path = relativePath.replaceAll(RegExp(r'^/+'), '');
    return '$_base/f_auto,q_auto,w_800,c_fill/$path';
  }
}
