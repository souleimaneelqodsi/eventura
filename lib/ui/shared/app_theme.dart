import 'package:flutter/material.dart';

class AppTheme {
  final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue, 
    // TODO: add other properties
  );
  ThemeData get light => lightTheme;
}