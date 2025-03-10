import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/ui/views/auth/signup_view.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  final AuthService authService;

  const AuthWrapper({super.key, required this.authService});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  Widget build(BuildContext context) {
    if (widget.authService.currentUser != null) {
      return FutureBuilder<UserModel?>(
        future: widget.authService.getUserById(
          widget.authService.currentUser!.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            bool firstLogin = snapshot.data!.firstLogin ?? false; 
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, firstLogin ? '/welcome' : '/home');
            });
            return const SizedBox.shrink(); 
          } else {
            return Container(); 
          }
        },
      );
    }
    return SignupView();
  }
}
