// providers.dart
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/services/event_service.dart';
import 'package:eventura/core/services/friend_service.dart';
import 'package:eventura/core/services/message_service.dart';
import 'package:eventura/core/viewmodels/auth/login_viewmodel.dart';
import 'package:eventura/core/viewmodels/auth/reset_password_viewmodel.dart';
import 'package:eventura/core/viewmodels/auth/signup_viewmodel.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/core/viewmodels/events_list_viewmodel.dart';
import 'package:eventura/core/viewmodels/friends_viewmodel.dart';
import 'package:eventura/core/viewmodels/messages_list_viewmodel.dart';
// import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
import 'package:eventura/ui/shared/is_editing_profile.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

List<SingleChildWidget> providers = [
  // --- Services ---,
  Provider<AuthService>(create: (_) => AuthService(supabaseClient: supabase)),
  Provider<EventService>(create: (_) => EventService(supabaseClient: supabase)),
  Provider<FriendService>(
    create:
        (_) => FriendService(
          userId: supabase.auth.currentUser!.id,
          supabaseClient: supabase,
        ),
  ),

  // --- ViewModels ---
  ChangeNotifierProvider<LoginViewmodel>(
    create:
        (context) => LoginViewmodel(authService: context.read<AuthService>()),
  ),
  ChangeNotifierProvider<SignupViewmodel>(
    create:
        (context) => SignupViewmodel(authService: context.read<AuthService>()),
  ),
  ChangeNotifierProvider<ResetPasswordViewmodel>(
    create:
        (context) =>
            ResetPasswordViewmodel(authService: context.read<AuthService>()),
  ),

  ChangeNotifierProvider<EventListViewmodel>(
    create:
        (context) =>
            EventListViewmodel(eventService: context.read<EventService>()),
  ),
  ChangeNotifierProvider<EventViewmodel>(
    create:
        (context) => EventViewmodel(eventService: context.read<EventService>()),
  ),
  ChangeNotifierProvider<FriendsViewmodel>(
    create:
        (context) =>
            FriendsViewmodel(friendService: context.read<FriendService>()),
  ),

  ChangeNotifierProvider<MessagesListViewmodel>(
    create:
        (context) => MessagesListViewmodel(
          messageService: context.read<MessageService>(),
        ),
  ),

  ChangeNotifierProvider<SettingsViewmodel>(
    create: (context) => SettingsViewmodel(),
  ),

  ChangeNotifierProvider<ProfileEditingState>(
    create: (context) => ProfileEditingState(),
  ),
];

final supabase = Supabase.instance.client;
