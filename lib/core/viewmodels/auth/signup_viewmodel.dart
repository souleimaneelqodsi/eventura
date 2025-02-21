import 'package:eventura/core/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class SignupViewmodel extends BaseViewModel {
  SignupViewmodel({required this.authService});

  final AuthService authService;

  Future<void> signUp(String email, String password) async {
    try {
      setBusy(true);
      await authService.signUp(email, password);
    } catch (e) {
      // Handle signup error
      setError(true as String?);
      setErrorMessage(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }
  
  void setErrorMessage(String string) {}
}