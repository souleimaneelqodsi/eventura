import 'package:eventura/core/services/auth_service.dart';
import 'package:eventura/core/viewmodels/profile_viewmodel.dart';
import 'package:eventura/providers.dart';
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

  runApp(MultiProvider(providers: providers, child: const Eventura()));
}

final supabase = Supabase.instance.client;

class Eventura extends StatelessWidget {
  const Eventura({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eventura',
      theme: AppTheme().light,
      initialRoute: '/',
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
                  style: TextStyle(color: Colors.red),
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

          print('Navigating to profile with userId: $finalUserId');

          return ChangeNotifierProvider(
            key: ValueKey('profile_route_$finalUserId'), // Add a unique key
            create:
                (context) => ProfileViewmodel(
                  userService: Provider.of<AuthService>(context, listen: false),
                  userId: finalUserId,
                ),
            child: ProfileView(userId: finalUserId, fromHome: false),
          );
        },
        '/settings': (context) => SettingsView(),
        '/about': (context) => AboutUs(),
        '/contact': (context) => ContactUs(),
        '/faq': (context) => FAQ(),
        '/events_list': (context) => EventListView(),
      },
    );
  }
}
