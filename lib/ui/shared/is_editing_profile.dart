import 'package:flutter/material.dart';

class ProfileEditingState extends ChangeNotifier {
  bool _isEditing = false;

  bool get isEditing => _isEditing;

  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }
}
