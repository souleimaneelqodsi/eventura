import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventViewmodel extends BaseViewmodel {
  final EventService _eventService;
  Event? _event;
  bool? _isParticipating;
  bool? _isPublic;
  bool? _isOrganizer;

  EventViewmodel({required EventService eventService})
    : _eventService = eventService;

  Event? get event => _event;
  bool? get isParticipating => _isParticipating;
  bool? get isPublic => _isPublic;
  bool? get isOrganizer => _isOrganizer;

  Future<void> loadEvent(int eventId) async {
    setBusy(true);
    setError(null);
    try {
      _event = await _eventService.getEventById(eventId);
      if (_event != null) {
        _isPublic = !_event!.isPrivate;
        _isParticipating = await _eventService.isUserParticipating(eventId);

        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        _isOrganizer =
            currentUserId != null && _event!.organizerId == currentUserId;
      } else {
        _isPublic = null;
        _isParticipating = null;
        _isOrganizer = null;
      }

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
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
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteEvent(BuildContext context, int eventId) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.deleteEvent(eventId);
      _event = null;
      _isParticipating = null;
      _isPublic = null;
      _isOrganizer = null;
      if (context.mounted) {
        Navigator.pop(context);
      }
      notifyListeners();
    } catch (e) {
      setError(e.toString());
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
    } finally {
      setBusy(false);
    }
  }

  Future<void> joinPublicEvent(int eventId) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.joinPublicEvent(eventId);
      _isParticipating = true;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> leaveEvent(int eventId) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.leaveEvent(eventId);
      _isParticipating = false;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> addFriendToEvent(String friendId, int eventId) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.addFriendToEvent(eventId, friendId);

      notifyListeners();
    } catch (e) {
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }
}
