import 'package:flutter/services.dart';

class MapStyleLoader {
  static String? _cachedStyle;

  static Future<String> loadStyle() async {
    if (_cachedStyle != null) return _cachedStyle!;
    _cachedStyle = await rootBundle.loadString('assets/map_styles.json');
    return _cachedStyle!;
  }

  static String? get cachedStyle => _cachedStyle;
}
