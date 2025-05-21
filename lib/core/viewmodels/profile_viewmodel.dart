import 'dart:io';
import 'package:eventura/core/models/friends.dart';
import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class ProfileViewmodel extends BaseViewmodel {
  final AuthService userService;
  final String userId;
  UserModel? _user;
  bool? hasVerifiedEmail;
  ProfileViewmodel({required this.userService, required this.userId});

  UserModel? get currentUser {
    logger.d(_user == null ? "User is null" : _user!.firstName);
    return _user;
  }

  bool get isCurrentUserProfile {
    return userId == userService.currentUser!.id;
  }

  Logger logger = Logger(printer: PrettyPrinter());
  UserModel? get user => _user;

  Future<void> loadProfile() async {
    try {
      setBusy(true);
      if (userId.isEmpty) throw Exception("User ID is empty.");
      if (userService.currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final fetchedUser = await userService.getUserById(userId);
      _user = fetchedUser;
      hasVerifiedEmail = userService.hasVerifiedEmail();
      notifyListeners();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> changeProfilePicture(File imageFile) async {
    if (!isCurrentUserProfile || _user == null) {
      setError(
        "Cannot change profile picture for another user or if user is not loaded.",
      );
      return;
    }
    setBusy(true);
    setError(null);
    try {
      final imageUrl = await userService.uploadProfilePicture(
        imageFile,
        _user!.userId,
      );

      if (imageUrl != null) {
        final updatedUser = await userService.updateUserProfilePictureUrl(
          _user!.userId,
          imageUrl,
        );
        if (updatedUser != null) {
          _user = updatedUser;
        } else {
          _user = _user?.copyWith(profilePicture: imageUrl);
          logger.w(
            "User record update with new profile picture URL failed, but image was uploaded.",
          );
        }
      } else {
        throw Exception("Profile picture upload failed.");
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
      logger.e("Error changing profile picture: $e");
    } finally {
      setBusy(false);
    }
  }

  Future<void> addFriend(BuildContext context) async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception("Cannot add yourself as a friend.");
      }
      final friendService = Provider.of<FriendService>(context, listen: false);
      await friendService.sendFriendRequest(userId);
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteFriend(BuildContext context) async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception(
          "You cannot be friends with yourself, so you cannot delete a friendship between you and yourself.",
        );
      }
      final friendService = Provider.of<FriendService>(context, listen: false);
      final FriendshipModel toDelete = await friendService.getFriendshipByIds(
        userService.currentUser!.id,
        userId,
      );
      await friendService.deleteFriend(toDelete);
      notifyListeners();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> acceptFriendRequest(BuildContext context) async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception(
          "You cannot have added yourself as a friend, so you cannot accept a friend request of yourself.",
        );
      }
      final friendService = Provider.of<FriendService>(context, listen: false);
      final FriendshipModel toAccept = await friendService.getFriendshipByIds(
        userService.currentUser!.id,
        userId,
      );
      int idToAccept = toAccept.friendshipId;
      friendService.acceptFriendRequest(idToAccept);
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> rejectFriendRequest(BuildContext context) async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception(
          "You cannot have added yourself as a friend, so you cannot accept a friend request of yourself.",
        );
      }
      final friendService = Provider.of<FriendService>(context, listen: false);
      final FriendshipModel toReject = await friendService.getFriendshipByIds(
        userService.currentUser!.id,
        userId,
      );
      int idToReject = toReject.friendshipId;
      friendService.rejectFriendRequest(idToReject);
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> cancelFriendRequest(BuildContext context) async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception(
          "You cannot have sent yourself a friend request, so you cannot cancel a friend request to yourself.",
        );
      }
      final friendService = Provider.of<FriendService>(context, listen: false);
      friendService.cancelFriendRequest(userId);
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      setBusy(true);

      if (!isCurrentUserProfile) {
        throw Exception("Cannot update another user's profile.");
      }

      await userService.updateUser(user, false);
      _user = user;
      notifyListeners();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      setBusy(true);
      if (isCurrentUserProfile) {
        throw Exception("Cannot resend verification email for another user.");
      }
      await userService.resendVerificationEmail();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> resetPassword() async {
    try {
      setBusy(true);
      if (!isCurrentUserProfile) {
        throw Exception("Cannot reset password for another user.");
      }
      await userService.resetPassword(user!.email);
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }

  Future<void> signOut() async {
    try {
      setBusy(true);
      await userService.signOut();
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }
}
