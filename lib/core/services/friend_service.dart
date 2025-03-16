import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _supabaseClient;

  FriendService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  // Envoie une demande d'ami
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await _supabaseClient
          .from('friends')
          .insert({
            'requestor_id': fromUserId,
            'receiver_id': toUserId,
            'status': 'pending',
          })
          .single();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String friendRequestId) async {
    try {
      await _supabaseClient
          .from('friends')
          .update({'status': 'accepted'})
          .eq('id', friendRequestId)
          .single();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectFriendRequest(String friendRequestId) async {
    try {
      await _supabaseClient
          .from('friends')
          .update({'status': 'rejected'})
          .eq('id', friendRequestId)
          .single();
    } catch (e) {
      rethrow;
    }
  }
  // byby
  Future<void> blockUser(String friendRequestId) async {
    try {
      await _supabaseClient
          .from('friends')
          .update({'status': 'blocked'})
          .eq('id', friendRequestId)
          .single();
    } catch (e) {
      rethrow;
    }
  }

  // Récupère la liste des amis
  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    try {
      final response = await _supabaseClient
          .from('friends')
          .select()
          .or('requestor_id.eq.$userId,receiver_id.eq.$userId')
          .eq('status', 'accepted');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Récupère les demandes en attente
  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    try {
      final response = await _supabaseClient
          .from('friends')
          .select()
          .eq('receiver_id', userId)
          .eq('status', 'pending');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }
}