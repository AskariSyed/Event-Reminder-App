import 'package:event_reminder_app/widgets/BottomNavBar.dart';
import 'package:event_reminder_app/widgets/appbar.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String defaultReminderTime = '10 minutes';
  bool isDarkMode = false;

  // List of reminder time options
  final List<String> reminderTimes = [
    '5 minutes',
    '10 minutes',
    '30 minutes',
    '1 hour',
    '1 day',
  ];

  // Placeholder for user name (replace with actual user data)
  final String userName = 'Askari Syed';

  void handleLogout() {
    // Placeholder for logout logic
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully!')));
    // Add navigation to login screen or similar logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: buildAppBar('Settings'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          children: [
            // Profile Card
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF6C63FF),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Manage your profile',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Notification Preferences Section
            const SizedBox(height: 16),
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Notifications',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Default Reminder Time',
                      style: TextStyle(fontSize: 16),
                    ),
                    DropdownButton<String>(
                      value: defaultReminderTime,
                      items:
                          reminderTimes.map((String time) {
                            return DropdownMenuItem<String>(
                              value: time,
                              child: Text(time),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          defaultReminderTime = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Appearance Section
            const SizedBox(height: 16),
            const Text(
              'Appearance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        setState(() {
                          isDarkMode = value; // Fixed to allow toggling
                        });
                      },
                      activeColor: const Color(0xFF6C63FF),
                    ),
                  ],
                ),
              ),
            ),

            // About Section
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
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
                        const Text(
                          'Event Reminder App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: const Text(
                            'Version 1.0.0',
                            style: TextStyle(color: Colors.grey),
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
                                const SnackBar(
                                  content: Text('Privacy Policy coming soon!'),
                                ),
                              );
                            },
                            child: const Text(
                              'Privacy Policy',
                              style: TextStyle(color: Color(0xFF6C63FF)),
                            ),
                          ),
                        ),

                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Terms of Use coming soon!'),
                                ),
                              );
                            },
                            child: const Text(
                              'Terms of Use',
                              style: TextStyle(color: Color(0xFF6C63FF)),
                            ),
                          ),
                        ),

                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Developed by ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const Text(
                                'Askari',
                                style: TextStyle(color: Colors.grey),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(currentIndex: 4),
    );
  }
}
