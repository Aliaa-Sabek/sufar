import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import 'cloudinary_media_service.dart';

/// Matches [Nada-Khaled21/Sufar](https://github.com/Nada-Khaled21/Sufar) + seedMaster.js:
///
/// Local `Images/` folder:
///   Images/destinations/{slug}/     → city cover (uploaded to Cloudinary)
///   Images/{citySlug}/{hotel}/general/
///   Images/{citySlug}/{hotel}/rooms/
///
/// Cloudinary after seed:
///   sufar/destinations/{file}       → city
///   sufar/hotels/{hotel}/general/   → hotel
///   sufar/hotels/{hotel}/rooms/     → rooms (via GET /api/hotels/:slug)
///
/// Pexels → activities only ([ActivityImageResolver]).
class ImageService {
  ImageService._();

  static const Map<String, String> _httpHeaders = {
    'Accept': 'image/avif,image/webp,image/*,*/*;q=0.8',
    'User-Agent': 'SufarApp/1.0 Flutter',
  };

  /// Cloudinary city cover: `sufar/destinations/{slug}.jpg`
  static String cloudinaryDestinationUrl(String citySlug, {String? fileName}) {
    final slug = citySlug.trim().toLowerCase();
    if (slug.isEmpty) return '';
    final file = fileName ?? '$slug.jpg';
    final base = AppConfig.mediaBaseUrl.replaceAll(RegExp(r'/$'), '');
    return CloudinaryMediaService.optimised('$base/sufar/destinations/$file');
  }

  /// Maps a destination slug to its corresponding local asset image.
  static String? getLocalAssetForSlug(String slug) {
    final s = slug.trim().toLowerCase();
    if (s == 'abu-dhabi') return 'assets/destinations/abu-dhabi.png';
    if (s == 'al-madinah' || s == 'al-madina') return 'assets/destinations/al-madina.png';
    if (s == 'alexandria') return 'assets/destinations/alexandria.png';
    if (s == 'amman') return 'assets/destinations/amman.png';
    if (s == 'aswan') return 'assets/destinations/aswan.jpg';
    if (s == 'barcelona') return 'assets/destinations/barcelona.jpg';
    if (s == 'beirut') return 'assets/destinations/beirut.png';
    if (s == 'cairo') return 'assets/destinations/cairo.jpg';
    if (s == 'doha') return 'assets/destinations/doha.png';
    if (s == 'dubai') return 'assets/destinations/dubai.jpg';
    if (s == 'hurghada') return 'assets/destinations/hurghada.jpeg';
    if (s == 'istanbul') return 'assets/destinations/istanbul.jpg';
    if (s == 'jeddah') return 'assets/destinations/jeddah.jpeg';
    if (s == 'london') return 'assets/destinations/london.png';
    if (s == 'los-angeles') return 'assets/destinations/los-angeles.png';
    if (s == 'luxor') return 'assets/destinations/luxor.png';
    if (s == 'makkah') return 'assets/destinations/makkah.jpeg';
    if (s == 'maldives') return 'assets/destinations/maldives.jpg';
    if (s == 'new-york') return 'assets/destinations/new-york.png';
    if (s == 'paris') return 'assets/destinations/paris.jpg';
    if (s == 'riyadh') return 'assets/destinations/riyadh.png';
    if (s == 'rome') return 'assets/destinations/rome.jpg';
    if (s == 'sharm-el-sheikh') return 'assets/destinations/sharm-el-sheikh.jpg';
    if (s == 'tokyo') return 'assets/destinations/tokyo.jpg';
    return null;
  }

  static bool isPexelsUrl(String url) =>
      url.toLowerCase().contains('pexels.com');

  static bool isCloudinaryUrl(String url) => url.contains('res.cloudinary.com');

  static bool isActivityType(String? type) =>
      type == 'activity' || type == 'things-to-do';

  /// Full CDN URL — Cloudinary always; Pexels only when [type] is activity.
  static bool isDirectCdnUrl(String url, {String? type}) {
    final u = url.trim();
    if (!u.startsWith('https://')) return false;
    if (isCloudinaryUrl(u)) return true;
    return isPexelsUrl(u) && isActivityType(type);
  }

  static String dedupeKey(String url) => url.split('?').first.trim();

  /// Widget-safe URL. Pexels is allowed **only** for `type: activity`.
  static String urlForWidget(
    String url, {
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
  }) {
    url = url.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('assets/')) return url;

