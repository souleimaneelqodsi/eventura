import 'package:flutter/foundation.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/friend_service.dart';

class FriendsViewmodel extends BaseViewmodel {
  FriendsViewmodel({required this.friendService});

  final FriendService friendService;

  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> pendingRequests = [];

  Future<void> fetchFriendsAndRequests(String currentUserId) async {
    try {
      setBusy(true);
      friends = await friendService.getFriends(currentUserId);// Récupère les amis
      pendingRequests = await friendService.getPendingRequests(currentUserId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  // Envoie une demande d'ami (méthode similaire pour accept/reject/block)
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      setBusy(true);
      await friendService.sendFriendRequest(fromUserId, toUserId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> acceptFriendRequest(String friendRequestId) async {
    try {
      setBusy(true);
      await friendService.acceptFriendRequest(friendRequestId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> rejectFriendRequest(String friendRequestId) async {
    try {
      setBusy(true);
      await friendService.rejectFriendRequest(friendRequestId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }

  Future<void> blockUser(String friendRequestId) async {
    try {
      setBusy(true);
      await friendService.blockUser(friendRequestId);
    } catch (e) {
      setError(e.toString());
      rethrow;
    } finally {
      setBusy(false);
    }
  }
}
