import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginViewmodel extends BaseViewmodel {
  final AuthService authService;

  Logger logger = Logger();

  LoginViewmodel({required this.authService});

  Future<void> signIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      setBusy(true);
      await authService.signIn(email, password);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, "/home");
        UserModel? user = await authService.getUserById(
          authService.currentUser!.id,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back, ${user?.firstName ?? 'Guest'} ${user?.lastName ?? ''}.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ''));
    } finally {
      setBusy(false);
    }
  }
}
