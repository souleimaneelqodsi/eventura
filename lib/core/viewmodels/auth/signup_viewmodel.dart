import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class SignupViewmodel extends BaseViewModel {
  final AuthService authService;
  String? _errorMessage;

  SignupViewmodel({required this.authService});

  String? get errorMessage => _errorMessage;

  Future<void> signUp(String email, String password, String username) async {
    try {
      setBusy(true);
      _errorMessage = null;
      
      await authService.signUp(email, password, username);
      
    } catch (e) {
      _errorMessage = "Erreur d'inscription : ${e.toString()}";
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}