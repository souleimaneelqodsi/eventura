import 'package:eventura/core/models/friends.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart' show AuthService;
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendService {
  final SupabaseClient _supabaseClient;
  final log = Logger();

  FriendService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<FriendshipModel> acceptFriendRequest(int friendRequestId) async {
    try {
      var response = await _supabaseClient
          .from('friends')
          .select()
          .eq('friendship_id', friendRequestId);

      if (response.isEmpty) {
        throw Exception("Error accepting the friendship: friendship not found");
      }
      if (response.first['status'] != 'pending') {
        throw Exception(
          "Error accepting the friendship: friendship already accepted/rejected",
        );
      }

      var friendship = FriendshipModel.fromJson(response.first);

      await _supabaseClient
          .from('friends')
          .update({'status': 'accepted'})
          .eq('friendship_id', friendRequestId);

      friendship.status = 'accepted';
      return friendship;
    } catch (e) {
      log.e(e.toString(), error: e);
      rethrow;
    }
  }

  Future<Map<FriendshipModel, UserModel?>> getFriends(
    String userId,
    BuildContext context,
  ) async {
    try {
      Map<FriendshipModel, UserModel?> friends = {};
      final response = await _supabaseClient
          .from('friends')
          .select()
          .or('user_id_1.eq.$userId,user_id_2.eq.$userId')
          .eq('status', 'accepted');
      for (Map<String, dynamic> line in response) {
        FriendshipModel friendship = FriendshipModel.fromJson(line);
        if (context.mounted) {
          UserModel? friend = await Provider.of<AuthService>(
            context,
            listen: false,
          ).getUserById(
            friendship.userId1 == userId
                ? friendship.userId2
                : friendship.userId1,
          );
          friends[friendship] = friend;
        }
      }
      return friends;
    } catch (e) {
      log.e(e.toString(), error: e);
      rethrow;
    }
  }

  Future<Map<FriendshipModel, UserModel?>> getPendingRequests(
    String userId,
    BuildContext context,
  ) async {
    try {
      Map<FriendshipModel, UserModel?> pendingRequests = {};
      final response = await _supabaseClient
          .from('friends')
          .select()
          .eq('user_id_2', userId)
          .eq('status', 'pending');
      for (Map<String, dynamic> line in response) {
        FriendshipModel pendingRequest = FriendshipModel.fromJson(line);
        if (context.mounted) {
          UserModel? user = await Provider.of<AuthService>(
            context,
            listen: false,
          ).getUserById(pendingRequest.userId1);
          pendingRequests[pendingRequest] = user;
        }
      }
      return pendingRequests;
    } catch (e) {
      log.e(e.toString(), error: e);
      rethrow;
    }
  }

  Future<FriendshipModel> rejectFriendRequest(int friendRequestId) async {
    try {
      var response = await _supabaseClient
          .from('friends')
          .select()
          .eq('friendship_id', friendRequestId);

      if (response.isEmpty) {
        throw Exception("Error accepting the friendship: friendship not found");
      }
      if (response.first['status'] != 'pending') {
        throw Exception(
          "Error accepting the friendship: friendship already accepted/rejected",
        );
      }
      await _supabaseClient
          .from('friends')
          .update({'status': 'rejected'})
          .eq('friendship_id', friendRequestId);

      return FriendshipModel.fromJson(response.first);
    } catch (e) {
      log.e(e.toString(), error: e);
      rethrow;
    }
  }

  Future<FriendshipModel?> sendFriendRequest(
    String fromUserId,
    String toUserId,
  ) async {
    try {
      final response =
          await _supabaseClient.from('friends').insert({
            'user_id_1': fromUserId,
            'user_id_2': toUserId,
            'status': 'pending',
          }).select();

      return FriendshipModel.fromJson(response.first);
    } catch (e) {
      log.e("Error sending friend request: ${e.toString()}", error: e);
      rethrow;
    }
  }

  Future<void> deleteFriend(FriendshipModel friendship) async {
    try {
      await _supabaseClient
          .from('friends')
          .delete()
          .eq('friendship_id', friendship.friendshipId);
    } catch (e) {
      log.e("Error deleting friend: ${e.toString()}", error: e);
      rethrow;
    }
  }
}
