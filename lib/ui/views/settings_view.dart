import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewmodel>(context);
    viewModel.loadSettings();

    return Consumer<SettingsViewmodel>(
      builder:
          (context, viewModel, child) => Scaffold(
            appBar: AppBar(title: Text('Settings')),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Enable Dark Mode", style: TextStyle(fontSize: 18)),
                  Switch(
                    value: !viewModel.settings.lightMode,
                    onChanged: (_) {
                      viewModel.toggleDarkMode();
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
