import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';

class LoginViewmodel extends BaseViewModel {
  final AuthService authService;

  LoginViewmodel({required this.authService});

  Future<void> login(String email, String password) async {
    try {
      setBusy(true);
      await authService.signIn(email, password);
    } catch (e) {
      setError(true as String?);
      setErrorMessage(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }
  
  void setErrorMessage(String string) {}
}
