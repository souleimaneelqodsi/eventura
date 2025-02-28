import 'package:supabase_flutter/supabase_flutter.dart' as supabase; 
import 'package:eventura/core/models/user.dart'; 

class UserService {
  final supabase.SupabaseClient _supabaseClient;

  UserService({required supabase.SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  // 🔹 Fetch the current user's profile
  Future<User?> getCurrentUser() async {
    final supabase.User? authUser = _supabaseClient.auth.currentUser;
    if (authUser == null) {
      print("⚠️ No authenticated user found.");
      return null;
    }

    return await getUserById(authUser.id);
  }

  // 🔹 Fetch another user's profile by ID
  Future<User?> getUserById(String userId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response == null) {
        print("⚠️ No user found for ID: $userId");
        return null;
      }

      return User.fromJson(response);
    } catch (error) {
      print("❌ Error fetching user with ID: $userId. Error: $error");
      return null; // Prevents app crash
    }
  }
}

