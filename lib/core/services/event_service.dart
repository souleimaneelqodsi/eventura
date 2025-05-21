import 'package:eventura/core/services/friend_service.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event.dart';

class EventService {
  final SupabaseClient _supabaseClient;

  Logger log = Logger();

  EventService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<Event?> createEvent(Event event) async {
    try {
      final response =
          await _supabaseClient.from('events').insert(event.toJson()).select();
      if (response.isEmpty) {
        throw Exception("Couldn't create the event. DB response was empty.");
      }
      return Event.fromJson(response.first);
    } catch (error) {
      log.e("Error creating event", error: error);
      rethrow;
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      final event = await getEventById(eventId);
      if (event == null) {
        throw Exception("Event not found");
      }
      if (event.organizerId != _supabaseClient.auth.currentUser!.id) {
        throw Exception("You are not the organizer of this event.");
      }
      await _supabaseClient.from('events').delete().eq('event_id', eventId);
    } catch (e) {
      log.e("Error deleting event", error: e);
      rethrow;
    }
  }

  Future<bool> isUserParticipating(int eventId) async {
    try {
      Event? event = await getEventById(eventId);
      if (event == null) return false;
      final response = await _supabaseClient
          .from('guests')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .eq('event_id', eventId)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      log.e("Error fetching user participation", error: e);
      rethrow;
    }
  }

