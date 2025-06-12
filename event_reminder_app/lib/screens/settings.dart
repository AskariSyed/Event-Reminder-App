import 'package:event_reminder_app/providers/theme_provider.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize notificationsEnabled based on existing events
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: user.uid)
              .get();
      // Consider notifications enabled if at least one event has a notificationId
      bool hasNotifications = querySnapshot.docs.any(
        (doc) => doc['notificationId'] != null,
      );
      setState(() {
        notificationsEnabled = hasNotifications;
      });
    } catch (e) {
      print('Debug: Error checking notification status: $e');
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please log in to manage notifications.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
      return;
    }

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: user.uid)
              .get();

      if (!value) {
        for (var doc in querySnapshot.docs) {
          final event = doc.data();
          if (event['notificationId'] != null) {
            await cancelNotification(event['notificationId']);
            await FirebaseFirestore.instance
                .collection('events')
                .doc(doc.id)
                .update({'notificationId': null});
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'All notifications disabled.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        }
      } else {
        for (var doc in querySnapshot.docs) {
          final event = doc.data();
          if (event['date'] != null && event['time'] != null) {
            try {
              final date = DateFormat(
                'EEEE, MMMM d, yyyy',
              ).parse(event['date']);
              final time = _parseTime(event['time']);
              if (time == null) continue;

              final combinedDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );

              final tzScheduledDateTime = tz.TZDateTime.from(
                combinedDateTime,
                tz.local,
              );
              if (tzScheduledDateTime.isAfter(tz.TZDateTime.now(tz.local))) {
                final notificationId =
                    DateTime.now().millisecondsSinceEpoch ~/ 1000;
                await scheduleNotification(
                  id: notificationId,
                  title: event['title'] ?? 'Event Reminder',
                  body:
                      '📍 ${event['location'] ?? ''}\n📝 ${event['description'] ?? ''}',
                  scheduledDateTime: combinedDateTime,
                );
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(doc.id)
                    .update({'notificationId': notificationId});
              }
            } catch (e) {
              print(
                'Debug: Error scheduling notification for event ${event['id']}: $e',
              );
            }
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Notifications enabled for all future events.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
          );
        }
      }

      setState(() {
        notificationsEnabled = value;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error managing notifications: $e',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        );
      }
    }
  }

  TimeOfDay? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    try {
      final cleanedTimeString =
          timeStr
              .replaceAll(
                RegExp(r'[\u202F\u00A0\u2007\u2060\uFEFF\u200B]'),
                ' ',
              )
              .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
              .replaceAll(RegExp(r'\s+'), ' ')
              .trim();
      final timeParts = cleanedTimeString.split(' ');
      if (timeParts.length != 2) {
        throw FormatException('Invalid time format: $cleanedTimeString');
      }

      final timeValue = timeParts[0];
      final period = timeParts[1].toUpperCase();

      final timeComponents = timeValue.split(':');
      if (timeComponents.length != 2) {
        throw FormatException('Invalid time components: $timeValue');
      }

      int hour = int.parse(timeComponents[0]);
      final minute = int.parse(timeComponents[1]);

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Debug: Error parsing time "$timeStr": $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final user = FirebaseAuth.instance.currentUser;
        final String userName = user?.displayName ?? 'User';
        final String? photoUrl = user?.photoURL;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: buildAppBar('Settings', context),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                // Profile Card
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          backgroundColor: Theme.of(context).primaryColor,
                          child:
                              photoUrl == null
                                  ? const Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage your profile',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Notification Preferences Section
                const SizedBox(height: 16),
                Text(
                  'Notification Preferences',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enable Notifications',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                        Switch(
                          value: notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Appearance Section
                const SizedBox(height: 16),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Mode',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(fontSize: 16),
                        ),
                        Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme(value);
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // About Section
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Event Reminder App',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 24),
                              child: Text(
                                'Version 1.0.0',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Privacy Policy coming soon!',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Privacy Policy',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Terms of Use coming soon!',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                        ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.surface,
                                    ),
                                  );
                                },
                                child: Text(
                                  'Terms of Use',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Developed by ',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'Askari:Quratulain',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Logout Button
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: handleLogout,
                    style: Theme.of(context).elevatedButtonTheme.style,
                    child: Text(
                      'Logout',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(currentIndex: 2),
        );
      },
    );
  }

  void handleLogout() async {
    try {
      await GoogleSignIn().disconnect();
    } catch (e) {
      print(e);
    }
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Logged out successfully!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
    Navigator.of(context).pushReplacementNamed('/auth');
  }
}
