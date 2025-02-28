import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/user_service.dart';
import 'package:eventura/core/models/user.dart';

class ProfileViewModel extends BaseViewModel {
  final UserService _userService;
  User? _user;
  String? _userId;

  ProfileViewModel({required UserService userService, String? userId})
      : _userService = userService,
        _userId = userId;

  User? get user => _user;

  Future<void> loadProfile() async {
    setBusy(true);
    setError(null);

    try {
      if (_userId == null || _userId!.isEmpty) {
        _user = await _userService.getCurrentUser();
      } else {
        _user = await _userService.getUserById(_userId!);
      }

      if (_user == null) {
        setError("⚠️ Profil introuvable.");
      }

      notifyListeners();
    } catch (error) {
      setError("❌ Erreur lors du chargement du profil.");
      print(error);
    } finally {
      setBusy(false);
    }
  }
}
