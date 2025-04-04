import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class FriendsViewmodel extends BaseViewmodel {
  FriendsViewmodel({required this.friendService});

  final FriendService friendService;

  Future<void> sendFriendRequest(String receiverId) async {
  try {
    setBusy(true);
    await friendService.sendFriendRequest(receiverId);
  } catch (e) {
    setError(e.toString());
  } finally {
    setBusy(false);
  }
}

}