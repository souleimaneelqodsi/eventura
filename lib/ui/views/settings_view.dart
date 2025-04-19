import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final viewModel = Provider.of<SettingsViewmodel>(context, listen: false);
    await viewModel.loadSettings();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewmodel>(
      builder:
          (context, viewModel, child) => Scaffold(
            appBar: AppBar(title: Text('Settings')),
            body:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Enable Dark Mode",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
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
