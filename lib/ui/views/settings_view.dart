import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewmodel>(context);

    final isLight = viewModel.settings.lightMode;

    return Scaffold(
      appBar: AppBar(title: Text('Parametres')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isLight ? "Activer le mode sombre" : "Activer le mode clair",
              style: TextStyle(fontSize: 18),
            ),
            Switch(
              value: !isLight, 
              onChanged: (_) {
                viewModel.toggleDarkMode();
              },
            ),
          ],
        ),
      ),
    );
  }
}