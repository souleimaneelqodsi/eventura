import 'package:eventura/core/services/activity_service.dart';
import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/activity_viewmodel.dart';
import 'package:eventura/core/viewmodels/event_viewmodel.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
import 'package:eventura/ui/views/activity_detail_view.dart';
import 'package:eventura/ui/views/create_activity_view.dart';
import '../providers.dart';
import 'package:eventura/ui/shared/app_colors.dart';
import 'package:eventura/ui/shared/app_theme.dart';
import 'package:eventura/ui/static/about_us.dart';
import 'package:eventura/ui/static/contact_us.dart';
import 'package:eventura/ui/static/faq.dart';
import 'package:eventura/ui/views/auth/login_view.dart';
import 'package:eventura/ui/views/auth/reset_password_view.dart';
import 'package:eventura/ui/views/auth/signup_view.dart';
import 'package:eventura/ui/views/create_event_view.dart';
import 'package:eventura/ui/views/event_detail_view.dart';
import 'package:eventura/ui/views/events_list_view.dart';
import 'package:eventura/ui/views/friends_view.dart';
import 'package:eventura/ui/views/homepage_view.dart';
import 'package:eventura/ui/views/messages_view.dart';
import 'package:eventura/ui/views/profile_view.dart';
import 'package:eventura/ui/views/settings_view.dart';
import 'package:eventura/ui/views/welcome_view.dart';
import 'package:eventura/ui/widgets/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseKey == null) {
    logger.e(
      "CRITICAL ERROR: SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file.",
    );

    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final settingsViewModel = SettingsViewmodel();
  await settingsViewModel.loadSettings();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsViewmodel>.value(
          value: settingsViewModel,
        ),

        ...providers,
      ],
      child: const Eventura(),
    ),
  );
}

final supabase = Supabase.instance.client;
final logger = Logger();

class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name == '/login') {
      _cancelSubscriptions();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute?.settings.name == '/login') {
      _cancelSubscriptions();
    }
  }

  void _cancelSubscriptions() {
    try {
      final supabase = Supabase.instance.client;
      supabase.removeAllChannels();
    } catch (e) {
      logger.e("Error clearing subscriptions: $e", error: e);
    }
  }
}

class Eventura extends StatelessWidget {
  const Eventura({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewmodel>(
      builder: (context, viewmodel, child) {
        return MaterialApp(
          title: 'Eventura',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              viewmodel.settings.lightMode ? ThemeMode.light : ThemeMode.dark,
          initialRoute: '/',
          navigatorObservers: [NavigationObserver()],
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => const AuthWrapper(),
              );
            }

            if (settings.name == '/event_detail') {
              final eventId = settings.arguments as int?;
              if (eventId == null) {
                return MaterialPageRoute(
                  settings: settings,
                  builder:
                      (context) => Scaffold(
                        appBar: AppBar(title: const Text("Error")),
                        body: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Error: No Event ID provided for event_detail",
                              style: TextStyle(color: AppColors.errorRed),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                );
              }
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => EventDetailView(eventId: eventId),
              );
            }

            if (settings.name == '/create_activity') {
              if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                final eventId = args['eventId'] as int?;
                final eventViewModel =
                    args['eventViewModel'] as EventViewmodel?;

                if (eventId != null && eventViewModel != null) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder:
                        (context) => CreateActivityView(
                          eventId: eventId,
                          eventViewModel: eventViewModel,
                        ),
                  );
                }
              }

              return MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      appBar: AppBar(title: const Text("Error")),
                      body: const Center(
                        child: Text(
                          "Error: Invalid arguments for creating activity.",
                        ),
                      ),
                    ),
              );
            }

            if (settings.name == '/activity_detail') {
              if (settings.arguments is Map<String, dynamic>) {
                final args = settings.arguments as Map<String, dynamic>;
                final activityId = args['activityId'] as int?;
                final eventViewModel =
                    args['eventViewModel'] as EventViewmodel?;

                if (activityId != null && eventViewModel != null) {
                  return MaterialPageRoute(
                    settings: settings,
                    builder:
                        (context) => ChangeNotifierProvider(
                          create:
                              (_) => ActivityViewModel(
                                activityService:
                                    context.read<ActivityService>(),
                                authService: context.read<AuthService>(),
                                eventViewModel: eventViewModel,
                              ),
                          child: ActivityDetailView(activityId: activityId),
                        ),
                  );
                }
              }

              return MaterialPageRoute(
                builder:
                    (_) => Scaffold(
                      appBar: AppBar(title: const Text("Error")),
                      body: const Center(
                        child: Text(
                          "Error: Invalid arguments for activity detail.",
                        ),
                      ),
                    ),
              );
            }

            return null;
          },
          routes: {
            '/login': (context) => LoginView(),
            '/signup': (context) => SignupView(),
            '/reset_password': (context) => ResetPasswordView(),
            '/welcome': (context) => const WelcomeView(),
            '/home': (context) => const HomepageView(),
            '/create_event': (context) => const CreateEventView(),
            '/friends': (context) => const FriendsView(),
            '/messages': (context) => const MessagesView(),
            '/profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;

              final String? potentialUserId = args is String ? args : null;
              final String currentAuthUserId =
                  supabase.auth.currentUser?.id ?? '';
              final String finalUserId =
                  (potentialUserId?.isNotEmpty ?? false)
                      ? potentialUserId!
                      : currentAuthUserId;

              if (finalUserId.isEmpty && supabase.auth.currentUser == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text("Error")),
                  body: const Center(
                    child: Text("User not authenticated and no ID provided."),
                  ),
                );
              }

              return ChangeNotifierProvider(
                key: ValueKey('profile_route_$finalUserId'),
                create:
                    (context) => ProfileViewmodel(
                      userService: Provider.of<AuthService>(
                        context,
                        listen: false,
                      ),
                      userId: finalUserId,
                    ),
                child: ProfileView(
                  userId: finalUserId,
                  fromHome: false,
                  key: ValueKey('profile_page_$finalUserId'),
                ),
              );
            },
            '/settings': (context) => const SettingsView(),
            '/about': (context) => const AboutUs(),
            '/contact': (context) => const ContactUs(),
            '/faq': (context) => FAQ(),
            '/events_list': (context) => const EventListView(),
          },
        );
      },
    );
  }
}
