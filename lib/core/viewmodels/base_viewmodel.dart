import 'package:flutter/material.dart';

class BaseViewModel extends ChangeNotifier {
  bool _busy = false;
  bool _error = false;
  String _errorMessage = '';

  void setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message!;
    notifyListeners();
  }

  bool get hasError => _errorMessage != null;

  @override
  // ignore: unnecessary_overrides
  void dispose() {
    super.dispose();
  }
}
