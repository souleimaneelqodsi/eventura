import 'package:flutter/material.dart';

class AppColors {
  // Primary Accent (Purple used for main actions, switches)
  static const Color primaryPurple = Color(0xFF673AB7); // Deep Purple 500
  static const Color primaryPurpleLight = Color(0xFFD1C4E9); // Deep Purple 100
  static const Color primaryPurpleDark = Color(0xFF311B92); // Deep Purple 900

  // Error / Destructive (Red used for errors, delete/refuse)
  static const Color errorRed = Color(0xFFD32F2F); // Red 700
  static const Color errorRedShade300 = Color(0xFFE57373);
  static const Color onErrorRed = Colors.white;

  // Warning (Orange for email verification)
  static const Color warningOrange = Color(0xFFFFA000); // Amber 700
  static const Color onWarningOrange = Colors.black;

  // Success (Green for accept friend request)
  static const Color successGreen = Color(0xFF388E3C); // Green 700
  static const Color onSuccessGreen = Colors.white;

  // Secondary Action / Subtle (Grey for sign out, some text)
  static const Color secondaryGrey = Color(0xFF757575); // Grey 600
  static const Color onSecondaryGrey = Colors.white;

  // Link Color (DeepPurple used for clickable text spans)
  static const Color linkPurple = primaryPurple;
}
