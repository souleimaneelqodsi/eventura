import 'package:eventura/core/viewmodels/auth/signup_viewmodel.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          builder: (context, viewModel, _) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/icon/icon.png', height: 100),
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
                        errorMaxLines: 4,
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
                        errorMaxLines: 5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _firstNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _lastNameController,
                      keyboardType: TextInputType.name,
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
                                  if (!viewModel.hasError) {
                                    _emailController.clear();
                                    _passwordController.clear();
                                    _firstNameController.clear();
                                    _lastNameController.clear();
                                    // ignore: use_build_context_synchronously
                                    _showConfirmationDialog(context);
                                  }
                                },
                        child:
                            viewModel.isBusy
                                ? const CircularProgressIndicator()
                                : const Text('Sign Up'),
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
                          style: const TextStyle(color: AppColors.errorRed),
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
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
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
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    final dialog = AlertDialog(
      title: const Text("Email confirmation"),
      content: const Text(
        "Please confirm your email using the link we've sent you. You're going to be redirected to the sign in page.",
      ),
      actions: [
        ElevatedButton(
          child: const Text("OK"),
          onPressed: () => Navigator.pushReplacementNamed(context, "/login"),
        ),
      ],
    );
    // code à décommenter en cas d'exécution sur appareil mobile
    /*Platform.isAndroid
    ?
    showCupertinoDialog(context: context, builder: (_) => dialog) :*/
    showDialog(
      context: context,
      builder: (_) => dialog,
      barrierDismissible: false,
    );
  }
}
