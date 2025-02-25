import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';

class EventDetailViewModel extends BaseViewModel {
  final EventService _eventService;
  Event? _event;

  Event? get event => _event;

  EventDetailViewModel({required EventService eventService})
      : _eventService = eventService;

  // 1️⃣ Charger un événement par son ID
  Future<void> loadEvent(int eventId) async {
    setBusy(true);
    _event = await _eventService.getEventById(eventId);
    setBusy(false);
    notifyListeners();
  }

  // 2️⃣ Mettre à jour un événement
  Future<void> updateEvent(Event updatedEvent) async {
    setBusy(true);
    await _eventService.updateEvent(updatedEvent);
    _event = updatedEvent;
    setBusy(false);
    notifyListeners();
  }

  // 3️⃣ Supprimer un événement
  Future<void> deleteEvent() async {
    if (_event == null) return;
    setBusy(true);
    await _eventService.deleteEvent(_event!.eventId!);
    _event = null;
    setBusy(false);
    notifyListeners();
  }
}
