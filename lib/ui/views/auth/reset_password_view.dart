import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/auth/reset_password_viewmodel.dart';

class ResetPasswordView extends StatefulWidget {
  @override
  _ResetPasswordViewState createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  //implementation du widget
  
  Widget build(BuildContext context) {
    // Récupération de l'instance de ResetPasswordViewModel
    final resetPasswordViewModel = Provider.of<ResetPasswordViewModel>(context);
  
    return Scaffold(
      appBar: AppBar(
        title: Text("Réinitialisation du mot de passe"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Entrez votre e-mail pour réinitialiser votre mot de passe.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-mail",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            resetPasswordViewModel.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      if (email.isNotEmpty) {
                        await resetPasswordViewModel.resetPassword(email);
                        if (resetPasswordViewModel.errorMessage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("✅ E-mail de réinitialisation envoyé !")),
                          );
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(resetPasswordViewModel.errorMessage!)),
                          );
                        }
                      }
                    },
                    child: Text("Envoyer"),
                  ),
          ],
        ),
      ),
    );
  }
}
