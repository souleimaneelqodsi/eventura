import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class FriendsViewmodel extends BaseViewmodel {
  FriendsViewmodel({required this.friendService});

  final FriendService friendService;
}