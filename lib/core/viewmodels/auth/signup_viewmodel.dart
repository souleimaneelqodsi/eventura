import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/widgets.dart';

class SignupViewmodel extends BaseViewmodel {
  final AuthService authService;

  SignupViewmodel({required this.authService});

  Future<void> signUp(
    BuildContext context, {
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      setBusy(true);
      await authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ''));
    } finally {
      setBusy(false);
    }
  }
}
