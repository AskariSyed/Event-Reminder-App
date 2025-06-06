import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_reminder_app/models/app_user.dart';
import 'package:event_reminder_app/services/notification_services.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;

  Future<void> setUser(AppUser user) async {
    _user = user;
    notifyListeners();
    await _fetchAndScheduleUserEvents();
  }

  void clearUser() {
    _user = null;
    flutterLocalNotificationsPlugin.cancelAll();
    notifyListeners();
  }

  Future<void> _fetchAndScheduleUserEvents() async {
    if (_user == null) return;

    final now = DateTime.now();

    final snapshot =
        await FirebaseFirestore.instance
            .collection('events')
            .where('userId', isEqualTo: _user!.uid)
            .where('eventDateTime', isGreaterThan: Timestamp.fromDate(now))
            .get();
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final eventDateTime = (data['eventDateTime'] as Timestamp).toDate();
      final title = data['title'] ?? 'Scheduled Event';

      await scheduleNotification(
        id: eventDateTime.hashCode,
        title: 'Reminder',
        body: title,
        scheduledDateTime: eventDateTime,
      );
    }
  }
}
