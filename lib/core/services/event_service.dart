// ignore_for_file: unnecessary_null_comparison

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final SupabaseClient _supabaseClient;

  Logger log = Logger();

  EventService({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<Event?> getEventById(int eventId) async {
    try {
      final response = await _supabaseClient
          .from('events')
          .select()
          .eq('event_id', eventId);

      // ignore: unnecessary_type_check
      if ((response is List && response.isEmpty) || response == null) {
        String msg = "Aucun événement trouvé avec l'ID $eventId.";
        log.i(msg);
        throw Exception(msg);
      }

      log.d(response);

      if (response is Map) {
        return Event.fromJson(response as Map<String, dynamic>);
      } else {
        // ignore: unnecessary_type_check
        if (response is List) {
          return Event.fromJson(response[0]);
        }
        String msg = "Erreur inconnue, reponse est de type inconnu";
        log.i(msg);
        throw Exception(msg);
      }
    } catch (e) {
      log.e("Erreur lors de la récupération de l'événement.", error:e);
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _supabaseClient.from('events').select();
      return response.map<Event>((json) => Event.fromJson(json)).toList();
    } catch (e) {
      log.e("Erreur lors de la récupération des événements", error:e);
      rethrow;
    }
  }

  Stream<List<Event>> getEventsStream() {
    if (_supabaseClient != null) log.t("Supabase Client is not null");
    return _supabaseClient
        .from('events')
        .stream(primaryKey: ['event_id'])
        .map((data) => data.map((e) => Event.fromJson(e)).toList());
  }

  Future<Event?> createEvent(Event event) async {
    try {
      final response =
          await _supabaseClient
              .from('events')
              .insert(event.toJson())
              .select()
              .single();
      if (response != null) {
        return Event.fromJson(response);
      }
      return null;
    } catch (error) {
      log.e("Error creating event", error:error);
      rethrow;
    }
  }

  Future<Event?> updateEvent(Event event) async {
    if (event.eventId == null) {
      throw Exception(
        "Erreur : Impossible de mettre à jour un événement sans ID.",
      );
    }

    try {
      final response =
          await _supabaseClient
              .from('events')
              .update(event.toJson())
              .eq('event_id', event.eventId!)
              .select()
              .single();
      if (response == null) {
        throw Exception(
          "Event update failed: could not write to the database.",
        );
      }
      return Event.fromJson(response);
    } catch (e) {
      log.e("Erreur lors de la mise à jour de l'événement", error:e);
      rethrow;
    }
  }

  Future<void> deleteEvent(int eventId) async {
    try {
      await _supabaseClient.from('events').delete().eq('event_id', eventId);
    } catch (e) {
      log.e("Erreur lors de la suppression de l'événement", error:e);
      rethrow;
    }
  }
}
