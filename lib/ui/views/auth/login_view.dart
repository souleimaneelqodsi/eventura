import 'package:eventura/core/viewmodels/auth/login_viewmodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign In')),
        body: Consumer<LoginViewmodel>(
          builder: (context, vmodel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
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
                                            : "")
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
                                    vmodel.hasError
                                        ? (vmodel.errorMessage!
                                                .toLowerCase()
                                                .contains("password")
                                            ? vmodel.errorMessage
                                            : "")
                                        : null,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/reset_password',
                                  );
                                },
                                child: const Text('Forgot your password?'),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed:
                                  vmodel.isBusy
                                      ? null
                                      : () async {
                                        await vmodel.signIn(
                                          context,
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                        );
                                      },
                              child:
                                  vmodel.isBusy
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                        'Sign In',
                                        style: TextStyle(fontSize: 16),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (vmodel.hasError &&
                        !vmodel.errorMessage!.toLowerCase().contains(
                          "password",
                        ) &&
                        !vmodel.errorMessage!.toLowerCase().contains("email"))
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Text(
                          vmodel.errorMessage ?? "An unknown error occurred",
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Sign Up",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                                recognizer:
                                    TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          "/signup",
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
