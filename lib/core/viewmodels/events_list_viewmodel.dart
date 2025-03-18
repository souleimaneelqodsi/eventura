// events_list_viewmodel.dart
import 'dart:async';

import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:logger/logger.dart';

class EventListViewmodel extends BaseViewmodel {
  final EventService _eventService;
  List<Event> _events = [];
  StreamSubscription? _subscription;

  List<Event> get events => _events;

  final log = Logger();

  EventListViewmodel({required EventService eventService})
    : _eventService = eventService {
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    setBusy(true);
    _subscription = _eventService.getEventsStream().listen(
      (events) {
        _events = events;
        notifyListeners();
        setBusy(false);
      },
      onError: (error) {
        setError(error.toString());
        setBusy(false);
      },
    );
  }

  Future<void> refreshEvents() async {
    _subscribeToEvents();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
