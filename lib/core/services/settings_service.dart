import 'package:eventura/core/models/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  bool _isLightMode = true;

  bool get isLightMode => _isLightMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('light_mode') ?? true;
  }

  Future<Settings> getAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isLightMode = prefs.getBool('light_mode') ?? true;
    return Settings(lightMode: _isLightMode);
  }

  Future<Settings?> toggleLightMode() async {
    _isLightMode = !_isLightMode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('light_mode', _isLightMode);
      return Settings(lightMode: _isLightMode);
    } catch (e) {
      print("Error saving light mode preference: $e");
      return null;
    }
  }
}
