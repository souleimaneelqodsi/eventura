import 'package:eventura/core/models/activity.dart';
import 'package:eventura/core/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class ActivityService {
  final SupabaseClient _supabaseClient;
  final Logger _log = Logger();

  ActivityService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<List<ActivityModel>> getActivitiesForEvent(
    int eventId, {
    List<ActivityStatus>? statuses,
  }) async {
    try {
      var query = _supabaseClient
          .from('activities')
          .select()
          .eq('event_id', eventId)
          .order('start_time', ascending: true);

      if (statuses != null && statuses.isNotEmpty) {
        query = _supabaseClient
            .from('activities')
            .select()
            .eq('event_id', eventId)
            .inFilter(
              'status',
              statuses.map((s) => activityStatusToString(s)).toList(),
            )
            .order('start_time', ascending: true);
      }

      final response = await query;

      return response.map((data) => ActivityModel.fromJson(data)).toList();
    } catch (e) {
      _log.e('Error fetching activities for event $eventId: $e');
      rethrow;
    }
  }

  Future<bool> _doesActivityOverlap(
    ActivityModel activityToCheck,
    Event parentEvent, {
    int? excludeActivityId,
  }) async {
    if (activityToCheck.startTime == null || activityToCheck.endTime == null) {
      _log.w('Activity to check has null start or end time.');
      return true;
    }
    if (activityToCheck.startTime!.isBefore(parentEvent.beginning) ||
        activityToCheck.endTime!.isAfter(parentEvent.end)) {
      _log.i(
        'Activity (ID: ${activityToCheck.activityId}) is outside parent event (ID: ${parentEvent.eventId}) boundaries.',
      );
      throw Exception(
        'Activity time must be within the event\'s overall start and end times.',
      );
    }

    final existingActivitiesResponse = await _supabaseClient
        .from('activities')
        .select('start_time, end_time, activity_id')
        .inFilter('status', [
          activityStatusToString(ActivityStatus.accepted),
          activityStatusToString(ActivityStatus.organizerCreated),
        ])
        .eq('event_id', activityToCheck.eventId);

    final List<Map<String, dynamic>> existingActivities =
        List<Map<String, dynamic>>.from(existingActivitiesResponse);

    for (var existingActivityData in existingActivities) {
      final existingActivityId = existingActivityData['activity_id'] as int?;

      if (excludeActivityId != null &&
          existingActivityId == excludeActivityId) {
        continue;
      }

      final DateTime existingStartTime = DateTime.parse(
        existingActivityData['start_time'] as String,
      );
      final DateTime existingEndTime = DateTime.parse(
        existingActivityData['end_time'] as String,
      );

      if (activityToCheck.startTime!.isBefore(existingEndTime) &&
          activityToCheck.endTime!.isAfter(existingStartTime)) {
        _log.i(
          'Activity (ID: ${activityToCheck.activityId}) overlaps with existing activity (ID: $existingActivityId).',
        );
        return true;
      }
    }
    return false;
  }

  Future<ActivityModel?> createActivity(
    ActivityModel activity,
    Event parentEvent,
  ) async {
    try {
      if (activity.status == ActivityStatus.organizerCreated ||
          activity.status == ActivityStatus.accepted) {
        if (await _doesActivityOverlap(activity, parentEvent)) {
          throw Exception(
            'Activity time overlaps with an existing activity or is outside event boundaries.',
          );
        }
      }

      if (activity.startTime == null ||
          activity.endTime == null ||
          activity.startTime!.isBefore(parentEvent.beginning) ||
          activity.endTime!.isAfter(parentEvent.end)) {
        throw Exception(
          'Activity time must be within the event\'s overall start and end times.',
        );
      }

      final response =
          await _supabaseClient
              .from('activities')
              .insert(activity.toJson())
              .select()
              .single();

      return ActivityModel.fromJson(response);
    } catch (e) {
      _log.e('Error creating activity: $e');
      rethrow;
    }
  }

  Future<ActivityModel?> updateActivity(
    ActivityModel activity,
    Event parentEvent,
  ) async {
    if (activity.activityId == null) {
      _log.e('Cannot update activity without an ID.');
      throw Exception('Activity ID is required for an update.');
    }
    try {
      if (activity.status == ActivityStatus.accepted) {
        if (await _doesActivityOverlap(
          activity,
          parentEvent,
          excludeActivityId: activity.activityId,
        )) {
          throw Exception(
            'Accepting this activity would cause an overlap with an existing activity or is outside event boundaries.',
          );
        }
      }

      if (activity.startTime != null &&
          activity.endTime != null &&
          (activity.startTime!.isBefore(parentEvent.beginning) ||
              activity.endTime!.isAfter(parentEvent.end))) {
        throw Exception(
          'Updated activity time must be within the event\'s overall start and end times.',
        );
      }

      final response =
          await _supabaseClient
              .from('activities')
              .update(activity.toJson())
              .eq('activity_id', activity.activityId!)
              .select()
              .single();

      return ActivityModel.fromJson(response);
    } catch (e) {
      _log.e('Error updating activity ${activity.activityId}: $e');
      rethrow;
    }
  }

  Future<void> deleteActivity(int activityId) async {
    try {
      await _supabaseClient
          .from('activities')
          .delete()
          .eq('activity_id', activityId);
      _log.i('Activity $activityId deleted.');
    } catch (e) {
      _log.e('Error deleting activity $activityId: $e');
      rethrow;
    }
  }

  Future<ActivityModel?> getActivityById(int activityId) async {
    try {
      final response =
          await _supabaseClient
              .from('activities')
              .select()
              .eq('activity_id', activityId)
              .maybeSingle();
      if (response == null) return null;
      return ActivityModel.fromJson(response);
    } catch (e) {
      _log.e('Error fetching activity $activityId: $e');
      rethrow;
    }
  }
}
