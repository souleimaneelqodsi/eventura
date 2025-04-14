import 'package:flutter/material.dart';

class ComingSoon extends StatelessWidget {
  final String title;
  const ComingSoon({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Coming soon! ⏳', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
