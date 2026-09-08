import 'package:shared_preferences/shared_preferences.dart';

/// Service handler untuk SharedPreferences (Day 17)
class PreferenceHandler {
  static SharedPreferences? _prefs;

  /// Inisialisasi SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Getter untuk instance SharedPreferences
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
        'PreferenceHandler belum diinisialisasi. Panggil PreferenceHandler.init() di main().',
      );
    }
    return _prefs!;
  }

  // Helper methods untuk kemudahan akses data
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  static Future<bool> clear() async {
    return await prefs.clear();
  }
}
