import 'package:event_reminder_app/screens/upcoming_events_screen.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:event_reminder_app/screens/auth_screen.dart';
import 'package:event_reminder_app/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  await initializeNotifications();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    final user = FirebaseAuth.instance.currentUser;

    if (!onboardingDone) {
      return const OnboardingScreen();
    } else if (user != null) {
      return const UpcomingEventScreenWidget();
    } else {
      return const AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Reminder App',
      theme: ThemeData(primarySwatch: Colors.blue),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const UpcomingEventScreenWidget(),
      },
      home: FutureBuilder<Widget>(
        future: getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
