import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/settings_viewmodel.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Consumer<SettingsViewmodel>(
        builder: (context, settingsViewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SwitchListTile(
                title: const Text("Dark Mode"),
                value: settingsViewModel.isDarkMode,
                onChanged: (value) {
                  settingsViewModel.toggleDarkMode();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}