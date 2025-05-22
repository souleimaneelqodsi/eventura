// lib/core/viewmodels/activity_viewmodel.dart
import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/services/activity_service.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/base_viewmodel.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart'; // To interact with parent event
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class ActivityViewModel extends BaseViewmodel {
  final ActivityService _activityService;
  final AuthService _authService;
  final EventViewmodel
  _eventViewModel; // To access parent event details and refresh lists
  final Logger _log = Logger();

  ActivityModel? _activity;
  bool _isCurrentUserSuggester = false;
  bool _isCurrentUserEventOrganizer = false;

  ActivityModel? get activity => _activity;
  bool get isCurrentUserSuggester => _isCurrentUserSuggester;
  bool get isCurrentUserEventOrganizer => _isCurrentUserEventOrganizer;
  String? get currentUserId => _authService.currentUser?.id;

  ActivityViewModel({
    required ActivityService activityService,
    required AuthService authService,
    required EventViewmodel eventViewModel,
  }) : _activityService = activityService,
       _authService = authService,
       _eventViewModel = eventViewModel;

  Future<void> loadActivity(int activityId) async {
    setBusy(true);
    setError(null);
    try {
      _activity = await _activityService.getActivityById(activityId);
      if (_activity != null) {
        final currentUserId = _authService.currentUser?.id;
        _isCurrentUserSuggester = _activity!.suggesterId == currentUserId;
        // Get organizer status from the parent EventViewModel
        _isCurrentUserEventOrganizer = _eventViewModel.isOrganizer ?? false;
      } else {
        throw Exception("Activity not found.");
      }
      notifyListeners();
    } catch (e) {
      _log.e("Error loading activity $activityId: $e");
      setError(e.toString());
      notifyListeners();
    } finally {
      setBusy(false);
    }
  }

  // --- Actions ---
  Future<bool> acceptSuggestion(BuildContext context) async {
    if (_activity == null ||
        !_isCurrentUserEventOrganizer ||
        _activity!.status != ActivityStatus.pendingSuggestion) {
      setError(
        "Cannot accept: Activity not loaded, user not organizer, or not a pending suggestion.",
      );
      notifyListeners();
      return false;
    }
    if (_eventViewModel.event == null) {
      setError("Parent event not loaded.");
      notifyListeners();
      return false;
    }

    setBusy(true);
    setError(null);
    try {
      final updatedActivity = await _activityService.updateActivity(
        _activity!.copyWith(status: ActivityStatus.accepted),
        _eventViewModel.event!, // Pass parent event for boundary checks
      );
      if (updatedActivity != null) {
        _activity = updatedActivity;
        await _eventViewModel.loadEvent(
          _eventViewModel.event!.eventId!,
          context,
        ); // Refresh parent event's activity lists
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _log.e(
        "Error accepting suggestion for activity ${_activity!.activityId}: $e",
      );
      setError(e.toString());
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> rejectSuggestion(BuildContext context) async {
    if (_activity == null ||
        !_isCurrentUserEventOrganizer ||
        _activity!.status != ActivityStatus.pendingSuggestion) {
      setError(
        "Cannot reject: Activity not loaded, user not organizer, or not a pending suggestion.",
      );
      notifyListeners();
      return false;
    }
    setBusy(true);
    setError(null);
    try {
      // Option 1: Mark as rejected (if you want to keep a record)
      // final updatedActivity = await _activityService.updateActivity(
      //   _activity!.copyWith(status: ActivityStatus.rejected),
      //   _eventViewModel.event!,
      // );
      // _activity = updatedActivity;

      // Option 2: Delete the suggestion
      await _activityService.deleteActivity(_activity!.activityId!);
      _activity = null; // Clear the activity as it's deleted

      await _eventViewModel.loadEvent(
        _eventViewModel.event!.eventId!,
        context,
      ); // Refresh parent event's activity lists
      notifyListeners();
      return true;
    } catch (e) {
      _log.e(
        "Error rejecting suggestion for activity ${_activity?.activityId}: $e",
      );
      setError(e.toString());
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }

  Future<bool> retractSuggestion(BuildContext context) async {
    if (_activity == null ||
        !_isCurrentUserSuggester ||
        _activity!.status != ActivityStatus.pendingSuggestion) {
      setError(
        "Cannot retract: Activity not loaded, user not suggester, or not a pending suggestion.",
      );
      notifyListeners();
      return false;
    }
    setBusy(true);
    setError(null);
    try {
      await _activityService.deleteActivity(_activity!.activityId!);
      _activity = null; // Clear the activity

      await _eventViewModel.loadEvent(
        _eventViewModel.event!.eventId!,
        context,
      ); // Refresh parent event's activity lists
      notifyListeners();
      return true;
    } catch (e) {
      _log.e(
        "Error retracting suggestion for activity ${_activity?.activityId}: $e",
      );
      setError(e.toString());
      notifyListeners();
      return false;
    } finally {
      setBusy(false);
    }
  }
}
