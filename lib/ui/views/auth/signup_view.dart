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
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      errorText:
                          viewModel.hasError &&
                                  viewModel.errorMessage!
                                      .toLowerCase()
                                      .contains("email")
                              ? viewModel.errorMessage
                              : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      errorText:
                          viewModel.hasError &&
                                  viewModel.errorMessage!
                                      .toLowerCase()
                                      .contains("password")
                              ? viewModel.errorMessage
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
                  const SizedBox(height: 50),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          viewModel.isBusy
                              ? null
                              : () async {
                                await viewModel.signUp(
                                  context,
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  firstName: _firstNameController.text,
                                  lastName: _lastNameController.text,
                                );
                                if (!viewModel.hasError && context.mounted) {
                                  _showConfirmationDialog(context);
                                }
                              },
                      child:
                          viewModel.isBusy
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Sign Up',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                    ),
                  ),
                  if (viewModel.hasError &&
                      !viewModel.errorMessage!.toLowerCase().contains(
                        RegExp("password|email"),
                      ))
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Error: ${viewModel.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap =
                                      () => Navigator.pushReplacementNamed(
                                        context,
                                        "/login",
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final dialog =
        Platform.isIOS
            ? CupertinoAlertDialog(
              title: const Text("Email confirmation"),
              content: const Text(
                "Please confirm your email using the link we've sent you. You're going to be redirected to the sign in page.",
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, "/login"),
                ),
              ],
            )
            : AlertDialog(
              title: const Text("Email confirmation"),
              content: const Text(
                "Please confirm your email using the link we've sent you. You're going to be redirected to the sign in page.",
              ),
              actions: [
                ElevatedButton(
                  child: const Text("OK"),
                  onPressed:
                      () => Navigator.pushReplacementNamed(context, "/login"),
                ),
              ],
            );

    Platform.isAndroid
        ? showDialog(
          context: context,
          builder: (_) => dialog,
          barrierDismissible: false,
        )
        : showCupertinoDialog(context: context, builder: (_) => dialog);
  }
}
