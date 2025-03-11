//import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginViewmodel extends BaseViewModel {
  final AuthService authService;

  LoginViewmodel({required this.authService});

  Logger logger = Logger();

  Future<void> signIn(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    try {
      setBusy(true);
      await authService.signIn(email, password);
      /*var usr = await authService.getUserById(authService.currentUser!.id);
      logger.i("${usr!.firstLogin}");
      if (usr.firstLogin ?? true) {
        var usrJson = usr.toJson();
        usrJson["firstLogin"] = false;
        var newUser = UserModel.fromJson(usrJson);
        await authService.updateUser(newUser);
        if (context.mounted) {
          logger.t("welcome");
          Navigator.pushReplacementNamed(context, "/welcome");
          return;
        }
      }
      logger.t("home");*/
      if (context.mounted) Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ''));
    } finally {
      setBusy(false);
    }
  }
}
