import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  late final GoTrueClient _supabaseClient;

  AuthService({required SupabaseClient supabaseClient}) : _supabaseClient = supabaseClient.auth;

  signIn(String email, String password) {}

  signUp(String email, String password) {}}