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
      await _supabaseClient.from('events').delete().eq('event_id', eventId);
    } catch (e) {
      log.e("Error deleting event", error: e);
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _supabaseClient.from('events').select();
      return response.map<Event>((json) => Event.fromJson(json)).toList();
    } catch (e) {
      log.e("Error while retrieving events", error: e);
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

  Stream<List<Event>> getEventsStream() {
    return _supabaseClient
        .from('events')
        .stream(primaryKey: ['event_id'])
        .map((data) => data.map((e) => Event.fromJson(e)).toList());
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
