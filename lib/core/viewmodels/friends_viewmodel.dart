import 'package:eventura/core/models/friends.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/widgets.dart';

class FriendsViewmodel extends BaseViewmodel {
  FriendsViewmodel({required this.friendService});

  final FriendService friendService;

  Map<FriendshipModel, UserModel?> friends = {};
  Map<FriendshipModel, UserModel?> pendingRequests = {};

  Future<void> fetchFriendsAndRequests(
    String currentUserId,
    BuildContext context,
  ) async {
    try {
      setBusy(true);
      if (context.mounted) {
        friends = await friendService.getFriends(currentUserId, context);
      }
      if (context.mounted) {
        pendingRequests = await friendService.getPendingRequests(
          currentUserId,
          context,
        );
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      setBusy(true);
      await friendService.sendFriendRequest(fromUserId, toUserId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> acceptFriendRequest(int friendRequestId) async {
    try {
      setBusy(true);
      await friendService.acceptFriendRequest(friendRequestId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> rejectFriendRequest(int friendRequestId) async {
    try {
      setBusy(true);
      await friendService.rejectFriendRequest(friendRequestId);
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
