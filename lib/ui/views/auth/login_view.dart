import 'package:eventura/core/viewmodels/auth/login_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Contrôleurs pour email et mot de passe
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Consumer<LoginViewModel>(
        builder: (context, viewModel, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (viewModel.isError) 
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                TextField(
                  controller: emailController, // Utilisation du contrôleur
                  onChanged: (email) {
                    // Mettre à jour l'email dans le ViewModel
                    viewModel.setEmail(email);
                  },
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: passwordController, // Utilisation du contrôleur
                  onChanged: (password) {
                    // Mettre à jour le mot de passe dans le ViewModel
                    viewModel.setPassword(password);
                  },
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    // Appelle la méthode login du ViewModel avec l'email et mot de passe
                    await viewModel.login(
                      emailController.text,
                      passwordController.text,
                    );
                  },
                  child: viewModel.isBusy
                      ? const CircularProgressIndicator()
                      : const Text('Login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}