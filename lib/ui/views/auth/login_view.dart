import 'package:eventura/core/viewmodels/auth/login_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Consumer<LoginViewmodel>(
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
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          () => Navigator.pushNamed(context, '/reset_password'),
                      child: const Text('Forgot your password?'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed:
                          viewModel.isBusy
                              ? null
                              : () async {
                                await viewModel.signIn(
                                  context,
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                              },
                      child:
                          viewModel.isBusy
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Sign In',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                    ),
                  ),
                  if (viewModel.hasError &&
                      !viewModel.errorMessage!.toLowerCase().contains(
                        "password",
                      ) &&
                      !viewModel.errorMessage!.toLowerCase().contains("email"))
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Text(
                        viewModel.errorMessage ?? "An unknown error occurred",
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap =
                                      () => Navigator.pushReplacementNamed(
                                        context,
                                        "/signup",
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
}
