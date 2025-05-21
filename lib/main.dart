import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/core/viewmodels/settings_viewmodel.dart';
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

  await Supabase.initialize(url: supabaseUrl!, anonKey: supabaseKey!);

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
        ...providers.where(
          (p) => p is! ChangeNotifierProvider<SettingsViewmodel>,
        ),
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
                              "Error: No Event ID provided",
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

            return null;
          },
          routes: {
            '/': (context) => const AuthWrapper(),
            '/login': (context) => LoginView(),
            '/signup': (context) => SignupView(),

            '/reset_password': (context) => ResetPasswordView(),
            '/welcome': (context) => WelcomeView(),
            '/home': (context) => HomepageView(),
            '/create_event': (context) => CreateEventView(),
            '/event_detail': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              final eventId = args as int?;
              if (eventId == null) {
                return Scaffold(
                  appBar: AppBar(title: Text("Error")),
                  body: Center(
                    child: Text(
                      "Error: No Event ID",
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                );
              }
              return EventDetailView(eventId: eventId);
            },
            '/friends': (context) => FriendsView(),
            '/messages': (context) => MessagesView(),
            '/profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              final userId = args as String?;
              final finalUserId = userId ?? supabase.auth.currentUser!.id;

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
                  key: ValueKey('profile_$finalUserId'),
                ),
              );
            },
            '/settings': (context) => SettingsView(),
            '/about': (context) => AboutUs(),
            '/contact': (context) => ContactUs(),
            '/faq': (context) => FAQ(),
            '/events_list': (context) => EventListView(),
          },
        );
      },
    );
  }
}
