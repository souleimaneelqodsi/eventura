import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class EventsListViewModel extends BaseViewModel {
  final EventService _eventService;
  List<Event> _events = [];

  List<Event> get events => _events;

  EventsListViewModel({required EventService eventService})
      : _eventService = eventService;

  // Charger tous les événements
  Future<void> loadEvents() async {
    setBusy(true);
    try {
      _events = await _eventService.getAllEvents();
    } catch (e) {
      print("Erreur lors du chargement des événements: $e");
      _events = [];
    }
    setBusy(false);
    notifyListeners();
  }
}
