import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'events_list_viewmodel.dart';

class EventViewmodel extends BaseViewmodel {
  final EventService _eventService;
  Event? _event;
  bool _isCurrentEventFavorited = false;

  bool? _isParticipating;
  bool? _isPublic;
  bool? _isOrganizer;

  EventViewmodel({required EventService eventService})
    : _eventService = eventService;

  Event? get event => _event;
  bool get isCurrentEventFavorited => _isCurrentEventFavorited;

  bool? get isParticipating => _isParticipating;
  bool? get isPublic => _isPublic;
  bool? get isOrganizer => _isOrganizer;

  Future<void> loadEvent(int eventId, BuildContext context) async {
    setBusy(true);
    setError(null);
    try {
      _event = await _eventService.getEventById(eventId);
      if (_event != null) {
        _isPublic = !_event!.isPrivate;

        _isParticipating = await Provider.of<EventService>(
          context,
          listen: false,
        ).isUserParticipating(_event!.eventId!);

        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        _isOrganizer =
            currentUserId != null && _event!.organizerId == currentUserId;
        if (_isOrganizer != null && _isOrganizer == true) {
          _isParticipating = true;
        }

        final eventListVM = Provider.of<EventListViewmodel>(
          context,
          listen: false,
        );
        _isCurrentEventFavorited = eventListVM.isEventFavorited(eventId);
      } else {
        _isPublic = null;
        _isParticipating = null;
        _isOrganizer = null;
        _isCurrentEventFavorited = false;
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> toggleDetailFavoriteStatus(BuildContext context) async {
    if (_event == null || _event!.eventId == null) return;

    final originalState = _isCurrentEventFavorited;
    _isCurrentEventFavorited = !_isCurrentEventFavorited;
    notifyListeners();

    try {
      final newState = await _eventService.toggleFavorite(_event!.eventId!);
      if (newState != _isCurrentEventFavorited) {
        _isCurrentEventFavorited = newState;
      }

      Provider.of<EventListViewmodel>(
        context,
        listen: false,
      ).updateFavoritedStateFromDetail(
        _event!.eventId!,
        _isCurrentEventFavorited,
      );

      notifyListeners();
    } catch (e) {
      _isCurrentEventFavorited = originalState;
      setError(e.toString());
      notifyListeners();
    }
  }

  Future<void> createEvent(BuildContext context, Event event) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.createEvent(event);
      if (context.mounted) Navigator.pop(context);
      _event = null;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteEvent(BuildContext context, int eventId) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.deleteEvent(eventId);

      Provider.of<EventListViewmodel>(
        context,
        listen: false,
      ).removeEventIfFavorited(eventId);

      _event = null;
      _isParticipating = null;
      _isPublic = null;
      _isOrganizer = null;
      _isCurrentEventFavorited = false;
      if (context.mounted) {
        Navigator.pop(context);
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> updateEvent(Event updatedEvent) async {
    setBusy(true);
    setError(null);
    try {
      final newEvent = await _eventService.updateEvent(updatedEvent);
      if (newEvent != null) {
        _event = newEvent;
        _isPublic = !newEvent.isPrivate;
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        _isOrganizer =
            currentUserId != null && _event!.organizerId == currentUserId;
      }
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
    setError(null);
    try {
      print(
        'EventViewModel: _eventService.joinPublicEvent non implémenté ou à revoir',
      );
      _isParticipating = true;

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
    setError(null);
    try {
      print(
        'EventViewModel: _eventService.leaveEvent non implémenté ou à revoir',
      );
      _isParticipating = false;

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
    setError(null);
    try {
      print(
        'EventViewModel: _eventService.addFriendToEvent non implémenté ou à revoir',
      );

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
