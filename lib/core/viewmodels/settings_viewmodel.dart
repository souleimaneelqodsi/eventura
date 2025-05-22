import 'package:eventura/core/models/settings.dart';
import 'package:eventura/core/services/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SettingsViewmodel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  final Logger _logger = Logger();
  late Settings _settings;

  Settings get settings => _settings;

  bool _loadAttempted = false;
  bool get loadAttempted => _loadAttempted;

  Future<void> loadSettings() async {
    _loadAttempted = true;
    try {
      _settings = await _settingsService.getAllSettings();
      _logger.i(
        "Settings loaded successfully: lightMode is ${_settings.lightMode}",
      );
    } catch (e, stackTrace) {
      _logger.e(
        "ERROR loading settings in SettingsViewmodel!",
        error: e,
        stackTrace: stackTrace,
      );

      _settings = Settings(lightMode: true);
      _logger.w("Initialized _settings with default values due to an error.");
    } finally {
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    if (!_loadAttempted) {
      _logger.w(
        "Attempted to toggle dark mode before settings load was attempted.",
      );
    }
    final updatedSettings = await _settingsService.toggleLightMode();
    if (updatedSettings != null) {
      _settings = updatedSettings;
      notifyListeners();
      _logger.i("Dark mode toggled: lightMode is now ${_settings.lightMode}");
    }
  }
}
