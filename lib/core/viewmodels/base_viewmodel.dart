import 'package:flutter/material.dart';

class BaseViewmodel extends ChangeNotifier {
  bool _isBusy = false;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool get isBusy => _isBusy;

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }

  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
