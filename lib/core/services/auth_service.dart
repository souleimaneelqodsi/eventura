import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  late final GoTrueClient _supabaseClient;

  AuthService({required SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient.auth;

  signIn(String email, String password) {}

  signUp(String email, String password) {}
  
   // Implémentation de la méthode resetPassword()
   // Cette méthode permet de réinitialiser le mot de passe d'un utilisateur

  Future<void> resetPassword(String email) async {
    try {
      // Appel de la méthode resetPasswordForEmail() du client GoTrue
      await _supabaseClient.resetPasswordForEmail(email);
      print("E-mail de réinitialisation du mot de passe envoyé avec succès.");
    } catch (error) {
      print("Erreur lors de la réinitialisation du mot de passe : $error");
      throw error;
    }
  
  }
}