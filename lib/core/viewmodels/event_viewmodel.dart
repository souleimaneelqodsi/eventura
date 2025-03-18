import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:flutter/widgets.dart';

class EventViewmodel extends BaseViewmodel {
  final EventService _eventService;
  Event? _event;

  Event? get event => _event;

  EventViewmodel({required EventService eventService})
    : _eventService = eventService;

  Future<void> loadEvent(int eventId) async {
    setBusy(true);
    setError(null);
    try {
      _event = await _eventService.getEventById(eventId);
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
      }
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
}
