import 'package:event_reminder_app/models/app_user.dart';
import 'package:event_reminder_app/providers/theme_provider.dart';
import 'package:event_reminder_app/screens/upcoming_events_screen.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:event_reminder_app/screens/auth_screen.dart';
import 'package:event_reminder_app/screens/calender_screen.dart';
import 'package:event_reminder_app/screens/settings.dart';
import 'package:event_reminder_app/providers/user_provider.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeNotifications();
  await handlePermissionsFirstTimeOnly();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> handlePermissionsFirstTimeOnly() async {
  final prefs = await SharedPreferences.getInstance();
  final asked = prefs.getBool('asked_permissions') ?? false;

  if (!asked) {
    if (Platform.isAndroid && await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        package: 'com.example.event_reminder_app',
      );
      await intent.launch();
    }

    await prefs.setBool('asked_permissions', true);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        final appUser = AppUser(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName,
          email: firebaseUser.email,
          photoUrl: firebaseUser.photoURL,
        );
        await userProvider.setUser(appUser);
      } else {
        userProvider.clearUser();
      }

      if (!onboardingDone) {
        _initialScreen = const OnboardingScreen();
      } else if (firebaseUser != null) {
        _initialScreen = const UpcomingEventScreenWidget();
      } else {
        _initialScreen = const AuthScreen();
      }

      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Event Reminder App',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          home: _initialScreen,
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const UpcomingEventScreenWidget(),
            '/calender': (context) => const Calenderscreen(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
