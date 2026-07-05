import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/destination_model.dart';
import '../models/hotel_model.dart';
import 'activity_image_resolver.dart';
import 'api_service.dart';
import 'image_service.dart';

/// Aligned with [Nada-Khaled21/Sufar](https://github.com/Nada-Khaled21/Sufar):
/// - Cities + hotel list → Vercel `/api/destinations`, `/api/hotels`
/// - City image → Cloudinary `sufar/destinations/` (from `Images/destinations/{slug}`)
/// - Hotel images → `sufar/hotels/{slug}/general/` (from `Images/{city}/{hotel}/general`)
/// - Activities → local JSON + Pexels (`activity_images.json`)
class DestinationCatalogService {
  static List<Map<String, dynamic>>? _cache;
  static DateTime? _cacheTime;
  static const cacheDuration = Duration(hours: 1);

  static const featuredSlugs = [
    'cairo',
    'alexandria',
    'hurghada',
    'sharm-el-sheikh',
    'dubai',
    'paris',
    'istanbul',
    'maldives',
  ];

  static Future<List<Map<String, dynamic>>> loadRawCatalog() async {
    if (_cache != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < cacheDuration) {
        return _cache!;
      }
    }

    final localBySlug = await _localCatalogBySlug();

    try {
      final apiList = await ApiService.getDestinations(limit: 100);
      if (apiList.isNotEmpty) {
        final merged = <Map<String, dynamic>>[];
        final seen = <String>{};

        for (final raw in apiList.whereType<Map>()) {
          final m = Map<String, dynamic>.from(raw);
          final slug = toSlug((m['slug'] ?? m['name'] ?? '').toString());
          m['slug'] = slug;

          final local = localBySlug[slug];
          if (local != null) {
            m['activities'] = local['activities'];
            m.putIfAbsent('name_ar', () => local['name_ar']);
            final localImg = (local['image'] ?? '').toString();
            if (localImg.startsWith('assets/')) {
              m['image'] = localImg;
            }
          }

          // City hero: Cloudinary/assets only — strip any Pexels from API.
          final hero = resolveCityHeroUrl(m);
          if (hero.isNotEmpty) m['image'] = hero;

          merged.add(m);
          seen.add(slug);
        }

        for (final entry in localBySlug.entries) {
          if (!seen.contains(entry.key)) {
            merged.add(Map<String, dynamic>.from(entry.value));
          }
        }

        _cache = merged;
        _cacheTime = DateTime.now();
        return _cache!;
      }
    } catch (e) {
      debugPrint('[DestinationCatalogService] API catalog failed: $e');
    }