  Future<List<Event>> getUserEvents() async {
    try {
      final response = await _supabaseClient.rpc('get_my_events');

      if (response is List) {
        var result =
            response
                .map<Event>(
                  (json) => Event.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        return result;
      } else if (response == null) {
        log.w("RPC 'get_my_events' returned null.");
        return [];
      } else {
        log.e(
          "Unexpected response from RPC 'get_my_events': type ${response.runtimeType}, value: $response",
        );
        throw Exception(
          "Unexpected response format from 'get_my_events' function.",
        );
      }
    } catch (e) {
      log.e("Error calling RPC 'get_my_events'", error: e);
      rethrow;
    }
  }

  Future<void> addFriendToEvent(int eventId, String userId) async {
    try {
      Event? event = await getEventById(eventId);
      if (event != null) {
        if (event.nbGuests >= event.capacity) {
          throw Exception("Event id $eventId is full");
        }
      } else {
        throw Exception("Event id $eventId does not exist");
      }
      var response = await _supabaseClient
          .from('guests')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .eq('event_id', eventId)
          .limit(1);
      if (response.isEmpty) {
        throw Exception(
          "You cannot add a user to an event you don't take part in.",
        );
      }
      try {
        FriendService friendService = FriendService(
          supabaseClient: _supabaseClient,
          userId: _supabaseClient.auth.currentUser!.id,
        );

        friendService.getFriendshipByIds(
          userId,
          _supabaseClient.auth.currentUser!.id,
        );
      } catch (e) {
        log.e(
          "An error occurred while checking if the user is friend with the person they're trying to add event id n°$eventId",
          error: e,
        );
        rethrow;
      }
      response =
          await _supabaseClient.from('guests').insert({
            'user_id': userId,
            'event_id': eventId,
          }).select();
      if (response.isEmpty) {
        throw Exception("An error occurred while adding a friend to event");
      }
    } catch (e) {
      log.e("An error occurred while adding a friend to event", error: e);
      rethrow;
    }
  }

  Future<void> joinPublicEvent(int eventId) async {
    try {
      Event? event = await getEventById(eventId);
      if (event == null) {
        throw Exception("Event not found");
      }
      if (event.isPrivate) {
        throw Exception("Event is private");
      }
      if (event.nbGuests >= event.capacity) {
        throw Exception("Event is full");
      }
      await _supabaseClient.from('guests').insert({
        'user_id': _supabaseClient.auth.currentUser!.id,
        'event_id': eventId,
      }).select();
    } catch (e) {
      log.e("An error occurred while joining public event", error: e);
      rethrow;
    }
  }

  Future<void> leaveEvent(int eventId) async {
    Event? event = await getEventById(eventId);
    try {
      if (event == null) {
        throw Exception("Event not found");
      }
      await _supabaseClient
          .from('guests')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', _supabaseClient.auth.currentUser!.id);
    } catch (e) {
      log.e("An error occurred while leaving event", error: e);
      rethrow;
    }
  }

  Future<List<Event>> getPublicEvents() async {
    try {
      final currentUserId = _supabaseClient.auth.currentUser!.id;

      final response = await _supabaseClient
          .from('events')
          .select()
          .eq('is_private', false)
          .gt('end', DateTime.now().toIso8601String())
          .order('beginning', ascending: true);

      if (response.isEmpty) {
        return [];
      }

      List<Event> publicEvents =
          response.map<Event>((json) => Event.fromJson(json)).toList();

      final participatingEventIdsResponse = await _supabaseClient
          .from('guests')
          .select('event_id')
          .eq('user_id', currentUserId);

      final Set<int> participatingEventIds =
          participatingEventIdsResponse
              .map<int>((row) => row['event_id'] as int)
              .toSet();

      List<Event> filteredEvents =
          publicEvents.where((event) {
            return !participatingEventIds.contains(event.eventId);
          }).toList();

      return filteredEvents;
    } catch (e) {
      log.e("Error fetching public events", error: e);
      rethrow;
    }
  }

  Future<Event?> getEventById(int eventId) async {
    try {
      final response = await _supabaseClient
          .from('events')
          .select()
          .eq('event_id', eventId);

      if (response.isEmpty) {
        String msg = "No event found with ID $eventId.";
        log.i(msg);
        throw Exception(msg);
      }
      return Event.fromJson(response.first);
    } catch (e) {
      log.e("Error while retrieving event.", error: e);
      rethrow;
    }
  }

  Future<bool> toggleFavorite(int eventId) async {
    final currentUserId = _supabaseClient.auth.currentUser!.id;
    await getEventById(eventId);
    try {
      final favoriteEntry =
          await _supabaseClient
              .from('event_favorites')
              .select('favorite_id')
              .eq('event_id', eventId)
              .eq('user_id', currentUserId)
              .maybeSingle();

      if (favoriteEntry == null) {
        await _supabaseClient.from('event_favorites').insert({
          'user_id': currentUserId,
          'event_id': eventId,
        });
        return true;
      } else {
        await _supabaseClient
            .from('event_favorites')
            .delete()
            .eq('event_id', eventId)
            .eq('user_id', currentUserId);
        return false;
      }
    } catch (e) {
      log.e('Error toggling favorite status for event $eventId', error: e);
      rethrow;
    }
  }

  Future<List<Event>> getFavoriteEvents() async {
    try {
      final response = await _supabaseClient.rpc('get_user_favorite_events');

      if (response is List) {
        final List<Event> events =
            response
                .map<Event>(
                  (json) => Event.fromJson(json as Map<String, dynamic>),
                )
                .toList();
        return events;
      } else if (response == null) {
        log.w(
          "RPC 'get_user_favorite_events' returned null. Returning an empty list.",
        );
        return [];
      } else {
        log.e(
          "Unexpected response from RPC 'get_user_favorite_events'. Type: ${response.runtimeType}, Data: $response",
        );
        throw Exception(
          "Unexpected response format for get_user_favorite_events.",
        );
      }
    } catch (e) {
      if (e is PostgrestException) {
        log.e(
          "Postgrest error calling RPC 'get_user_favorite_events': ${e.message} (Code: ${e.code})",
          error: e,
        );
      } else {
        log.e(
          "Unexpected error calling RPC 'get_user_favorite_events'",
          error: e,
          stackTrace: e is Error ? e.stackTrace : null,
        );
      }
      rethrow;
    }
  }

  Future<Event?> updateEvent(Event event) async {
    if (event.eventId == null) {
      throw Exception("Error: cannot update an event without an ID.");
    }

    try {
      final response =
          await _supabaseClient
              .from('events')
              .update(event.toJson())
              .eq('event_id', event.eventId!)
              .select();
      if (response.isEmpty) {
        throw Exception(
          "Event update failed: could not write to the database.",
        );
      }
      return Event.fromJson(response.first);
    } catch (e) {
      log.e("Error updating event", error: e);
      rethrow;
    }
  }
}
