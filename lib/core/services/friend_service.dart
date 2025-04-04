import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  // ignore: unused_field
  final SupabaseClient _supabaseClient;

  FriendService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

 Future<void> sendFriendRequest(String receiverId) async {
  final currentUser = _supabaseClient.auth.currentUser;
  if (currentUser == null) throw Exception("Utilisateur non connecté.");

  await _supabaseClient.from('friend_requests').insert({
    'sender_id': currentUser.id,
    'receiver_id': receiverId,
    'status': 'pending',
  });
}
   
}
