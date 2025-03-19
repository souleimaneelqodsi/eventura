import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:logger/logger.dart';

class ResetPasswordViewmodel extends BaseViewmodel {
  final AuthService _authService;

  final log = Logger();
  ResetPasswordViewmodel({required AuthService authService})
    : _authService = authService;

  Future<void> resetPassword(String email) async {
    setBusy(true);
    setError(null);
    try {
      await _authService.resetPassword(email);
    } catch (error) {
      setError(error.toString().replaceFirst("Exception: ", ''));
    } finally {
      setBusy(false);
    }
  }
}