    _cache = localBySlug.values.toList();
    _cacheTime = DateTime.now();
    return _cache!;
  }

  static Future<Map<String, Map<String, dynamic>>> _localCatalogBySlug() async {
    final list = await _loadLocalFromAssets();
    return {
      for (final d in list)
        toSlug((d['slug'] ?? d['name'] ?? '').toString()): d,
    };
  }

  static Future<List<Map<String, dynamic>>> _loadLocalFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/destinations_data.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        m['slug'] = toSlug((m['slug'] ?? m['name'] ?? '').toString());
        return m;
      }).toList();
    } catch (e) {
      debugPrint('[DestinationCatalogService] Local load failed: $e');
      return [];
    }
  }

  static String toSlug(String value) {
    return value
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  static Future<Map<String, dynamic>?> findRaw({
    String? slug,
    String? name,
  }) async {
    final all = await loadRawCatalog();
    final normalizedSlug = slug != null ? toSlug(slug) : '';
    final normalizedName = name?.trim().toLowerCase() ?? '';

    for (final dest in all) {
      final destName = (dest['name'] ?? '').toString();
      final destSlug = dest['slug']?.toString() ?? toSlug(destName);
      if (normalizedSlug.isNotEmpty && toSlug(destSlug) == normalizedSlug) {
        return dest;
      }
      if (normalizedName.isNotEmpty &&
          destName.toLowerCase() == normalizedName) {
        return dest;
      }
    }
    return null;
  }

  /// City hero from Cloudinary `sufar/destinations/` or bundled assets — never Pexels.
  static String resolveCityHeroUrl(Map<String, dynamic> dest) {
    final slug =
        dest['slug']?.toString() ?? toSlug((dest['name'] ?? '').toString());
    
    // Prioritize local asset images by slug
    final localAsset = ImageService.getLocalAssetForSlug(slug);
    if (localAsset != null) return localAsset;

    final raw = (dest['image'] ?? '').toString().trim();

    if (raw.startsWith('assets/')) return raw;

    if (ImageService.isPexelsUrl(raw)) {
      return ImageService.cloudinaryDestinationUrl(slug);
    }

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      if (ImageService.isCloudinaryUrl(raw)) {
        return ImageService.urlForWidget(
          raw,
          citySlug: slug,
          type: 'destination',
        );
      }
      return ImageService.cloudinaryDestinationUrl(slug);
    }

    return ImageService.urlForWidget(
      raw.isNotEmpty ? raw : '$slug.jpg',
      citySlug: slug,
      type: 'destination',
    );
  }

  static Future<Map<String, dynamic>> enrichForModel(
    Map<String, dynamic> dest,
  ) async {
    final slug =
        dest['slug']?.toString() ?? toSlug((dest['name'] ?? '').toString());
    final enriched = Map<String, dynamic>.from(dest);
    enriched['slug'] = slug;

    final hero = resolveCityHeroUrl(dest);
    if (hero.isNotEmpty) enriched['image'] = hero;

    final activityMaps = dest['activities'] is List
        ? (dest['activities'] as List).whereType<Map>().toList()
        : <Map>[];

    final enrichedActivities = await Future.wait(
      activityMaps.map((act) async {
        final map = Map<String, dynamic>.from(act);
        final title = (map['title'] ?? '').toString();

        var resolved = await ActivityImageResolver.resolveAsync(
          title: title,
          citySlug: slug,
          rawImage: (map['image'] ?? '').toString(),
        );

        if (resolved.isEmpty) {
          resolved = _genericFallbackImage(title);
        }

        if (resolved.isNotEmpty) map['image'] = resolved;
        return map;
      }),
    );

    enriched['activities'] = enrichedActivities;
    enriched.remove('images');

    return enriched;
  }

  /// Returns a reliable Pexels placeholder image based on activity keywords.
  static String _genericFallbackImage(String title) {
    final t = title.toLowerCase();
    if (t.contains('museum') || t.contains('متحف') || t.contains('library') || t.contains('bibliotheca')) {
      return 'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('mosque') || t.contains('haram') || t.contains('مسجد') || t.contains('masjid')) {
      return 'https://images.pexels.com/photos/2403212/pexels-photo-2403212.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('temple') || t.contains('معبد') || t.contains('pyramid') || t.contains('أهرام')) {
      return 'https://images.pexels.com/photos/71241/pexels-photo-71241.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('beach') || t.contains('شاطئ') || t.contains('sea') || t.contains('snorkel') || t.contains('diving') || t.contains('reef')) {
      return 'https://images.pexels.com/photos/1001682/pexels-photo-1001682.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('desert') || t.contains('safari') || t.contains('dune')) {
      return 'https://images.pexels.com/photos/17388963/pexels-photo-17388963.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('cruise') || t.contains('boat') || t.contains('felucca') || t.contains('nile') || t.contains('yacht')) {
      return 'https://images.pexels.com/photos/3137062/pexels-photo-3137062.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('park') || t.contains('garden') || t.contains('balloon') || t.contains('nature')) {
      return 'https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('food') || t.contains('dinner') || t.contains('restaurant') || t.contains('cuisine') || t.contains('مطعم')) {
      return 'https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('shop') || t.contains('mall') || t.contains('bazaar') || t.contains('market') || t.contains('souk') || t.contains('سوق')) {
      return 'https://images.pexels.com/photos/1476888/pexels-photo-1476888.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('tower') || t.contains('bridge') || t.contains('palace') || t.contains('castle') || t.contains('fort') || t.contains('citadel')) {
      return 'https://images.pexels.com/photos/532826/pexels-photo-532826.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    if (t.contains('walk') || t.contains('corniche') || t.contains('downtown') || t.contains('كورنيش')) {
      return 'https://images.pexels.com/photos/1436747/pexels-photo-1436747.jpeg?auto=compress&cs=tinysrgb&w=800';
    }
    // Generic travel/landmark fallback
    return 'https://images.pexels.com/photos/3278215/pexels-photo-3278215.jpeg?auto=compress&cs=tinysrgb&w=800';
  }

  /// GET /api/destinations/:slug → { destination, topHotels }
  static Future<({DestinationModel? destination, List<Hotel> topHotels})>
  destinationDetailFromApi({required String slug, String? name}) async {
    final detail = await ApiService.getDestinationDetail(slug);
    final catalog = await destinationFor(slug: slug, name: name);

    if (catalog == null && detail == null) {
      return (destination: null, topHotels: <Hotel>[]);
    }

    var model = catalog;
    if (detail != null) {
      final apiDest = detail['destination'];
      if (apiDest is Map<String, dynamic>) {
        final merged = Map<String, dynamic>.from(apiDest);
        if (catalog != null) {
          merged['activities'] = catalog.activities
              .map(
                (a) => {
                  'title': a.title,
                  'description': a.description,
                  'image': a.imageUrl,
                },
              )
              .toList();
        }
        model = DestinationModel.fromJson(await enrichForModel(merged));
      }
    }

    final topHotels = <Hotel>[];
    final rawHotels = detail?['topHotels'];
    if (rawHotels is List) {
      for (final item in rawHotels) {
        if (item is! Map) continue;
        try {
          topHotels.add(Hotel.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          debugPrint('[DestinationCatalogService] topHotel parse: $e');
        }
      }
    }

    return (destination: model, topHotels: topHotels);
  }

  static Future<DestinationModel?> destinationFor({
    String? slug,
    String? name,
  }) async {
    final raw = await findRaw(slug: slug, name: name);
    if (raw == null) return null;
    return DestinationModel.fromJson(await enrichForModel(raw));
  }

  static Future<List<DestinationModel>> allDestinations() async {
    final all = await loadRawCatalog();
    final enriched = await Future.wait(all.map(enrichForModel));
    return enriched.map(DestinationModel.fromJson).toList();
  }

  static Future<List<DestinationModel>> featuredDestinations({
    int limit = 8,
  }) async {
    final all = await allDestinations();
    final bySlug = {for (final d in all) d.slug: d};

    final picked = <DestinationModel>[];
    for (final slug in featuredSlugs) {
      final d = bySlug[slug];
      if (d != null) picked.add(d);
      if (picked.length >= limit) return picked;
    }

    for (final d in all) {
      if (picked.length >= limit) break;
      if (!picked.any((p) => p.slug == d.slug)) picked.add(d);
    }
    return picked;
  }

  static Future<List<ActivityModel>> activitiesFor({
    String? slug,
    String? name,
  }) async {
    final dest = await destinationFor(slug: slug, name: name);
    return dest?.activities ?? [];
  }
}
