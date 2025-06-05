import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/mixin/event_list.dart';

class AlertsScreenState extends StatefulWidget {
  const AlertsScreenState({super.key});

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreenState> {
  // List to store dismissed events (notification history)
  final List<Map<String, String>> notificationHistory = [];

  String getTimeUntilEvent(Map<String, String> event) {
    DateTime now = DateTime.now();
    DateTime eventDateTime;

    try {
      String dateString = event['date']!.replaceFirst('Today, ', '');
      DateTime eventDate = DateFormat('EEEE, MMMM d, yyyy').parse(dateString);
      String startTime = event['time']!.split(' - ')[0];
      DateTime eventTime = DateFormat('h:mm a').parse(startTime);

      eventDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        eventTime.hour,
        eventTime.minute,
      );
    } catch (e) {
      return 'Invalid date/time';
    }

    Duration difference = eventDateTime.difference(now);

    if (difference.isNegative) {
      return 'Event has passed';
    }

    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    if (days > 0) {
      return 'In $days day${days > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return 'In $hours hour${hours > 1 ? 's' : ''}';
    } else if (minutes > 0) {
      return 'In $minutes minute${minutes > 1 ? 's' : ''}';
    } else {
      return 'Now';
    }
  }

  // Check if the event is upcoming
  bool isEventUpcoming(Map<String, String> event) {
    DateTime now = DateTime.now();
    DateTime eventDateTime;

    try {
      String dateString = event['date']!.replaceFirst('Today, ', '');
      DateTime eventDate = DateFormat('EEEE, MMMM d, yyyy').parse(dateString);
      String startTime = event['time']!.split(' - ')[0];
      DateTime eventTime = DateFormat('h:mm a').parse(startTime);
      eventDateTime = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
        eventTime.hour,
        eventTime.minute,
      );
    } catch (e) {
      return false;
    }

    return eventDateTime.isAfter(now);
  }

  void snoozeAlert(Map<String, String> event) {
    // In a real app, you'd reschedule the notification using flutter_local_notifications
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${event['title']} snoozed for 10 minutes')),
    );
  }

  void dismissAlert(Map<String, String> event) {
    setState(() {
      // Move the event to notification history
      notificationHistory.insert(0, event);
      events.remove(event);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Alert dismissed')));
  }

  @override
  Widget build(BuildContext context) {
    // Filter events to show only upcoming events
    List<Map<String, String>> activeAlerts =
        events.where((event) => isEventUpcoming(event)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: buildAppBar('Alerts'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Active Alerts Section
            const SizedBox(height: 16),
            const Text(
              'Active Alerts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (activeAlerts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No active alerts.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...activeAlerts.asMap().entries.map((entry) {
                // ignore: unused_local_variable
                int index = entry.key;
                Map<String, String> event = entry.value;
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(int.parse(event['timeColor']!)),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${getTimeUntilEvent(event)} • ${event['time']}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                event['date']!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.snooze,
                                color: Color(0xFF6C63FF),
                              ),
                              onPressed: () => snoozeAlert(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => dismissAlert(event),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            // Notification History Section
            const SizedBox(height: 16),
            const Text(
              'Notification History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (notificationHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'No notification history.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...notificationHistory.map((event) {
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dismissed on April 20, 2025 at 11:08 PM',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 3),
    );
  }
}
