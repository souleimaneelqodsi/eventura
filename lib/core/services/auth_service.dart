import 'package:eventura/core/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  late final GoTrueClient _supabaseAuth;
  late final SupabaseClient _supabaseClient;

  AuthService({required SupabaseClient supabaseClient}) {
    _supabaseClient = supabaseClient;
    _supabaseAuth = _supabaseClient.auth;
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('user_id', userId)
          .single();
      return UserModel.fromJson(response);
    } catch (error) {
      print("Error fetching user by ID: $error");
      return null;
    }
  }

  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      if (response == null) {
        throw Exception("User creation failed: no data returned");
      }
      return UserModel.fromJson(response);
    } catch (error) {
      print("Error creating user: $error");
      return null;
    }
  }

  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .update(user.toJson())
          .eq('user_id', user.userId)
          .select()
          .single();
      // ignore: unnecessary_null_comparison
      if (response == null) {
        throw Exception(
            "User creation failed: user not found/data not returned");
      }
      return UserModel.fromJson(response);
    } catch (error) {
      print(
          "Une erreur s'est produite lors de la mise à jour de l'utilisateur : $error");
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response =
          await _supabaseClient.from('users').delete().eq('user_id', userId);
      // ignore: unnecessary_null_comparison
      if (response == null) {
        throw Exception(
            "User deletion failed: user not found/data not returned");
      }
    } catch (error) {
      print(
          "Une erreur s'est produite lors de la mise à jour de l'utilisateur : $error");
    }
  }

  void signIn(String email, String password) {}

   Future<void> signUp(String email, String password, String username) async {
    try {
      // Étape 1 : Création du compte dans Supabase Auth
      final AuthResponse response = await _supabaseAuth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) throw Exception('Échec de l\'inscription');

      // Étape 2 : Ajout de l'utilisateur dans la table "users"
      await _supabaseAuth.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'username': username,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      
    } catch (e) {
      if (kDebugMode) print('Erreur AuthService : $e'); // Log en mode debug
      rethrow; // Relance l'erreur pour le ViewModel
      print('AuthService Error: $e');
      rethrow;
    }
  }
}