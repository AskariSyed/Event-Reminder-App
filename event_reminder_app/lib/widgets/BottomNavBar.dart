import 'package:event_reminder_app/screens/alerts.dart';
import 'package:event_reminder_app/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:event_reminder_app/screens/calenderscreen.dart';
import 'package:event_reminder_app/screens/upcoming_events_screen.dart';
import 'package:event_reminder_app/screens/create_event_screen.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;
  final Color enabledColor = const Color.fromARGB(255, 111, 97, 239);
  final Color disabledColor = const Color.fromARGB(255, 96, 106, 133);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
  }

  void _onItemTapped(int index, BuildContext context) {
    // If the tapped index is the same as the current index, do nothing
    // (except for the Create Event screen, which we handle differently)
    if (_currentIndex == index && index != 2) {
      return; // Prevent reloading the same screen
    }

    // Update the current index to highlight the selected tab
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on the index
    switch (index) {
      case 0:
        // Only navigate if not already on UpcomingEventScreenWidget
        if (context.widget.runtimeType != UpcomingEventScreenWidget) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => UpcomingEventScreenWidget(),
            ),
          );
        }
        break;
      case 1:
        // Only navigate if not already on Calenderscreen
        if (context.widget.runtimeType != Calenderscreen) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Calenderscreen()),
          );
        }
        break;
      case 2:
        // For Create Event Screen
        if (context.widget.runtimeType == CreateEventScreen) {
          // If already on CreateEventScreen, pop the screen to go back
          Navigator.pop(context);
        } else {
          // If not on CreateEventScreen, navigate to it
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
        }
        break;
      case 3:
        // Only navigate if not already on AlertsScreenState
        if (context.widget.runtimeType != AlertsScreenState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AlertsScreenState()),
          );
        }
        break;
      case 4:
        // Only navigate if not already on SettingsPage
        if (context.widget.runtimeType != SettingsPage) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80.0,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color.fromARGB(26, 0, 0, 0),
            offset: Offset(0.0, -2.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Events Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _onItemTapped(0, context),
                  icon: Icon(
                    Icons.event_note_rounded,
                    color: _currentIndex == 0 ? enabledColor : disabledColor,
                    size: 28.0,
                  ),
                ),
                Text(
                  'Events',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: _currentIndex == 0 ? enabledColor : disabledColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Calendar Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _onItemTapped(1, context),
                  icon: Icon(
                    Icons.calendar_today_rounded,
                    color: _currentIndex == 1 ? enabledColor : disabledColor,
                    size: 28.0,
                  ),
                ),
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: _currentIndex == 1 ? enabledColor : disabledColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Create Event Tab (Floating Action Button)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () => _onItemTapped(2, context),
                  backgroundColor: const Color.fromARGB(255, 111, 97, 239),
                  elevation: 2.0,
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ),
              ],
            ),
            // Alerts Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _onItemTapped(3, context),
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: _currentIndex == 3 ? enabledColor : disabledColor,
                    size: 28.0,
                  ),
                ),
                Text(
                  'Alerts',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: _currentIndex == 3 ? enabledColor : disabledColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Settings Tab
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _onItemTapped(4, context),
                  icon: Icon(
                    Icons.settings_outlined,
                    color: _currentIndex == 4 ? enabledColor : disabledColor,
                    size: 28.0,
                  ),
                ),
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: _currentIndex == 4 ? enabledColor : disabledColor,
                    fontSize: 12.0,
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
