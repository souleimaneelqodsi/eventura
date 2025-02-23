import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
class AuthService extends ChangeNotifier {
  final GoTrueClient _supabaseClient;

  // Constructeur de AuthService
  AuthService({required SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient.auth;

  // Auth State Change Listener
  Stream<User?> get authStateChanges => _supabaseClient.onAuthStateChange.map((event) => event.session?.user);

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await _supabaseClient.signInWithPassword(email: email, password: password);
      if (response.session == null || response.user == null) {
        return 'Authentication failed';
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    try {
      final response = await _supabaseClient.signUp(email: email, password: password);
      if (response.session == null || response.user == null) {
        return 'Sign up failed hhh';
      }
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _supabaseClient.signOut();
    notifyListeners();
  }

  bool isLoggedIn() => _supabaseClient.currentSession != null;
  User? get currentUser => _supabaseClient.currentUser;
}