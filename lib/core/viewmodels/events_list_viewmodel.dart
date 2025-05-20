import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/ui/static/event_list_type.dart';

class EventListViewmodel extends BaseViewmodel {
  final EventService _eventService;
  List<Event> _events = [];

  EventListType _eventListType = EventListType.myEvents;

  EventListViewmodel({required EventService eventService})
    : _eventService = eventService;

  List<Event> get events => _events;
  set setEventsType(EventListType value) => _eventListType = value;

  Future<void> loadEvents() async {
    switch (_eventListType) {
      case EventListType.myEvents:
        await _loadMyEvents();
        break;
      case EventListType.events:
        await _loadPublicEvents();
        break;
    }
  }

  Future<void> _loadMyEvents() async {
    setBusy(true);
    try {
      _events = await _eventService.getUserEvents();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadPublicEvents() async {
    setBusy(true);
    try {
      _events = await _eventService.getPublicEvents();
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> addFriendToEvent(String friendId, int eventId) async {
    setBusy(true);
    try {
      await _eventService.addFriendToEvent(eventId, friendId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> joinPublicEvent(int eventId) async {
    setBusy(true);
    try {
      await _eventService.joinPublicEvent(eventId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> leaveEvent(int eventId) async {
    setBusy(true);
    try {
      await _eventService.leaveEvent(eventId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
