import 'package:flutter/material.dart';

class AppTheme {
  ThemeData get light => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
      );

  ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      );
}