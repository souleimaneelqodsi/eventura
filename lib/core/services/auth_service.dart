// ignore_for_file: unnecessary_null_comparison
import 'package:eventura/core/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class AuthService {
  late final GoTrueClient _supabaseAuth;
  late final SupabaseClient _supabaseClient;

  AuthService({required SupabaseClient supabaseClient}) {
    _supabaseClient = supabaseClient;
    _supabaseAuth = _supabaseClient.auth;
  }

  final logger = Logger();

  User? get currentUser => _supabaseAuth.currentUser;

  // CRUD operations: Create, Read, Update, Delete

  Future<UserModel?> createUser(UserModel user) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .insert(user.toJson())
              .select()
              .single();
      if (response == null) {
        throw Exception("User creation failed: no data returned");
      }
      return UserModel.fromJson(response);
    } catch (error) {
      logger.e("Error creating user", error: error);
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .select()
              .eq('user_id', userId)
              .single();
      return UserModel.fromJson(response);
    } catch (error) {
      logger.e("Error fetching user by ID", error: error);
      return null;
    }
  }

  Future<UserModel?> updateUser(UserModel user) async {
    try {
      final response =
          await _supabaseClient
              .from('users')
              .update(user.toJson())
              .eq('user_id', user.userId)
              .select()
              .single();
      if (response == null) {
        throw Exception(
          "User creation failed: user not found/data not returned",
        );
      }
      return UserModel.fromJson(response);
    } catch (error) {
      logger.e(
        "Une erreur s'est produite lors de la mise à jour de l'utilisateur",
        error: error,
      );
      return null;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .delete()
          .eq('user_id', userId);
      if (response == null) {
        throw Exception(
          "User deletion failed: user not found/data not returned",
        );
      }
    } catch (error) {
      logger.e(
        "Une erreur s'est produite lors de la mise à jour de l'utilisateur",
        error: error,
      );
    }
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _supabaseAuth.signUp(
        email: email,
        password: password,
      );
      if (response.user != null) {
        final newUser = UserModel(
          userId: response.user!.id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          firstLogin: true,
        );
        try {
          final existingUser =
              await _supabaseClient
                  .from('users')
                  .select('user_id')
                  .eq('email', email)
                  .maybeSingle();

          if (existingUser != null) {
            var e = Exception("Email already in use.");
            logger.e("Error: email already in use", error: e);
            throw e;
          }
          final user = await createUser(newUser);
          return user;
        } catch (error) {
          logger.e(
            "An error occurred while creating the user in the databse",
            error: error,
          );
          rethrow;
        }
      } else {
        throw Exception("Sign-up failed: Please try again or contact support.");
      }
    } on AuthException catch (error) {
      logger.e("Error during signup", error: error);
      throw Exception(error.message);
    } catch (error) {
      logger.e("Unexpected error during sign up", error: error);
      throw Exception("Failed to sign up: ${error.toString()}");
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      final response = await _supabaseAuth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.session == null || response.user == null) {
        throw Exception(
          "An error occurred while logging in. Please try again or contact support.",
        );
      }
    } on AuthException catch (error) {
      logger.e("Auth Error while logging in the user.", error: error);
      throw Exception(error.message);
    } catch (error) {
      logger.e("Unknown error during log in.", error: error);
      throw Exception("Failed to login: ${error.toString()}");
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseAuth.signOut();
    } catch (error) {
      rethrow;
    }
  }
}
