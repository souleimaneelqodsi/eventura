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

  final log = Logger();

  EventListViewmodel({required EventService eventService})
    : _eventService = eventService {
    _subscribeToEvents();
  }

  List<Event> get events => _events;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> refreshEvents() async {
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
}
