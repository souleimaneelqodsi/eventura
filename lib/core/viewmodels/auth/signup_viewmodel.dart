import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class SignupViewmodel extends BaseViewModel {
  final AuthService authService;

  SignupViewmodel({required this.authService});

  Future<int> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      setBusy(true);
      setError(null);
      var response = await authService.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      if (response == null) {
        return 0;
      }
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ''));
    } finally {
      setBusy(false);
    }
    return 1;
  }
}
