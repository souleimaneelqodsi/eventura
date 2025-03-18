import 'package:flutter/material.dart';

class BaseViewmodel extends ChangeNotifier {
  bool _isBusy = false;
  bool get isBusy => _isBusy;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  bool get hasError => _errorMessage != null;

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}