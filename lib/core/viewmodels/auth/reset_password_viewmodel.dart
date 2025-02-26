import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';

class ResetPasswordViewModel extends BaseViewModel {
  final AuthService _authService;

  // Constructeur
  ResetPasswordViewModel({required AuthService authService}) : _authService = authService;

  // Méthode pour réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    // Active le mode "chargement"
    setBusy(true);
    setError(null); // Réinitialise les erreurs

    try {
      // Appel de la méthode resetPassword() du service d'authentification
      await _authService.resetPassword(email);
      print("Réinitialisation du mot de passe demandée avec succès.");
    } catch (error) {
      setError("Une erreur s'est produite lors de la réinitialisation du mot de passe.");
      print(error);
    } finally {
      setBusy(false); // Désactive le mode "chargement"
    }
  }
}
