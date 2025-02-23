import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eventura/core/viewmodels/signup_viewmodel.dart';

class SignupView extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<SignupViewmodel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 25),
            if (vm.errorMessage != null)
              Text(
                vm.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ElevatedButton(
              onPressed: vm.isBusy ? null : () async {
                await vm.signUp(
                  _emailController.text.trim(),
                  _passwordController.text,
                  _usernameController.text.trim(),
                );
                if (vm.errorMessage == null) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: vm.isBusy 
                  ? const CircularProgressIndicator()
                  : const Text('S\'inscrire', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}