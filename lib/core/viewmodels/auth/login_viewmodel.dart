import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';

class LoginViewmodel extends BaseViewModel {
  final AuthService authService;

  LoginViewmodel({required this.authService});
}