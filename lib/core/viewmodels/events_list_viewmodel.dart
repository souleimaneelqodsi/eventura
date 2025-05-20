import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/ui/static/event_list_type.dart';

class EventListViewmodel extends BaseViewmodel {
  final EventService _eventService;
  List<Event> _events = [];
  EventListType _eventListType = EventListType.myEvents;

  Set<int> _favoritedEventIds = {};

  EventListViewmodel({required EventService eventService})
    : _eventService = eventService {
    _fetchInitialFavoritedEventIds();
  }

  List<Event> get events => _events;
  EventListType get eventListType => _eventListType;

  set setEventsType(EventListType value) {
    if (_eventListType != value) {
      _eventListType = value;
    }
  }

  bool isEventFavorited(int eventId) {
    return _favoritedEventIds.contains(eventId);
  }

  Future<void> _fetchInitialFavoritedEventIds() async {
    try {
      final List<Event> favoriteEventsList =
          await _eventService.getFavoriteEvents();
      _favoritedEventIds = favoriteEventsList.map((e) => e.eventId!).toSet();
      notifyListeners();
    } catch (e) {
      print("Error fetching initial favorited event IDs: $e");
    }
  }

  Future<void> loadEvents() async {
    if (_favoritedEventIds.isEmpty &&
        _eventListType != EventListType.favorites) {
      await _fetchInitialFavoritedEventIds();
    }

    setBusy(true);
    setError(null);
    try {
      switch (_eventListType) {
        case EventListType.myEvents:
          await _loadMyEvents();
          break;
        case EventListType.events:
          await _loadPublicEvents();
          break;
        case EventListType.favorites:
          await _loadFavoriteEvents();
          break;
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadMyEvents() async {
    _events = await _eventService.getUserEvents();
    notifyListeners();
  }

  Future<void> _loadPublicEvents() async {
    _events = await _eventService.getPublicEvents();
    notifyListeners();
  }

  Future<void> _loadFavoriteEvents() async {
    _events = await _eventService.getFavoriteEvents();

    _favoritedEventIds = _events.map((e) => e.eventId!).toSet();
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(int eventId) async {
    final originalFavoritedState = _favoritedEventIds.contains(eventId);

    if (originalFavoritedState) {
      _favoritedEventIds.remove(eventId);
    } else {
      _favoritedEventIds.add(eventId);
    }

    if (_eventListType == EventListType.favorites) {
      if (originalFavoritedState) {
        _events.removeWhere((event) => event.eventId == eventId);
      } else {}
    }
    notifyListeners();

    try {
      final isNowFavorited = await _eventService.toggleFavorite(eventId);

      if (isNowFavorited != _favoritedEventIds.contains(eventId)) {
        if (isNowFavorited) {
          _favoritedEventIds.add(eventId);
        } else {
          _favoritedEventIds.remove(eventId);
        }

        if (_eventListType == EventListType.favorites) {
          await _loadFavoriteEvents();
        } else {
          notifyListeners();
        }
      }
    } catch (e) {
      if (originalFavoritedState) {
        _favoritedEventIds.add(eventId);
      } else {
        _favoritedEventIds.remove(eventId);
      }

      if (_eventListType == EventListType.favorites &&
          originalFavoritedState &&
          !_favoritedEventIds.contains(eventId)) {
        await _loadFavoriteEvents();
      } else {
        notifyListeners();
      }
      setError(e.toString());
    }
  }

  Future<void> addFriendToEvent(String friendId, int eventId) async {
    setBusy(true);
    try {
      print(
        'ViewModel: addFriendToEvent - Service call to be implemented/verified',
      );
      await loadEvents();
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
      print(
        'ViewModel: joinPublicEvent - Service call to be implemented/verified',
      );
      await loadEvents();
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
      print('ViewModel: leaveEvent - Service call to be implemented/verified');
      _events.removeWhere((event) => event.eventId == eventId);
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  void updateFavoritedStateFromDetail(int eventId, bool isFavorited) {
    if (isFavorited) {
      _favoritedEventIds.add(eventId);
    } else {
      _favoritedEventIds.remove(eventId);
      if (_eventListType == EventListType.favorites) {
        _events.removeWhere((event) => event.eventId == eventId);
      }
    }
    notifyListeners();
  }

  void removeEventIfFavorited(int eventId) {
    if (_favoritedEventIds.contains(eventId)) {
      _favoritedEventIds.remove(eventId);
      if (_eventListType == EventListType.favorites) {
        _events.removeWhere((event) => event.eventId == eventId);
      }
      notifyListeners();
    }
  }
}
