import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Asset paths and constants
/// مركز واحد لجميع مسارات الصور والـ Assets
class AssetPaths {
  // Logos
  static const String sufarLogoBlue = 'assets/Sufar Logo Blue.png';
  static const String sufarLogo = 'assets/Sufar.png';

  // Backgrounds
  static const String homeBg = 'assets/home_bg.png';
  static const String flightsBg = 'assets/flights_bg.png';
  static const String cloudsBg = 'assets/clouds_bg.png';

  // Tour Images
  static const String allTours = 'assets/all_tours.png';

  // Onboarding Images
  static const String onboarding1 = 'assets/Group 81.png';
  static const String onboarding2 = 'assets/Group 416.png';
  static const String onboarding3 = 'assets/Group 417.png';

  // Missing Images (Please add these)
  static const String travelIllustration =
      'assets/Image (Travel illustration).png';
  static const String forgotPasswordImage = 'assets/image 7.png';

  // Data Files
  static const String intentsJson = 'assets/intents.json';
}

/// Asset loading errors helper
class AssetHelper {
  /// Check if asset exists by trying to load it
  static Future<bool> assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get fallback widget for missing assets
  static Widget getFallbackWidget({
    String title = 'Image Not Found',
    IconData icon = Icons.image_not_supported,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}
