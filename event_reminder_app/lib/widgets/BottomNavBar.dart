import 'package:event_reminder_app/screens/alerts.dart';
import 'package:event_reminder_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/calenderscreen.dart';
import 'package:event_reminder_app/screens/upcoming_events_screen.dart';
import 'package:event_reminder_app/screens/create_event_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  final Color enabledColor = const Color.fromARGB(255, 111, 97, 239);
  final Color disabledColor = const Color.fromARGB(255, 96, 106, 133);

  void onItemTapped(int index, BuildContext context) {
    if (index == currentIndex && index != 2) return;

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateEventScreen()),
      );
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UpcomingEventScreenWidget()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Calenderscreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AlertsScreenState()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color.fromARGB(26, 0, 0, 0),
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(0, context),
                  icon: Icon(
                    Icons.event_note_rounded,
                    color: currentIndex == 0 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Events',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 0 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(1, context),
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    color: currentIndex == 1 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 1 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => onItemTapped(2, context),
                  backgroundColor: const Color.fromARGB(255, 111, 97, 239),
                  elevation: 2,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(3, context),
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: currentIndex == 3 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Alerts',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 3 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onItemTapped(4, context),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: currentIndex == 4 ? enabledColor : disabledColor,
                    size: 28,
                  ),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: currentIndex == 4 ? enabledColor : disabledColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
