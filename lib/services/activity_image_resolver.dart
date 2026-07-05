import 'dart:convert';

import 'package:flutter/services.dart';

/// Things-to-do images only — served from the curated [activity_images.json]
/// bundled in assets. No live network calls; the catalog contains hand-picked
/// Pexels URLs for every activity in every supported city.
///
/// Key format in the JSON:  "{citySlug}|{activityTitle}"
class ActivityImageResolver {
  ActivityImageResolver._();

  static Map<String, String>? _catalog;

  static Future<void> preloadCatalog() => _ensureLoaded();

  static Future<void> _ensureLoaded() async {
    if (_catalog != null) return;
    try {
      final raw = await rootBundle.loadString('assets/activity_images.json');
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      // Normalize all keys to lowercase for robust case-insensitive matching
      _catalog = decoded.map((k, v) => MapEntry(k.trim().toLowerCase(), v.toString()));
    } catch (_) {
      _catalog = {};
    }
  }

  // ── slug helpers ─────────────────────────────────────────────────────────────

  /// Normalises a city slug the same way DestinationCatalogService does.
  static String _normalise(String raw) => raw
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  // ── public API ────────────────────────────────────────────────────────────────

  /// Returns the curated Pexels URL for [title] + [citySlug].
  ///
  /// Lookup order:
  /// 1. Exact key `{citySlug}|{title}` (fast path).
  /// 2. Title-only match — any city that has this exact activity title.
  /// 3. Partial-slug match — e.g. "cairo-egypt" still finds "cairo" entries.
  /// 4. Returns `''` if nothing found (caller shows a placeholder).
  static Future<String> resolveAsync({
    required String title,
    required String citySlug,
    required String rawImage,
  }) async {
    // If the raw field is already a curated Pexels URL, trust it directly.
    final trimmed = rawImage.trim();
    if (trimmed.startsWith('https://') &&
        trimmed.toLowerCase().contains('pexels.com')) {
      return trimmed;
    }

    await _ensureLoaded();
    final catalog = _catalog;
    if (catalog == null || catalog.isEmpty) return '';

    final normSlug = _normalise(citySlug);
    final normTitle = title.trim().toLowerCase();
    final exactKey = '$normSlug|$normTitle';

    // 1️⃣ Exact match
    if (catalog.containsKey(exactKey)) return catalog[exactKey]!;

    // 2️⃣ Title-only match (any city)
    for (final entry in catalog.entries) {
      if (entry.key.endsWith('|$normTitle')) return entry.value;
    }

    // 3️⃣ Partial slug match (e.g. "sharm-el-sheikh-egypt" → "sharm-el-sheikh")
    for (final entry in catalog.entries) {
      final parts = entry.key.split('|');
      if (parts.length != 2) continue;
      final catalogSlug = parts[0];
      final catalogTitle = parts[1];
      if (catalogTitle == normTitle &&
          (normSlug.contains(catalogSlug) || catalogSlug.contains(normSlug))) {
        return entry.value;
      }
    }

    return '';
  }

  /// Synchronous lookup — for use where async is not available.
  /// Returns `''` if catalog is not loaded yet or no match found.
  static String resolveSync({
    required String title,
    required String citySlug,
  }) {
    final catalog = _catalog;
    if (catalog == null || catalog.isEmpty) return '';

    final normSlug = _normalise(citySlug);
    final normTitle = title.trim().toLowerCase();
    final exactKey = '$normSlug|$normTitle';

    if (catalog.containsKey(exactKey)) return catalog[exactKey]!;
    for (final entry in catalog.entries) {
      if (entry.key.endsWith('|$normTitle')) return entry.value;
    }
    return '';
  }
}
