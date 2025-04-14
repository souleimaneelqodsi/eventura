import 'package:flutter/material.dart';
import 'package:eventura/ui/static/coming_soon.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ComingSoon(title: 'Settings');
  }
}
