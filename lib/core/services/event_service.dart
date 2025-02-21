import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  final SupabaseClient _supabaseClient;

  EventService({required SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient;}