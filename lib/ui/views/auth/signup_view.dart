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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: Consumer<SignupViewmodel>(
          builder: (context, vmodel, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.75,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              textCapitalization: TextCapitalization.none,
                              autocorrect: false,
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
                                            : "")
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
                            const SizedBox(height:50),
                            ElevatedButton(
                              onPressed:
                                  vmodel.isBusy
                                      ? null
                                      : () async {
                                        await vmodel.signUp(
                                          context,
                                          email: _emailController.text.trim(),
                                          password: _passwordController.text,
                                          firstName: _firstNameController.text,
                                          lastName: _lastNameController.text,
                                        );
                                        if (!vmodel.hasError) {
                                          var dialog =
                                              Platform.isIOS
                                                  ? CupertinoAlertDialog(
                                                    title: Text(
                                                      "Email confirmation",
                                                    ),
                                                    content: Text(
                                                      "Please confirm your email using the link we've sent you. You're going to be redirected to the sign in page.",
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
                                                    title: Text(
                                                      "Email confirmation",
                                                    ),
                                                    content: Text(
                                                      "Please confirm your email using the link we've sent you. You're going to be redirected to the sign in page.",
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
                                          if (context.mounted) {
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
                                        }
                                      },
                              child:
                                  vmodel.isBusy
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                        "Sign Up",
                                        style: TextStyle(fontSize: 16),
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (vmodel.hasError &&
                        !vmodel.errorMessage!.toLowerCase().contains(
                          RegExp("password|email"),
                        ))
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Text(
                          'Error: ${vmodel.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Text.rich(
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
