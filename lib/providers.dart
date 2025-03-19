// providers.dart
import 'package:eventura/core/services/message_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/viewmodels/auth/login_viewmodel.dart';
import 'package:eventura/core/viewmodels/auth/signup_viewmodel.dart';
import 'package:eventura/core/viewmodels/create_event_viewmodel.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/core/viewmodels/messages_list_viewmodel.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
//import 'package:eventura/core/viewmodels/base_viewmodel.dart'; // Add this

final supabase = Supabase.instance.client;

List<SingleChildWidget> providers = [
  // --- Services ---
  Provider<SupabaseService>(
    create: (_) => SupabaseService(supabaseClient: supabase),
  ),
  Provider<AuthService>(create: (_) => AuthService(supabaseClient: supabase)),
  Provider<EventService>(create: (_) => EventService(supabaseClient: supabase)),
  Provider<FriendService>(
    create: (_) => FriendService(supabaseClient: supabase),
  ),

  // --- ViewModels ---

  // Auth View Models:
  ChangeNotifierProvider<LoginViewmodel>(
    create:
        (context) => LoginViewmodel(authService: context.read<AuthService>()),
  ),
  ChangeNotifierProvider<SignupViewmodel>(
    create:
        (context) => SignupViewmodel(authService: context.read<AuthService>()),
  ),

  // Event View Models:
  ChangeNotifierProvider<EventsListViewModel>(
    create:
        (context) =>
            EventsListViewModel(eventService: context.read<EventService>()),
  ),
  ChangeNotifierProvider<CreateEventViewmodel>(
    create:
        (context) =>
            CreateEventViewmodel(eventService: context.read<EventService>()),
  ),
  // Friend View Model
  ChangeNotifierProvider<FriendsViewmodel>(
    create:
        (context) =>
            FriendsViewmodel(friendService: context.read<FriendService>()),
  ),

  // Message List View Model
  ChangeNotifierProvider<MessagesListViewmodel>(
    create:
        (context) => MessagesListViewmodel(
          messageService: context.read<MessageService>(),
        ),
  ),

  // Settings View Model
  ChangeNotifierProvider<SettingsViewmodel>(
    create:
        (context) => SettingsViewmodel(), // TODO:add the necessary dependencies
  ),

  ChangeNotifierProvider<ProfileViewmodel>(
    create:
        (context) => ProfileViewmodel(
          userService: context.read<SupabaseService>(),
          userId: '',
        ), // Provide necessary dependencies
  ),
];