    // Use local high-quality assets for destinations if available
    if (type == 'destination') {
      final slugToUse = (citySlug != null && citySlug.isNotEmpty)
          ? citySlug
          : url.split('/').last.split('.').first;
      final localAsset = getLocalAssetForSlug(slugToUse);
      if (localAsset != null) return localAsset;
    }

    if (isPexelsUrl(url)) {
      if (isActivityType(type)) return url;
      if (type == 'destination' && (citySlug?.isNotEmpty ?? false)) {
        return cloudinaryDestinationUrl(citySlug!);
      }
      return '';
    }

    if (url.startsWith('https://') || url.startsWith('http://')) {
      final https = url.startsWith('http://')
          ? 'https://${url.substring(7)}'
          : url;
      if (isCloudinaryUrl(https)) {
        return CloudinaryMediaService.optimised(https);
      }
      if (_rejectForType(https, type)) return '';
      return https;
    }

    return resolveUrl(
      url,
      citySlug: citySlug,
      cityName: cityName,
      type: type,
      hotelSlug: hotelSlug,
    );
  }

  static bool _rejectForType(String url, String? type) {
    if (isActivityType(type)) return false;
    if (type != null && type.startsWith('hotel')) return isPexelsUrl(url);
    return isPexelsUrl(url);
  }

  static String normalizeImageUrl(
    String url, {
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
  }) {
    url = url.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('//')) url = 'https:$url';
    if (url.startsWith('http://')) url = 'https://${url.substring(7)}';

    if (url.startsWith('https://')) {
      if (_rejectForType(url, type)) return '';
      return url;
    }
    if (url.startsWith('assets/')) return url;

    return resolveMediaUrl(
      url,
      citySlug: citySlug,
      cityName: cityName,
      type: type,
      hotelSlug: hotelSlug,
    );
  }

  static String resolveMediaUrl(
    String url, {
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
  }) {
    url = url.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('//')) url = 'https:$url';
    if (url.startsWith('http://')) url = 'https://${url.substring(7)}';
    if (url.startsWith('https://')) {
      if (_rejectForType(url, type)) return '';
      return url;
    }

    final base = AppConfig.mediaBaseUrl.replaceAll(RegExp(r'/$'), '');
    final slug = (citySlug ?? '').trim().toLowerCase();
    var path = url.replaceAll(RegExp(r'^/+'), '');

    if (path.startsWith('sufar/')) return '$base/$path';

    if (type == 'destination') {
      final file = path.contains('/') ? path.split('/').last : path;
      if (file.contains('.')) {
        return '$base/sufar/destinations/$file';
      }
      if (slug.isNotEmpty) {
        return '$base/sufar/destinations/$slug.jpg';
      }
      return '$base/sufar/destinations/$file';
    }

    if (type == 'hotel' || type == 'hotel-general' || type == 'hotel-room') {
      final folder = type == 'hotel-room' ? 'rooms' : 'general';
      final hSlug = hotelSlug ?? _hotelSlugFromPath(path);
      final file = _fileName(path);
      if (hSlug.isNotEmpty) {
        return '$base/sufar/hotels/$hSlug/$folder/$file';
      }
    }

    if (path.contains('/')) return '$base/sufar/hotels/$path';
    return '';
  }

  static String _hotelSlugFromPath(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length >= 2 && (parts[1] == 'general' || parts[1] == 'rooms')) {
      return parts[0];
    }
    if (parts.length >= 3) return parts[1];
    return parts[0];
  }

  static String _fileName(String path) {
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? path : parts.last;
  }

  static String resolveUrl(
    String url, {
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
  }) {
    final n = normalizeImageUrl(
      url,
      citySlug: citySlug,
      cityName: cityName,
      type: type,
      hotelSlug: hotelSlug,
    );
    if (n.isNotEmpty) return CloudinaryMediaService.optimised(n);

    final resolved = resolveMediaUrl(
      url,
      citySlug: citySlug,
      cityName: cityName,
      type: type,
      hotelSlug: hotelSlug,
    );
    if (resolved.isNotEmpty) return CloudinaryMediaService.optimised(resolved);
    return '';
  }

  static List<String> hotelGeneralImages(List<String> images) =>
      images.where((u) => u.contains('/general/')).toList();

  static List<String> hotelRoomImages(List<String> images) =>
      images.where((u) => u.contains('/rooms/')).toList();

  static ImageProvider getNetworkImage(
    String url, {
    String? type,
    String? citySlug,
    String? cityName,
    String? hotelSlug,
  }) {
    final n = urlForWidget(
      url,
      citySlug: citySlug,
      cityName: cityName,
      type: type,
      hotelSlug: hotelSlug,
    );
    if (n.isEmpty) return const AssetImage('assets/Sufar Logo Blue.png');
    if (n.startsWith('assets/')) {
      return AssetImage(n);
    }
    return CachedNetworkImageProvider(n, headers: _httpHeaders);
  }

  static Widget buildNetworkCover({
    required String imageUrl,
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: fit,
        errorBuilder: (_, _, _) => ColoredBox(
          color: Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            color: Colors.grey.shade500,
            size: 40,
          ),
        ),
      );
    }

    String normalized = imageUrl;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      normalized = urlForWidget(
        imageUrl,
        citySlug: citySlug,
        cityName: cityName,
        type: type,
        hotelSlug: hotelSlug,
      );
    } else if (isCloudinaryUrl(imageUrl)) {
      normalized = CloudinaryMediaService.optimised(imageUrl);
    }

    if (normalized.isEmpty) {
      return ColoredBox(
        color: Colors.grey.shade300,
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey.shade500,
          size: 40,
        ),
      );
    }

    if (normalized.startsWith('assets/')) {
      return Image.asset(
        normalized,
        fit: fit,
        errorBuilder: (_, _, _) => ColoredBox(
          color: Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            color: Colors.grey.shade500,
            size: 40,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: normalized,
      httpHeaders: _httpHeaders,
      fit: fit,
      placeholder: (_, _) => ColoredBox(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, _, error) {
        debugPrint('[ImageService] Failed: $normalized\n$error');
        return ColoredBox(
          color: Colors.grey.shade300,
          child: Icon(
            Icons.broken_image,
            color: Colors.grey.shade500,
            size: 40,
          ),
        );
      },
    );
  }

  static Widget buildNetworkImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    String? citySlug,
    String? cityName,
    String? type,
    String? hotelSlug,
  }) {
    // Handle asset images first
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        fit: fit,
        errorBuilder: (_, _, _) => errorWidget ?? _defaultError(width, height),
      );
    }

    String normalized = imageUrl;
    if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
      normalized = urlForWidget(
        imageUrl,
        citySlug: citySlug,
        cityName: cityName,
        type: type,
        hotelSlug: hotelSlug,
      );
    } else if (isCloudinaryUrl(imageUrl)) {
      normalized = CloudinaryMediaService.optimised(imageUrl);
    }

    if (normalized.isEmpty) {
      return errorWidget ?? _defaultError(width, height);
    }

    if (normalized.startsWith('assets/')) {
      return Image.asset(
        normalized,
        width: width.isFinite ? width : null,
        height: height.isFinite ? height : null,
        fit: fit,
        errorBuilder: (_, _, _) => errorWidget ?? _defaultError(width, height),
      );
    }

    return CachedNetworkImage(
      imageUrl: normalized,
      httpHeaders: _httpHeaders,
      width: width.isFinite ? width : null,
      height: height.isFinite ? height : null,
      fit: fit,
      placeholder: (_, _) => placeholder ?? _defaultLoading(width, height),
      errorWidget: (_, _, error) {
        debugPrint('[ImageService] Failed: $normalized\n$error');
        return errorWidget ?? _defaultError(width, height);
      },
    );
  }

  static void preloadImages(BuildContext context, List<String> urls) {
    for (final url in urls) {
      final n = urlForWidget(url);
      if (n.isNotEmpty) {
        precacheImage(
          CachedNetworkImageProvider(n, headers: _httpHeaders),
          context,
        );
      }
    }
  }

  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  static Widget _defaultLoading(double width, double height) => Container(
    width: width.isFinite ? width : null,
    height: height.isFinite ? height : null,
    color: Colors.grey.shade200,
    child: const Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ),
  );

  static Widget _defaultError(double width, double height) => Container(
    width: width.isFinite ? width : null,
    height: height.isFinite ? height : null,
    color: Colors.grey.shade300,
    child: Icon(Icons.broken_image, color: Colors.grey.shade500, size: 40),
  );
}
