import '../../models/campsite.dart';

extension LanguageCodeExtension on String {
  String toLanguageName() {
    const languageMap = {
      'en': 'English',
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'ru': 'Russian',
      'ar': 'Arabic',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'nl': 'Dutch',
      'tr': 'Turkish',
      'sv': 'Swedish',
      'pl': 'Polish',
      'cs': 'Czech',
      'el': 'Greek',
      'he': 'Hebrew',
      'hi': 'Hindi',
      'th': 'Thai',
      'id': 'Indonesian',
      'ro': 'Romanian',
      'vi': 'Vietnamese',
      'fa': 'Persian',
    };

    return languageMap[toLowerCase()] ?? this;
  }
}


extension GeoLocationCountryExtension on GeoLocation {
  String get country {
    if (_inBounds(normalizedLat, normalizedLng, 35.0, 47.0, 6.0, 19.0)) return 'Italy';
    if (_inBounds(normalizedLat, normalizedLng, 36.0, 43.0, -9.0, 3.0)) return 'Spain';
    if (_inBounds(normalizedLat, normalizedLng, 46.0, 56.0, 5.0, 16.0)) return 'Germany';
    if (_inBounds(normalizedLat, normalizedLng, 48.0, 55.0, 2.0, 7.5)) return 'France';
    if (_inBounds(normalizedLat, normalizedLng, 49.0, 59.0, -8.0, 2.0)) return 'United Kingdom';
    if (_inBounds(normalizedLat, normalizedLng, 45.5, 49.0, 14.0, 18.5)) return 'Austria';
    if (_inBounds(normalizedLat, normalizedLng, 51.0, 55.5, 5.0, 7.5)) return 'Netherlands';
    if (_inBounds(normalizedLat, normalizedLng, 34.0, 42.0, 25.0, 45.0)) return 'Greece';
    return 'Other';
  }

  bool _inBounds(double lat, double lng, double minLat, double maxLat, double minLng, double maxLng) {
    return lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng;
  }
}