import 'package:eventura/core/models/settings.dart';
import 'package:eventura/core/services/settings_service.dart';
import 'package:flutter/material.dart';

class SettingsViewmodel extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();

  late Settings _settings;

  Settings get settings => _settings;

  Future<void> loadSettings() async {
    _settings = await _settingsService.getAllSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final updatedSettings = await _settingsService.toggleLightMode();
    if (updatedSettings != null) {
      _settings = updatedSettings;
      notifyListeners();
    }
  }
}