import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventura/ui/views/homepage_view.dart';
import 'package:eventura/ui/views/auth/login_view.dart';
import 'package:provider/provider.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = Supabase.instance.client;
  
    return StreamBuilder<User?>(
      stream: supabaseClient.auth.onAuthStateChange.map((event) => event.session?.user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          print("User is logged in: ${snapshot.data}");
          return HomepageView(); // User is logged in, navigate to homepage
        } else {
          print("User is not logged in");
          return LoginView(); // User is not logged in, navigate to login
        }
      },
    );
  }
}