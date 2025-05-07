import 'package:event_reminder_app/screens/upcoming_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/on_boarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:event_reminder_app/screens/auth_screen.dart';
import 'package:event_reminder_app/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Reminder App',
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const UpcomingEventScreenWidget(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, String>> _events = [
    {'title': 'Meeting with Team', 'date': '2025-03-10'},
    {'title': 'Doctor Appointment', 'date': '2025-03-12'},
    {'title': 'Birthday Party', 'date': '2025-03-14'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color.fromARGB(255, 0, 34, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(_events[index]['title']!),
                      subtitle: Text(_events[index]['date']!),
                      trailing: IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
