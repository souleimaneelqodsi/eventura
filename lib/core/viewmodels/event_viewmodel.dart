import 'dart:io';
import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/models/event.dart';
import 'package:eventura/core/services/activity_service.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class EventViewmodel extends BaseViewmodel {
  final EventService _eventService;
  final ActivityService _activityService;
  final AuthService _authService;
  final Logger _log = Logger();

  Event? _event;
  bool _isCurrentEventFavorited = false;
  bool? _isParticipating;
  bool? _isOrganizer;
  bool? _isPublic;

  List<ActivityModel> _acceptedActivities = [];
  List<ActivityModel> _pendingSuggestedActivities = [];

  EventViewmodel({
    required EventService eventService,
    required ActivityService activityService,
    required AuthService authService,
  }) : _eventService = eventService,
       _activityService = activityService,
       _authService = authService;

  Event? get event => _event;
  bool get isCurrentEventFavorited => _isCurrentEventFavorited;
  bool? get isParticipating => _isParticipating;
  bool? get isOrganizer => _isOrganizer;
  bool? get isPublic => _isPublic;

  List<ActivityModel> get acceptedActivities => _acceptedActivities;
  List<ActivityModel> get pendingSuggestedActivities =>
      _pendingSuggestedActivities;
  String? get currentUserId => _authService.currentUser?.id;

  Future<void> loadEvent(int eventId, BuildContext context) async {
    setBusy(true);
    setError(null);
    _acceptedActivities = [];
    _pendingSuggestedActivities = [];
    _isPublic = null;

    try {
      _event = await _eventService.getEventById(eventId);
      if (_event != null) {
        _isPublic = !_event!.isPrivate;

        _isParticipating = await _eventService.isUserParticipating(
          _event!.eventId!,
        );

        final currentUserId = _authService.currentUser?.id;
        _isOrganizer =
            currentUserId != null && _event!.organizerId == currentUserId;

        if (_isOrganizer == true) {
          _isParticipating = true;
        }

        final eventListVM = Provider.of<EventListViewmodel>(
          context,
          listen: false,
        );
        _isCurrentEventFavorited = eventListVM.isEventFavorited(eventId);

        await _loadActivities();
      } else {
        _isParticipating = null;
        _isOrganizer = null;
        _isCurrentEventFavorited = false;
        _isPublic = null;
        throw Exception("Event not found.");
      }
      notifyListeners();
    } catch (e) {
      _log.e("Error loading event $eventId: $e");
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> _loadActivities() async {
    if (_event == null || _event!.eventId == null) return;

    try {
      _acceptedActivities = await _activityService.getActivitiesForEvent(
        _event!.eventId!,
        statuses: [ActivityStatus.accepted, ActivityStatus.organizerCreated],
      );

      if (_isOrganizer == true) {
        _pendingSuggestedActivities = await _activityService
            .getActivitiesForEvent(
              _event!.eventId!,
              statuses: [ActivityStatus.pendingSuggestion],
            );
      }
      notifyListeners();
    } catch (e) {
      _log.e("Error loading activities for event ${_event!.eventId}: $e");
      setError("Could not load event activities. ${e.toString()}");
    }
  }

  Future<void> suggestActivity(ActivityModel newActivity) async {
    if (_event == null) {
      setError("Cannot suggest activity: Event not loaded.");
      notifyListeners();
      return;
    }
    setBusy(true);
    setError(null);
    try {
      final suggesterId = _authService.currentUser?.id;
      if (suggesterId == null) throw Exception("User not authenticated.");

      await _activityService.createActivity(
        newActivity.copyWith(
          eventId: _event!.eventId,
          status: ActivityStatus.pendingSuggestion,
          suggesterId: suggesterId,
        ),
        _event!,
      );
      await _loadActivities();
    } catch (e) {
      _log.e("Error suggesting activity: $e");
      setError(e.toString());
    } finally {
      setBusy(false);

      notifyListeners();
    }
  }

  Future<void> createOrganizerActivity(ActivityModel newActivity) async {
    if (_event == null || _isOrganizer != true) {
      setError(
        "Cannot create activity: Event not loaded or user is not organizer.",
      );
      notifyListeners();
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await _activityService.createActivity(
        newActivity.copyWith(
          eventId: _event!.eventId,
          status: ActivityStatus.organizerCreated,
          suggesterId: null,
        ),
        _event!,
      );
      await _loadActivities();
    } catch (e) {
      _log.e("Error creating organizer activity: $e");
      setError(e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> acceptActivitySuggestion(ActivityModel activity) async {
    if (_event == null || _isOrganizer != true) {
      setError("Action not allowed or event not loaded.");
      notifyListeners();
      return;
    }
    setBusy(true);
    setError(null);
    try {
      await _activityService.updateActivity(
        activity.copyWith(status: ActivityStatus.accepted),
        _event!,
      );
      await _loadActivities();
    } catch (e) {
      _log.e("Error accepting activity suggestion ${activity.activityId}: $e");
      setError(e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> rejectActivitySuggestion(ActivityModel activity) async {
    if (_isOrganizer != true) {
      setError("Action not allowed.");
      notifyListeners();
      return;
    }
    setBusy(true);
    setError(null);
    try {
      if (activity.activityId != null) {
        await _activityService.deleteActivity(activity.activityId!);
      } else {
        throw Exception("Activity ID is null, cannot delete.");
      }
      await _loadActivities();
    } catch (e) {
      _log.e(
        "Error rejecting/deleting activity suggestion ${activity.activityId}: $e",
      );
      setError(e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> retractActivitySuggestion(int activityId) async {
    setBusy(true);
    setError(null);
    try {
      final activityToRetract = await _activityService.getActivityById(
        activityId,
      );
      if (activityToRetract == null) throw Exception("Activity not found.");
      if (activityToRetract.suggesterId != _authService.currentUser?.id) {
        throw Exception("You are not authorized to retract this suggestion.");
      }
      if (activityToRetract.status != ActivityStatus.pendingSuggestion) {
        throw Exception("This suggestion can no longer be retracted.");
      }

      await _activityService.deleteActivity(activityId);
      await _loadActivities();
    } catch (e) {
      _log.e("Error retracting activity suggestion $activityId: $e");
      setError(e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
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
      _isOrganizer = null;
      _isCurrentEventFavorited = false;
      _isPublic = null;
      _acceptedActivities = [];
      _pendingSuggestedActivities = [];

      if (Navigator.canPop(context)) {
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

  Future<void> createEvent(
    BuildContext context,
    Event event, {
    File? imageFile,
  }) async {
    setBusy(true);
    setError(null);
    try {
      Event? createdEventRecord = await _eventService.createEvent(
        event.copyWith(coverPicture: null),
      );

      if (createdEventRecord != null &&
          createdEventRecord.eventId != null &&
          imageFile != null) {
        final imageUrl = await _eventService.uploadEventImage(
          imageFile,
          createdEventRecord.eventId.toString(),
        );
        if (imageUrl != null) {
          _event = await _eventService.updateEventCoverPicture(
            createdEventRecord.eventId!,
            imageUrl,
          );
        } else {
          _event = createdEventRecord;
        }
      } else if (createdEventRecord != null) {
        _event = createdEventRecord;
      } else {
        throw Exception("Failed to create event record.");
      }

      if (context.mounted && !hasError) {}
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
        final currentUserId = _authService.currentUser?.id;
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

  Future<void> joinPublicEvent(int eventId, BuildContext context) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.joinPublicEvent(eventId);

      await loadEvent(eventId, context);
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> leaveEvent(int eventId, BuildContext context) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.leaveEvent(eventId);
      await loadEvent(eventId, context);
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  Future<void> addFriendToEvent(
    String friendId,
    int eventId,
    BuildContext context,
  ) async {
    setBusy(true);
    setError(null);
    try {
      await _eventService.addFriendToEvent(eventId, friendId);
      await loadEvent(eventId, context);
    } catch (e) {
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }
}
