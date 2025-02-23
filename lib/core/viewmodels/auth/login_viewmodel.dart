import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/services/auth_service.dart';

class LoginViewModel extends BaseViewModel {
  final AuthService authService;

  // Constructeur avec injection de dépendance
  LoginViewModel({required this.authService});

  // Variables privées pour stocker l'email et le mot de passe
  String _email = '';
  String _password = '';
  bool _isBusy = false; // Variable privée pour l'état de "chargement"

  // Getter pour accéder à l'état de "chargement"
  bool get isBusy => _isBusy;

  // Getter pour accéder à l'email et au mot de passe
  String get email => _email;
  String get password => _password;

  // Setter pour changer l'état de "chargement"
  @override
  void setBusy(bool value) {
    _isBusy = value;
    notifyListeners(); // Notifie les widgets quand l'état change
  }

  // Méthode pour se connecter
  Future<void> login(String email, String password) async {
    try {
      setBusy(true); // Indique que la connexion est en cours
      await authService.signIn(_email, _password); // Tentative de connexion via AuthService
    } catch (e) {
      setError(e.toString()); // Si erreur, mettre l'état d'erreur à true
      setErrorMessage(e.toString()); // Mettre un message d'erreur
    } finally {
      setBusy(false); // La tâche est terminée, qu'elle ait échoué ou réussi
    }
  }

  // Setters pour mettre à jour les valeurs d'email et de mot de passe
  void setEmail(String email) {
    _email = email;
    notifyListeners(); // Notifie les widgets d'un changement
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners(); // Notifie les widgets d'un changement
  }

  // Setters pour gérer les erreurs et les messages d'erreur
  @override
  void setError(String? error) {
    _isError = error != null;
    notifyListeners();
  }

  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Variables privées pour gérer l'état de l'erreur et le message
  bool _isError = false;
  String _errorMessage = '';

  // Getters pour exposer l'état dans la vue
  bool get isError => _isError;
  String get errorMessage => _errorMessage;
}