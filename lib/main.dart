  import 'package:eventura/providers.dart';
  import 'package:eventura/ui/static/about_us.dart';
  import 'package:eventura/ui/static/contact_us.dart';
  import 'package:eventura/ui/static/faq.dart';
  import 'package:eventura/ui/views/events_list_view.dart';
  import 'package:flutter/material.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:provider/provider.dart';
  import 'package:eventura/ui/views/auth/login_view.dart';
  import 'package:eventura/ui/views/homepage_view.dart';
  import 'package:eventura/ui/views/auth/signup_view.dart';
  import 'package:eventura/ui/views/auth/reset_password_view.dart';
  import 'package:eventura/ui/shared/app_theme.dart';
  import 'package:eventura/core/services/auth_service.dart'; 
  import 'package:eventura/ui/views/create_event_view.dart';
  import 'package:eventura/ui/views/event_detail_view.dart';
  import 'package:eventura/ui/views/friends_view.dart';
  import 'package:eventura/ui/views/messages_view.dart';
  import 'package:eventura/ui/views/profile_view.dart';
  import 'package:eventura/ui/views/settings_view.dart';

import 'package:eventura/ui/static/about_us.dart';
import 'package:eventura/ui/static/contact_us.dart';
import 'package:eventura/ui/static/faq.dart';
import 'package:eventura/ui/views/events_list_view.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:eventura/ui/views/auth/login_view.dart';
import 'package:eventura/ui/views/homepage_view.dart';
import 'package:eventura/ui/views/auth/signup_view.dart';
import 'package:eventura/ui/views/auth/reset_password_view.dart';
import 'package:eventura/ui/shared/app_theme.dart';
import 'package:eventura/core/services/auth_service.dart'; // For AuthWrapper
// Import all your views
import 'package:eventura/ui/views/create_event_view.dart';
import 'package:eventura/ui/views/event_detail_view.dart';
import 'package:eventura/ui/views/friends_view.dart';
import 'package:eventura/ui/views/messages_view.dart';
import 'package:eventura/ui/views/profile_view.dart';
import 'package:eventura/ui/views/settings_view.dart';


  final supabase = Supabase.instance.client;

  Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");

    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];

    await Supabase.initialize(
      url: supabaseUrl!,
      anonKey: supabaseKey!,
    );
    runApp(
      MultiProvider(
        providers: providers,
        child: const MyApp(),
      ),
    );
  }
  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supabaseKey!,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(create: (_) => AuthService(supabaseClient: supabase)),
      ],
      child: const MyApp(),
    ),
  );
}

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Eventura',
        theme: AppTheme.lightTheme, 
        initialRoute: '/', 
        routes: {
          '/': (context) => AuthWrapper(), 
          '/login': (context) => LoginView(),
          '/signup': (context) => SignupView(),
          '/reset_password': (context) => ResetPasswordView(),
          '/home': (context) => HomepageView(), 
          '/events': (context) => EventListView(), 
          '/create_event': (context) => CreateEventView(),
          '/event_detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            final eventId = args as int?; 
            if (eventId == null) {
                return const Scaffold(body: Center(child: Text("Error: No Event ID")));
            }
            return EventDetailView(eventId: eventId);
          },
          '/friends': (context) => FriendsView(),
          '/messages': (context) => MessagesView(), 
          '/profile': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              final userId = args as String?;

              return ProfileView(userId: userId ?? supabase.auth.currentUser!.id);
          },
          '/settings': (context) => SettingsView(),
          '/about': (context) => AboutUs(),
          '/contact': (context) => ContactUs(),
          '/faq': (context) => FAQ(),
        },
      );
    }
  }


  class AuthWrapper extends StatelessWidget {
    const AuthWrapper({super.key});


    @override
    Widget build(BuildContext context) {
      Provider.of<AuthService>(context);
      final supabaseClient = Supabase.instance.client;

      return StreamBuilder<User?>(
        stream: supabaseClient.auth.onAuthStateChange.map((event) => event.session?.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData) {
            return HomepageView();
          } else {
            return LoginView();
          }
        },
      );
    }
  }

        if (snapshot.hasData) {
          return HomepageView();
        } else {
          return LoginView();
        }
      },
    );
  }
}
