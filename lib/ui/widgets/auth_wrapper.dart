import 'package:eventura/ui/views/auth/signup_view.dart';
import 'package:eventura/ui/views/homepage_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    //Supabase.instance.client.auth.signOut();
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      return const HomepageView();
    } else {
      return SignupView();
    }
  }
}
