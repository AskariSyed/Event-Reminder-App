import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_reminder_app/providers/user_provider.dart';
import 'package:event_reminder_app/screens/create_event_screen.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:event_reminder_app/widgets/bottom_nav_bar.dart';
import 'package:event_reminder_app/widgets/build_event_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;

class UpcomingEventScreenWidget extends StatefulWidget {
  const UpcomingEventScreenWidget({super.key});

  @override
  State<UpcomingEventScreenWidget> createState() =>
      _UpcomingEventScreenWidgetState();
}

class _UpcomingEventScreenWidgetState extends State<UpcomingEventScreenWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _scheduleExistingEventNotifications(userId);
      }
    });
  }

  Future<void> _scheduleExistingEventNotifications(String userId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('events')
              .where('userId', isEqualTo: userId)
              .get();

      for (var doc in querySnapshot.docs) {
        final event = doc.data();
        if (event['notificationId'] != null &&
            event['date'] != null &&
            event['time'] != null) {
          try {
            final date = DateFormat('EEEE, MMMM d, yyyy').parse(event['date']);
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
              await scheduleNotification(
                id: event['notificationId'],
                title: event['title'] ?? 'Event Reminder',
                body:
                    '📍 ${event['location'] ?? ''}\n📝 ${event['description'] ?? ''}',
                scheduledDateTime: combinedDateTime,
              );
            }
          } catch (e) {
            print(
              'Debug: Error scheduling notification for event ${event['id']}: $e',
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scheduling notifications: $e')),
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation,
          title: Text(
            'Events',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Passed'),
              Tab(text: 'Upcoming'),
              Tab(text: 'All'),
            ],
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).textTheme.bodyLarge?.color,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(userId, filter: 'passed'),
              _buildEventList(userId, filter: 'upcoming'),
              _buildEventList(userId, filter: 'all'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateEventScreen(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0),
      ),
    );
  }

  Widget _buildEventList(String? userId, {required String filter}) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    userId ??= firebaseUser?.uid;
    if (userId == null) {
      return const Center(child: Text('User not logged in.'));
    }

    final baseQuery = FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId)
        .orderBy('date');
    final eventStream = baseQuery.snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: eventStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching events.'));
        }
        final allEvents = snapshot.data?.docs ?? [];

        final filteredEvents =
            allEvents.where((doc) {
              final event = doc.data() as Map<String, dynamic>;
              final status = calculateRemainingTime(event, returnStatus: true);
              if (filter == 'passed') {
                return status == 'passed';
              } else if (filter == 'upcoming') {
                return status != 'passed';
              } else {
                return true;
              }
            }).toList();

        if (filteredEvents.isEmpty) {
          return Center(
            child: Text(
              'No $filter events.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final eventDoc = filteredEvents[index];
            final event = eventDoc.data() as Map<String, dynamic>;
            final docId = eventDoc.id;
            final eventTitle = event['title'] ?? 'Event';

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Dismissible(
                key: Key(docId),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    FirebaseFirestore.instance
                        .collection('events')
                        .doc(docId)
                        .delete()
                        .then((_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$eventTitle deleted')),
                              );
                            }
                          });
                        })
                        .catchError((error) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting event: $error'),
                                ),
                              );
                            }
                          });
                        });
                  });
                },
                child: buildEventCard(event, context, docId),
              ),
            );
          },
        );
      },
    );
  }
}
