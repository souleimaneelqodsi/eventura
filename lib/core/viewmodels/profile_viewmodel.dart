import 'package:eventura/core/models/user.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class ProfileViewmodel extends BaseViewmodel {
  /// ViewModel for managing user profile data.
  /// This class is responsible for loading user profile data
  /// and handling any errors that may occur during the process.
  final AuthService userService;
  final String? userId;

  UserModel? _user;
  UserModel? get user => _user;
  
  ProfileViewmodel({required this.userService, this.userId});

  Future<void> loadProfile() async {
    try {
      setBusy(true);

      String? targetUserId = userId;
      if (targetUserId == null || targetUserId.isEmpty) {
        final current = userService.currentUser;
        if (current == null) {
          throw Exception("No authenticated user found.");
        }
        targetUserId = current.id;
      }

      final fetchedUser = await userService.getUserById(targetUserId);
      if (fetchedUser == null) {
        throw Exception("User not found.");
      }
      _user = fetchedUser;
    } catch (e) {
      setError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setBusy(false);
    }
  }
}
