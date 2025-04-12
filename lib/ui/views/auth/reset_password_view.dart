import 'package:eventura/core/viewmodels/auth/reset_password_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  ResetPasswordViewState createState() => ResetPasswordViewState();
}

class ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Reset"), centerTitle: true),
      body: Consumer<ResetPasswordViewmodel>(
        builder: (context, vmodel, _) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter your email to reset your password.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    errorText: vmodel.hasError ? '' : null,
                  ),
                ),
                SizedBox(height: 20),
                if (vmodel.hasError)
                  Text(
                    vmodel.errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                SizedBox(height: 35),
                vmodel.isBusy
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          await vmodel.resetPassword(email);
                          if (!vmodel.hasError) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Reset email sent!")),
                              );
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          }
                        }
                      },
                      child: Text("Send"),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}
