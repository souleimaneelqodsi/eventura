import 'package:flutter/foundation.dart';
import 'package:eventura/core/services/auth_service.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;
  // Constructeur
  ResetPasswordViewModel({required AuthService authService}) :
   _authService = authService;
  //
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Méthode pour réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    // On met isLoading à true pour afficher le spinner de chargement
    _isLoading = true;
    // On réinitialise le message d'erreur
    _errorMessage = null;
    // On notifie les écouteurs du changement
    notifyListeners();

    try {
      // Appel de la méthode resetPassword() du service d'authentification
      await _authService.resetPassword(email);
      print("Réinitialisation du mot de passe demandée avec succès.");
    } catch (error) {
      _errorMessage = "Une erreur s'est produite lors de la réinitialisation du mot de passe.";
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
