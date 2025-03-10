import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _supabaseClient;

  FriendService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;
}
