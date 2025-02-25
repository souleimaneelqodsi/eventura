import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';

class EventService {
  final SupabaseClient _supabaseClient;

  EventService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  // Récupérer un événement par son ID
  Future<Event?> getEventById(int eventId) async {
    try {
      final response = await _supabaseClient
          .from('events')
          .select()
          .eq('event_id', eventId)
          .maybeSingle(); // Remplace `.single()` par `.maybeSingle()`

      if (response == null) {
        print("Aucun événement trouvé avec l'ID $eventId.");
        return null;
      }

      return Event.fromJson(response);
    } catch (e) {
      print("Erreur lors de la récupération de l'événement : $e");
      return null;
    }
  }

  // Récupérer la liste de tous les événements
  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _supabaseClient.from('events').select();
      return response.map<Event>((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print("Erreur lors de la récupération des événements : $e");
      return [];
    }
  }

  // Ajouter un nouvel événement
  Future<void> createEvent(Event event) async {
    try {
      await _supabaseClient.from('events').insert(event.toJson());
    } catch (e) {
      print("Erreur lors de l'ajout de l'événement : $e");
    }
  }

  // Mettre à jour un événement
  Future<void> updateEvent(Event event) async {
    if (event.eventId == null) {
      print("Erreur : Impossible de mettre à jour un événement sans ID.");
      return;
    }

    try {
      await _supabaseClient
          .from('events')
          .update(event.toJson())
          .eq('event_id', event.eventId!);
    } catch (e) {
      print("Erreur lors de la mise à jour de l'événement : $e");
    }
  }

  // Supprimer un événement
  Future<void> deleteEvent(int eventId) async {
    try {
      await _supabaseClient.from('events').delete().eq('event_id', eventId);
    } catch (e) {
      print("Erreur lors de la suppression de l'événement : $e");
    }
  }
}
