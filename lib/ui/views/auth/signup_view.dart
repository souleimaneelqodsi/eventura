// ignore_for_file: use_build_context_synchronously

import 'package:eventura/core/viewmodels/auth/signup_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';

class SignupView extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Consumer<SignupViewmodel>(
        builder: (context, vmodel, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          errorText:
                              vmodel.hasError
                                  ? (vmodel.errorMessage!
                                          .toLowerCase()
                                          .contains("email")
                                      ? vmodel.errorMessage
                                      : null)
                                  : null,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          errorText:
                              vmodel.hasError
                                  ? (vmodel.errorMessage!
                                          .toLowerCase()
                                          .contains("password")
                                      ? vmodel.errorMessage
                                      : null)
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 40),

                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed:
                      vmodel.isBusy
                          ? null
                          : () async {
                            var response = await vmodel.signUp(
                              context,
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                            );
                            if (vmodel.errorMessage == null && response == 1) {
                              await vmodel.authService.isFirstLogin(
                                    vmodel.authService.currentUser!.id,
                                  )
                                  ? Navigator.pushReplacementNamed(
                                    context,
                                    '/welcome',
                                  )
                                  : Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                            } else if (response == 0) {
                              var dialog =
                                  Platform.isIOS
                                      ? CupertinoAlertDialog(
                                        title: Text("Email confirmation"),
                                        content: Text(
                                          "Please confirm your email using the link we've sent you.",
                                        ),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: Text("OK"),
                                            onPressed:
                                                () =>
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      "/login",
                                                    ),
                                          ),
                                        ],
                                      )
                                      : AlertDialog(
                                        title: Text("Email confirmation"),
                                        content: Text(
                                          "Please confirm your email using the link we've sent you.",
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            child: Text("OK"),
                                            onPressed:
                                                () =>
                                                    Navigator.pushReplacementNamed(
                                                      context,
                                                      "/login",
                                                    ),
                                          ),
                                        ],
                                      );

                              Platform.isAndroid
                                  ? showDialog(
                                    context: context,
                                    builder: (_) => dialog,
                                    barrierDismissible: false,
                                  )
                                  : showCupertinoDialog(
                                    context: context,
                                    builder: (_) => dialog,
                                  );
                            }
                          },
                  child:
                      vmodel.isBusy
                          ? const CircularProgressIndicator()
                          : const Text(
                            "S'inscrire",
                            style: TextStyle(fontSize: 16),
                          ),
                ),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign In",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    "/login",
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
